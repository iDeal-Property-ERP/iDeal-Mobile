import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings_cached.dart';
import 'package:ideal_mobile/services/favorites_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  ListingsBloc({
    GetListings? getListings,
    GetListingFilterOptions? getFilterOptions,
    GetListingFilterOptions? getListingFilterOptions,
    GetListingsCached? getListingsCached,
    GetListingFilterOptionsCached? getFilterOptionsCached,
    FavoritesService? favoritesService,
    PerformanceMonitoringService? performanceService,
  }) : _getListings = getListings ?? sl<GetListings>(),
       _getFilterOptions =
           getFilterOptions ??
           getListingFilterOptions ??
           sl<GetListingFilterOptions>(),
       _getListingsCached =
           getListingsCached ??
           (sl.isRegistered<GetListingsCached>()
               ? sl<GetListingsCached>()
               : null),
       _getFilterOptionsCached =
           getFilterOptionsCached ??
           (sl.isRegistered<GetListingFilterOptionsCached>()
               ? sl<GetListingFilterOptionsCached>()
               : null),
       _favoritesService =
           favoritesService ??
           (sl.isRegistered<FavoritesService>()
               ? sl<FavoritesService>()
               : const FavoritesService()),
       _performanceService =
           performanceService ??
           (sl.isRegistered<PerformanceMonitoringService>()
               ? sl<PerformanceMonitoringService>()
               : PerformanceMonitoringService()),
       super(ListingsState.initial()) {
    _setupEventListeners();
  }

  final GetListings _getListings;
  final GetListingFilterOptions _getFilterOptions;
  final GetListingsCached? _getListingsCached;
  final GetListingFilterOptionsCached? _getFilterOptionsCached;
  final FavoritesService _favoritesService;
  final PerformanceMonitoringService _performanceService;
  Timer? _searchDebounce;

  void _setupEventListeners() {
    on<LoadListingsEvent>(_onLoadListingsEvent);
    on<LoadMoreListingsEvent>(_onLoadMoreListingsEvent);
    on<SearchListingsEvent>(_onSearchListingsEvent);
    on<_DebouncedSearchListingsEvent>(_onDebouncedSearchListingsEvent);
    on<ApplyListingFiltersEvent>(_onApplyListingFiltersEvent);
    on<ClearListingFiltersEvent>(_onClearListingFiltersEvent);
    on<LoadFilterOptionsEvent>(_onLoadFilterOptionsEvent);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);
    on<LoadFavoritesEvent>(_onLoadFavoritesEvent);
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onLoadListingsEvent(
    LoadListingsEvent event,
    Emitter<ListingsState> emit,
  ) {
    _searchDebounce?.cancel();
    return _loadListings(
      filters: state.filters,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onLoadMoreListingsEvent(
    LoadMoreListingsEvent event,
    Emitter<ListingsState> emit,
  ) {
    if (state.hasReachedMax || state.isLoadingMore) return Future.value();

    final nextPage = state.page + 1;
    emit(
      ListingsLoadingMoreState(
        state.copyWith(isLoadingMore: true, clearErrorMessage: true),
      ),
    );
    return _loadListings(
      filters: state.filters,
      page: nextPage,
      replaceItems: false,
      emit: emit,
    );
  }

  void _onSearchListingsEvent(
    SearchListingsEvent event,
    Emitter<ListingsState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(_DebouncedSearchListingsEvent(event.query));
    });
  }

  Future<void> _onDebouncedSearchListingsEvent(
    _DebouncedSearchListingsEvent event,
    Emitter<ListingsState> emit,
  ) {
    final query = event.query.trim();
    final filters = query.isEmpty
        ? state.filters.copyWith(clearQuery: true)
        : state.filters.copyWith(query: query);
    return _loadListings(
      filters: filters,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onApplyListingFiltersEvent(
    ApplyListingFiltersEvent event,
    Emitter<ListingsState> emit,
  ) {
    _searchDebounce?.cancel();
    return _loadListings(
      filters: event.filters,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onClearListingFiltersEvent(
    ClearListingFiltersEvent event,
    Emitter<ListingsState> emit,
  ) {
    _searchDebounce?.cancel();
    return _loadListings(
      filters: const ListingFilters.empty(),
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onLoadFilterOptionsEvent(
    LoadFilterOptionsEvent event,
    Emitter<ListingsState> emit,
  ) async {
    _performanceService.startTrace(kTraceApiGetListings);
    final cached = _getFilterOptionsCached;
    if (cached != null) {
      await for (final result in cached()) {
        result.fold(
          (failure) => emit(
            ListingsErrorState(state, errorMessage: failure.errorMessage),
          ),
          (event) => emit(
            ListingFilterOptionsLoadedState(
              state.copyWith(
                filterOptions: event.data,
                // Filter data must not change the feed's cache/stale state.
              ),
            ),
          ),
        );
      }
      _performanceService.stopTrace(kTraceApiGetListings);
      return;
    }
    final result = await _getFilterOptions();
    result.fold(
      (failure) {
        _performanceService.putAttribute(
          kTraceApiGetListings,
          kTraceAttrError,
          failure.errorMessage.truncate(100),
        );
        emit(ListingsErrorState(state, errorMessage: failure.errorMessage));
      },
      (options) {
        _performanceService.putAttribute(
          kTraceApiGetListings,
          kTraceAttrSuccess,
          true,
        );
        emit(
          ListingFilterOptionsLoadedState(
            state.copyWith(filterOptions: options, clearErrorMessage: true),
          ),
        );
      },
    );
    _performanceService.stopTrace(kTraceApiGetListings);
  }

  Future<void> _onToggleFavoriteEvent(
    ToggleFavoriteEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final favoriteIds = await _favoritesService.toggle(event.listingId);
    emit(state.copyWith(favoriteIds: favoriteIds));
  }

  Future<void> _onLoadFavoritesEvent(
    LoadFavoritesEvent event,
    Emitter<ListingsState> emit,
  ) async {
    final favoriteIds = await _favoritesService.load();
    emit(state.copyWith(favoriteIds: favoriteIds));
  }

  Future<void> _loadListings({
    required ListingFilters filters,
    required int page,
    required bool replaceItems,
    required Emitter<ListingsState> emit,
  }) async {
    if (replaceItems) {
      emit(
        ListingsLoadingState(
          state.copyWith(
            filters: filters,
            searchQuery: filters.query ?? '',
            page: 1,
            hasReachedMax: false,
            isLoadingMore: false,
            clearErrorMessage: true,
            clearListingRefreshError: true,
          ),
        ),
      );
    }

    _performanceService.startTrace(kTraceApiGetListings);
    final cached = _getListingsCached;
    if (replaceItems && cached != null) {
      await for (final result in cached(filters: filters, page: page)) {
        result.fold(
          (failure) {
            _performanceService.putAttribute(
              kTraceApiGetListings,
              kTraceAttrError,
              failure.errorMessage.truncate(100),
            );
            emit(
              ListingsErrorState(
                state.copyWith(isLoadingMore: false),
                errorMessage: failure.errorMessage,
              ),
            );
          },
          (event) {
            final response = event.data;
            emit(
              ListingsLoadedState(
                state.copyWith(
                  items: response.items,
                  filters: filters,
                  searchQuery: filters.query ?? '',
                  page: response.pageNumber,
                  numPages: response.numPages,
                  count: response.count,
                  hasReachedMax: response.pageNumber >= response.numPages,
                  isLoadingMore: false,
                  dataOrigin: event.origin,
                  isStale: event.isStale,
                  listingRefreshError: event.refreshError?.toString(),
                  clearListingRefreshError: event.refreshError == null,
                  clearErrorMessage: event.refreshError == null,
                ),
              ),
            );
          },
        );
      }
      _performanceService.stopTrace(kTraceApiGetListings);
      return;
    }
    final result = await _getListings(
      GetListingsParams(filters: filters, page: page),
    );

    result.fold(
      (failure) {
        _performanceService.putAttribute(
          kTraceApiGetListings,
          kTraceAttrError,
          failure.errorMessage.truncate(100),
        );
        emit(
          ListingsErrorState(
            state.copyWith(isLoadingMore: false),
            errorMessage: failure.errorMessage,
          ),
        );
      },
      (response) {
        _performanceService.putAttribute(
          kTraceApiGetListings,
          kTraceAttrSuccess,
          true,
        );
        final items = replaceItems
            ? response.items
            : [...state.items, ...response.items];
        emit(
          ListingsLoadedState(
            state.copyWith(
              items: items,
              filters: filters,
              searchQuery: filters.query ?? '',
              page: response.pageNumber,
              numPages: response.numPages,
              count: response.count,
              hasReachedMax: response.pageNumber >= response.numPages,
              isLoadingMore: false,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );

    _performanceService.stopTrace(kTraceApiGetListings);
  }
}

class _DebouncedSearchListingsEvent extends ListingsEvent {
  const _DebouncedSearchListingsEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
