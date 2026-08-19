import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_event.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_state.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

class ListingMapBloc extends Bloc<ListingMapEvent, ListingMapState> {
  ListingMapBloc({
    required ListingMapRepository repository,
    bool favoritesOnly = false,
  }) : _repository = repository,
       _favoritesOnly = favoritesOnly,
       super(const ListingMapState()) {
    on<InitializeListingMap>(_onInitialize);
    on<ListingMapCameraSettled>(_onCameraSettled);
    on<SearchListingMapArea>(_onSearchArea);
    on<ChangeListingMapFilters>(_onChangeFilters);
    on<ChangeListingMapSearch>(_onChangeSearch);
    on<SelectListingMapItem>(_onSelectListing);
    on<RetryListingMap>(_onRetry);
    on<RunProgrammaticListingMapLoad>(_onRunProgrammaticLoad);
    on<RunDebouncedListingMapSearch>(_onRunDebouncedSearch);
  }

  static const programmaticSettleDelay = Duration(milliseconds: 350);
  static const searchDebounceDelay = Duration(milliseconds: 500);

  final ListingMapRepository _repository;
  final bool _favoritesOnly;
  CancelToken? _cancelToken;
  Timer? _programmaticSettleTimer;
  Timer? _searchDebounceTimer;
  int _programmaticSettleGeneration = 0;
  int _searchGeneration = 0;
  int _requestGeneration = 0;

  @override
  Future<void> close() {
    _programmaticSettleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _programmaticSettleGeneration++;
    _searchGeneration++;
    _cancelActiveRequest('Listing map closed.');
    return super.close();
  }

  void _onInitialize(
    InitializeListingMap event,
    Emitter<ListingMapState> emit,
  ) {
    final seeds = event.seedListings
        .where((item) => item.mapLat != null && item.mapLon != null)
        .toList(growable: false);
    emit(
      state.copyWith(
        initialFilters: event.filters,
        filters: event.filters,
        items: seeds,
        count: seeds.length,
        clearSelectedListingId: true,
        clearErrorMessage: true,
      ),
    );
  }

  void _onCameraSettled(
    ListingMapCameraSettled event,
    Emitter<ListingMapState> emit,
  ) {
    final isGesture = event.reason == PropertyMapCameraMoveReason.gesture;
    if (isGesture) {
      _programmaticSettleTimer?.cancel();
      _searchDebounceTimer?.cancel();
      _programmaticSettleGeneration++;
      _searchGeneration++;
      _cancelActiveRequest('Camera moved by the user.');
      emit(
        state.copyWith(
          currentBounds: event.bounds,
          showSearchThisArea: true,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
      return;
    }
    emit(state.copyWith(currentBounds: event.bounds));
    _programmaticSettleTimer?.cancel();
    final generation = ++_programmaticSettleGeneration;
    _programmaticSettleTimer = Timer(programmaticSettleDelay, () {
      if (!isClosed) add(RunProgrammaticListingMapLoad(generation));
    });
  }

  Future<void> _onSearchArea(
    SearchListingMapArea event,
    Emitter<ListingMapState> emit,
  ) {
    _programmaticSettleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _programmaticSettleGeneration++;
    _searchGeneration++;
    return _loadCurrentBounds(emit);
  }

  Future<void> _onChangeFilters(
    ChangeListingMapFilters event,
    Emitter<ListingMapState> emit,
  ) async {
    if (event.filters == state.filters) return;
    _programmaticSettleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _programmaticSettleGeneration++;
    _searchGeneration++;
    emit(
      state.copyWith(
        filters: event.filters,
        showSearchThisArea: false,
        clearSelectedListingId: true,
      ),
    );
    await _loadCurrentBounds(emit);
  }

  Future<void> _onChangeSearch(
    ChangeListingMapSearch event,
    Emitter<ListingMapState> emit,
  ) async {
    final query = event.query.trim();
    final filters = query.isEmpty
        ? state.filters.copyWith(clearQuery: true)
        : state.filters.copyWith(query: query);
    if (filters == state.filters) return;
    _programmaticSettleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _programmaticSettleGeneration++;
    final generation = ++_searchGeneration;
    _cancelActiveRequest('Search input changed.');
    emit(
      state.copyWith(
        filters: filters,
        isLoading: false,
        showSearchThisArea: false,
        clearSelectedListingId: true,
        clearErrorMessage: true,
      ),
    );
    if (query.isEmpty) {
      await _loadCurrentBounds(emit);
      return;
    }
    _searchDebounceTimer = Timer(searchDebounceDelay, () {
      if (!isClosed) add(RunDebouncedListingMapSearch(generation));
    });
  }

  void _onSelectListing(
    SelectListingMapItem event,
    Emitter<ListingMapState> emit,
  ) {
    if (event.listingId == null) {
      emit(state.copyWith(clearSelectedListingId: true));
      return;
    }
    if (!state.items.any((item) => item.id == event.listingId)) return;
    emit(state.copyWith(selectedListingId: event.listingId));
  }

  Future<void> _onRetry(RetryListingMap event, Emitter<ListingMapState> emit) {
    _programmaticSettleTimer?.cancel();
    _searchDebounceTimer?.cancel();
    _programmaticSettleGeneration++;
    _searchGeneration++;
    return _loadCurrentBounds(emit);
  }

  Future<void> _onRunProgrammaticLoad(
    RunProgrammaticListingMapLoad event,
    Emitter<ListingMapState> emit,
  ) {
    if (event.generation != _programmaticSettleGeneration) {
      return Future.value();
    }
    return _loadCurrentBounds(emit);
  }

  Future<void> _onRunDebouncedSearch(
    RunDebouncedListingMapSearch event,
    Emitter<ListingMapState> emit,
  ) {
    if (event.generation != _searchGeneration) return Future.value();
    return _loadCurrentBounds(emit);
  }

  Future<void> _loadCurrentBounds(Emitter<ListingMapState> emit) async {
    final bounds = state.currentBounds;
    if (bounds == null) return;

    _cancelActiveRequest('Superseded by a newer listing map request.');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final generation = ++_requestGeneration;
    final filters = state.filters;
    emit(
      state.copyWith(
        isLoading: true,
        showSearchThisArea: false,
        clearErrorMessage: true,
      ),
    );

    try {
      final result = await _repository.getListings(
        bounds: bounds,
        filters: filters,
        cancelToken: cancelToken,
        favoritesOnly: _favoritesOnly,
      );
      if (isClosed || generation != _requestGeneration) return;
      if (identical(_cancelToken, cancelToken)) _cancelToken = null;
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            hasLoadedBounds: true,
            errorMessage: failure.errorMessage,
          ),
        ),
        (response) {
          final selectedStillVisible = response.items.any(
            (item) => item.id == state.selectedListingId,
          );
          emit(
            state.copyWith(
              items: response.items,
              count: response.count,
              truncated: response.truncated,
              isLoading: false,
              hasLoadedBounds: true,
              showSearchThisArea: false,
              clearSelectedListingId: !selectedStillVisible,
              clearErrorMessage: true,
            ),
          );
        },
      );
    } on DioException catch (error) {
      if (identical(_cancelToken, cancelToken)) _cancelToken = null;
      if (!CancelToken.isCancel(error) && generation == _requestGeneration) {
        emit(state.copyWith(isLoading: false, errorMessage: error.message));
      }
    }
  }

  void _cancelActiveRequest(String reason) {
    _requestGeneration++;
    _cancelToken?.cancel(reason);
    _cancelToken = null;
  }
}
