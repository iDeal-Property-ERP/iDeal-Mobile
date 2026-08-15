import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings_cached.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  ListingsBloc({
    GetListings? getListings,
    GetListingFilterOptions? getFilterOptions,
    GetListingFilterOptions? getListingFilterOptions,
    GetListingsCached? getListingsCached,
    GetListingFilterOptionsCached? getFilterOptionsCached,
    SetListingFavorite? setListingFavorite,
    FavoritesSyncService? favoritesSyncService,
    LegacyFavoritesCleanupService? legacyFavoritesCleanupService,
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
       _setListingFavorite = setListingFavorite ?? sl<SetListingFavorite>(),
       _favoritesSyncService =
           favoritesSyncService ?? sl<FavoritesSyncService>(),
       _legacyFavoritesCleanupService =
           legacyFavoritesCleanupService ?? sl<LegacyFavoritesCleanupService>(),
       _performanceService =
           performanceService ??
           (sl.isRegistered<PerformanceMonitoringService>()
               ? sl<PerformanceMonitoringService>()
               : PerformanceMonitoringService()),
       super(ListingsState.initial()) {
    _setupEventListeners();
    _favoriteSyncSubscription = _favoritesSyncService.stream.listen((change) {
      add(
        SyncFavoriteStatusEvent(
          listingId: change.listingId,
          isFavorite: change.isFavorite,
        ),
      );
    });
    unawaited(_legacyFavoritesCleanupService.clearLegacyFavoritesOnce());
  }

  final GetListings _getListings;
  final GetListingFilterOptions _getFilterOptions;
  final GetListingsCached? _getListingsCached;
  final GetListingFilterOptionsCached? _getFilterOptionsCached;
  final SetListingFavorite _setListingFavorite;
  final FavoritesSyncService _favoritesSyncService;
  final LegacyFavoritesCleanupService _legacyFavoritesCleanupService;
  final PerformanceMonitoringService _performanceService;
  Timer? _searchDebounce;
  StreamSubscription<FavoriteStatusChange>? _favoriteSyncSubscription;
  final Map<int, _FavoriteMutation> _favoriteMutations = {};
  final Map<int, bool> _favoriteStatusOverrides = {};
  final Map<int, Future<void>> _favoriteMutationTails = {};
  int _favoriteMutationVersion = 0;

  void _setupEventListeners() {
    on<LoadListingsEvent>(_onLoadListingsEvent);
    on<LoadMoreListingsEvent>(_onLoadMoreListingsEvent);
    on<SearchListingsEvent>(_onSearchListingsEvent);
    on<_DebouncedSearchListingsEvent>(_onDebouncedSearchListingsEvent);
    on<ApplyListingFiltersEvent>(_onApplyListingFiltersEvent);
    on<ClearListingFiltersEvent>(_onClearListingFiltersEvent);
    on<LoadFilterOptionsEvent>(_onLoadFilterOptionsEvent);
    on<ToggleFavoriteEvent>(_onToggleFavoriteEvent);
    on<ClearFavoriteFeedbackEvent>(_onClearFavoriteFeedbackEvent);
    on<SyncFavoriteStatusEvent>(_onSyncFavoriteStatusEvent);
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await _favoriteSyncSubscription?.cancel();
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
    if (state.isListingsLoading || state.hasReachedMax || state.isLoadingMore) {
      return Future.value();
    }

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
          (optionsEvent) => emit(
            ListingFilterOptionsLoadedState(
              state.copyWith(filterOptions: optionsEvent.data),
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
    final currentItem = _itemForId(state.items, event.listingId);
    if (currentItem == null) return;

    final nextIsFavorite = !currentItem.isFavorite;
    final mutation = _FavoriteMutation(
      version: ++_favoriteMutationVersion,
      isFavorite: nextIsFavorite,
      previousIsFavorite: currentItem.isFavorite,
    );
    _favoriteMutations[event.listingId] = mutation;
    _favoriteStatusOverrides[event.listingId] = nextIsFavorite;
    emit(
      ListingsLoadedState(
        state.copyWith(
          items: _setFavoriteStatus(
            state.items,
            event.listingId,
            nextIsFavorite,
          ),
          clearFavoriteMutationErrorMessage: true,
        ),
      ),
    );

    final previousMutation =
        _favoriteMutationTails[event.listingId] ?? Future<void>.value();
    final operation = previousMutation.then<void>(
      (_) => _completeFavoriteMutation(
        listingId: event.listingId,
        mutation: mutation,
        emit: emit,
      ),
    );
    _favoriteMutationTails[event.listingId] = operation;

    try {
      await operation;
    } finally {
      if (identical(_favoriteMutationTails[event.listingId], operation)) {
        unawaited(_favoriteMutationTails.remove(event.listingId));
      }
    }
  }

  Future<void> _completeFavoriteMutation({
    required int listingId,
    required _FavoriteMutation mutation,
    required Emitter<ListingsState> emit,
  }) async {
    final result = await _setListingFavorite(
      SetListingFavoriteParams(
        listingId: listingId,
        isFavorite: mutation.isFavorite,
      ),
    );

    if (!_isCurrentFavoriteMutation(listingId, mutation)) return;

    _favoriteMutations.remove(listingId);
    result.fold(
      (failure) {
        _favoriteStatusOverrides[listingId] = mutation.previousIsFavorite;
        emit(
          ListingsLoadedState(
            state.copyWith(
              items: _setFavoriteStatus(
                state.items,
                listingId,
                mutation.previousIsFavorite,
              ),
              favoriteMutationErrorMessage: failure.message,
            ),
          ),
        );
      },
      (_) {
        _favoriteStatusOverrides[listingId] = mutation.isFavorite;
        _favoritesSyncService.publish(
          FavoriteStatusChange(
            listingId: listingId,
            isFavorite: mutation.isFavorite,
          ),
        );
      },
    );
  }

  void _onClearFavoriteFeedbackEvent(
    ClearFavoriteFeedbackEvent event,
    Emitter<ListingsState> emit,
  ) {
    if (state.favoriteMutationErrorMessage == null) return;
    emit(
      ListingsLoadedState(
        state.copyWith(clearFavoriteMutationErrorMessage: true),
      ),
    );
  }

  void _onSyncFavoriteStatusEvent(
    SyncFavoriteStatusEvent event,
    Emitter<ListingsState> emit,
  ) {
    final item = _itemForId(state.items, event.listingId);
    if (item == null) return;

    final pendingMutation = _favoriteMutations[event.listingId];
    final isFavorite = pendingMutation?.isFavorite ?? event.isFavorite;
    if (pendingMutation == null) {
      _favoriteStatusOverrides[event.listingId] = event.isFavorite;
    }
    if (item.isFavorite == isFavorite) return;
    emit(
      ListingsLoadedState(
        state.copyWith(
          items: _setFavoriteStatus(state.items, event.listingId, isFavorite),
        ),
      ),
    );
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
            isListingsLoading: true,
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
                state.copyWith(isLoadingMore: false, isListingsLoading: false),
                errorMessage: failure.errorMessage,
              ),
            );
          },
          (cacheEvent) {
            final response = cacheEvent.data;
            emit(
              ListingsLoadedState(
                state.copyWith(
                  items: _applyPendingFavoriteStatuses(response.items),
                  filters: filters,
                  searchQuery: filters.query ?? '',
                  page: response.pageNumber,
                  numPages: response.numPages,
                  count: response.count,
                  hasReachedMax: response.pageNumber >= response.numPages,
                  isLoadingMore: false,
                  isListingsLoading: false,
                  hasLoadedListings: true,
                  dataOrigin: cacheEvent.origin,
                  isStale: cacheEvent.isStale,
                  listingRefreshError: cacheEvent.refreshError?.toString(),
                  clearListingRefreshError: cacheEvent.refreshError == null,
                  clearErrorMessage: cacheEvent.refreshError == null,
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
            state.copyWith(isLoadingMore: false, isListingsLoading: false),
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
            ? _applyPendingFavoriteStatuses(response.items)
            : _appendPendingFavoriteStatuses(response.items);
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
              isListingsLoading: false,
              hasLoadedListings: true,
              clearErrorMessage: true,
            ),
          ),
        );
      },
    );

    _performanceService.stopTrace(kTraceApiGetListings);
  }

  bool _isCurrentFavoriteMutation(int listingId, _FavoriteMutation mutation) {
    return identical(_favoriteMutations[listingId], mutation) &&
        _favoriteMutations[listingId]?.version == mutation.version;
  }

  List<ListingCard> _applyPendingFavoriteStatuses(List<ListingCard> items) {
    return [
      for (final item in items)
        item.copyWith(
          isFavorite:
              _favoriteMutations[item.id]?.isFavorite ??
              _favoriteStatusOverrides[item.id] ??
              item.isFavorite,
        ),
    ];
  }

  List<ListingCard> _appendPendingFavoriteStatuses(List<ListingCard> items) {
    final combined = [...state.items, ..._applyPendingFavoriteStatuses(items)];
    final seenIds = <int>{};
    return [
      for (final item in combined)
        if (seenIds.add(item.id)) item,
    ];
  }
}

class _FavoriteMutation {
  const _FavoriteMutation({
    required this.version,
    required this.isFavorite,
    required this.previousIsFavorite,
  });

  final int version;
  final bool isFavorite;
  final bool previousIsFavorite;
}

ListingCard? _itemForId(List<ListingCard> items, int listingId) {
  for (final item in items) {
    if (item.id == listingId) return item;
  }
  return null;
}

List<ListingCard> _setFavoriteStatus(
  List<ListingCard> items,
  int listingId,
  bool isFavorite,
) {
  return [
    for (final item in items)
      item.id == listingId ? item.copyWith(isFavorite: isFavorite) : item,
  ];
}

class _DebouncedSearchListingsEvent extends ListingsEvent {
  const _DebouncedSearchListingsEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
