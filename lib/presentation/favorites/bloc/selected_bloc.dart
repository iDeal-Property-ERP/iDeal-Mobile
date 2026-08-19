import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/get_favorites.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';

class SelectedBloc extends Bloc<SelectedEvent, SelectedState> {
  SelectedBloc({
    GetFavorites? getFavorites,
    SetListingFavorite? setListingFavorite,
    GetListingFilterOptions? getFilterOptions,
    FavoritesSyncService? favoritesSyncService,
    LegacyFavoritesCleanupService? legacyFavoritesCleanupService,
  }) : _getFavorites = getFavorites ?? sl<GetFavorites>(),
       _setListingFavorite = setListingFavorite ?? sl<SetListingFavorite>(),
       _getFilterOptions = getFilterOptions ?? sl<GetListingFilterOptions>(),
       _favoritesSyncService =
           favoritesSyncService ?? sl<FavoritesSyncService>(),
       _legacyFavoritesCleanupService =
           legacyFavoritesCleanupService ?? sl<LegacyFavoritesCleanupService>(),
       super(SelectedState.initial()) {
    on<LoadSelectedEvent>(_onLoadSelectedEvent);
    on<LoadMoreSelectedEvent>(_onLoadMoreSelectedEvent);
    on<SearchSelectedEvent>(_onSearchSelectedEvent);
    on<_DebouncedSearchSelectedEvent>(_onDebouncedSearchSelectedEvent);
    on<ApplySelectedFiltersEvent>(_onApplySelectedFiltersEvent);
    on<ClearSelectedFiltersEvent>(_onClearSelectedFiltersEvent);
    on<ChangeSelectedSortEvent>(_onChangeSelectedSortEvent);
    on<LoadSelectedFilterOptionsEvent>(_onLoadSelectedFilterOptionsEvent);
    on<ToggleSelectedFavoriteEvent>(_onToggleSelectedFavoriteEvent);
    on<RestoreSelectedFavoriteEvent>(_onRestoreSelectedFavoriteEvent);
    on<ClearSelectedFeedbackEvent>(_onClearSelectedFeedbackEvent);
    on<ClearSelectedLoadErrorEvent>(_onClearSelectedLoadErrorEvent);
    on<SyncSelectedFavoriteEvent>(_onSyncSelectedFavoriteEvent);

    _favoriteSyncSubscription = _favoritesSyncService.stream.listen((change) {
      add(
        SyncSelectedFavoriteEvent(
          listingId: change.listingId,
          isFavorite: change.isFavorite,
        ),
      );
    });

    unawaited(_legacyFavoritesCleanupService.clearLegacyFavoritesOnce());
  }

  final GetFavorites _getFavorites;
  final SetListingFavorite _setListingFavorite;
  final GetListingFilterOptions _getFilterOptions;
  final FavoritesSyncService _favoritesSyncService;
  final LegacyFavoritesCleanupService _legacyFavoritesCleanupService;
  Timer? _searchDebounce;
  StreamSubscription<FavoriteStatusChange>? _favoriteSyncSubscription;
  int _refreshGeneration = 0;
  int _requestGeneration = 0;
  bool _filterOptionsLoaded = false;
  final Map<int, _SelectedFavoriteMutation> _favoriteMutations = {};
  final Map<int, bool> _favoriteStatusOverrides = {};
  final Map<int, Future<void>> _favoriteMutationTails = {};
  int _favoriteMutationVersion = 0;

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    await _favoriteSyncSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadSelectedEvent(
    LoadSelectedEvent event,
    Emitter<SelectedState> emit,
  ) async {
    _searchDebounce?.cancel();
    if (!_filterOptionsLoaded) {
      add(const LoadSelectedFilterOptionsEvent());
    }
    await _loadSelected(
      filters: state.filters,
      sort: state.sort,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onLoadMoreSelectedEvent(
    LoadMoreSelectedEvent event,
    Emitter<SelectedState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.isLoading) return;

    await _loadSelected(
      filters: state.filters,
      sort: state.sort,
      page: state.page + 1,
      replaceItems: false,
      emit: emit,
    );
  }

  void _onSearchSelectedEvent(
    SearchSelectedEvent event,
    Emitter<SelectedState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(_DebouncedSearchSelectedEvent(event.query));
    });
  }

  Future<void> _onDebouncedSearchSelectedEvent(
    _DebouncedSearchSelectedEvent event,
    Emitter<SelectedState> emit,
  ) async {
    final query = event.query.trim();
    final filters = query.isEmpty
        ? state.filters.copyWith(clearQuery: true)
        : state.filters.copyWith(query: query);
    await _loadSelected(
      filters: filters,
      sort: state.sort,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onApplySelectedFiltersEvent(
    ApplySelectedFiltersEvent event,
    Emitter<SelectedState> emit,
  ) async {
    _searchDebounce?.cancel();
    await _loadSelected(
      filters: event.filters,
      sort: state.sort,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onClearSelectedFiltersEvent(
    ClearSelectedFiltersEvent event,
    Emitter<SelectedState> emit,
  ) async {
    _searchDebounce?.cancel();
    await _loadSelected(
      filters: const ListingFilters.empty(),
      sort: state.sort,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onChangeSelectedSortEvent(
    ChangeSelectedSortEvent event,
    Emitter<SelectedState> emit,
  ) async {
    _searchDebounce?.cancel();
    await _loadSelected(
      filters: state.filters,
      sort: event.sort,
      page: 1,
      replaceItems: true,
      emit: emit,
    );
  }

  Future<void> _onLoadSelectedFilterOptionsEvent(
    LoadSelectedFilterOptionsEvent event,
    Emitter<SelectedState> emit,
  ) async {
    if (_filterOptionsLoaded) return;

    final result = await _getFilterOptions();
    result.fold((_) {}, (options) {
      _filterOptionsLoaded = true;
      emit(SelectedLoadedState(state.copyWith(filterOptions: options)));
    });
  }

  Future<void> _onToggleSelectedFavoriteEvent(
    ToggleSelectedFavoriteEvent event,
    Emitter<SelectedState> emit,
  ) async {
    final originalItem = _itemForId(state.items, event.listingId);
    if (originalItem == null) return;

    final originalIndex = state.items.indexOf(originalItem);
    final nextIsFavorite = !originalItem.isFavorite;
    final mutation = _SelectedFavoriteMutation(
      version: ++_favoriteMutationVersion,
      isFavorite: nextIsFavorite,
      originalItem: originalItem,
      originalIndex: originalIndex,
    );
    _favoriteMutations[event.listingId] = mutation;
    _favoriteStatusOverrides[event.listingId] = nextIsFavorite;

    if (!nextIsFavorite) {
      emit(
        SelectedLoadedState(
          state.copyWith(
            items: _removeById(state.items, event.listingId),
            count: state.count > 0 ? state.count - 1 : 0,
            removedListing: SelectedUndoInfo(
              listingId: event.listingId,
              item: originalItem,
              index: originalIndex,
            ),
            clearFavoriteMutationErrorMessage: true,
          ),
        ),
      );
    }

    await _enqueueFavoriteMutation(
      listingId: event.listingId,
      mutation: mutation,
      emit: emit,
    );
  }

  Future<void> _onRestoreSelectedFavoriteEvent(
    RestoreSelectedFavoriteEvent event,
    Emitter<SelectedState> emit,
  ) async {
    final undoInfo = state.removedListing;
    if (undoInfo == null || undoInfo.listingId != event.listingId) return;
    if (_itemForId(state.items, event.listingId) != null) {
      emit(SelectedLoadedState(state.copyWith(clearRemovedListing: true)));
      return;
    }

    final mutation = _SelectedFavoriteMutation(
      version: ++_favoriteMutationVersion,
      isFavorite: true,
      originalItem: undoInfo.item,
      originalIndex: undoInfo.index,
    );
    _favoriteMutations[event.listingId] = mutation;
    _favoriteStatusOverrides[event.listingId] = true;
    emit(
      SelectedLoadedState(
        state.copyWith(
          items: _insertAtIndex(
            state.items,
            undoInfo.index,
            undoInfo.item.copyWith(isFavorite: true),
          ),
          count: state.count + 1,
          clearRemovedListing: true,
          clearFavoriteMutationErrorMessage: true,
        ),
      ),
    );

    await _enqueueFavoriteMutation(
      listingId: event.listingId,
      mutation: mutation,
      emit: emit,
    );
  }

  Future<void> _enqueueFavoriteMutation({
    required int listingId,
    required _SelectedFavoriteMutation mutation,
    required Emitter<SelectedState> emit,
  }) async {
    final previousMutation =
        _favoriteMutationTails[listingId] ?? Future<void>.value();
    final operation = previousMutation.then<void>(
      (_) => _completeSelectedFavoriteMutation(
        listingId: listingId,
        mutation: mutation,
        emit: emit,
      ),
    );
    _favoriteMutationTails[listingId] = operation;

    try {
      await operation;
    } finally {
      if (identical(_favoriteMutationTails[listingId], operation)) {
        unawaited(_favoriteMutationTails.remove(listingId));
      }
    }
  }

  Future<void> _completeSelectedFavoriteMutation({
    required int listingId,
    required _SelectedFavoriteMutation mutation,
    required Emitter<SelectedState> emit,
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
        if (mutation.isFavorite) {
          _favoriteStatusOverrides[listingId] = false;
          final currentItems = state.items;
          final wasVisible = _itemForId(currentItems, listingId) != null;
          emit(
            SelectedLoadedState(
              state.copyWith(
                items: _removeById(currentItems, listingId),
                count: wasVisible
                    ? (state.count > 0 ? state.count - 1 : 0)
                    : state.count,
                removedListing: SelectedUndoInfo(
                  listingId: listingId,
                  item: mutation.originalItem,
                  index: mutation.originalIndex,
                ),
                favoriteMutationErrorMessage: selectedMutationErrorKey,
              ),
            ),
          );
        } else {
          _favoriteStatusOverrides[listingId] = true;
          final currentItems = state.items;
          final alreadyVisible = _itemForId(currentItems, listingId) != null;
          emit(
            SelectedLoadedState(
              state.copyWith(
                items: _restoreById(
                  currentItems,
                  listingId,
                  mutation.originalItem,
                ),
                count: alreadyVisible ? state.count : state.count + 1,
                clearRemovedListing: true,
                favoriteMutationErrorMessage: selectedMutationErrorKey,
              ),
            ),
          );
        }
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

  void _onClearSelectedFeedbackEvent(
    ClearSelectedFeedbackEvent event,
    Emitter<SelectedState> emit,
  ) {
    if (state.favoriteMutationErrorMessage == null) return;
    emit(
      SelectedLoadedState(
        state.copyWith(clearFavoriteMutationErrorMessage: true),
      ),
    );
  }

  void _onClearSelectedLoadErrorEvent(
    ClearSelectedLoadErrorEvent event,
    Emitter<SelectedState> emit,
  ) {
    if (state.errorMessage == null) return;
    emit(
      SelectedLoadedState(
        state.copyWith(clearErrorMessage: true, clearFailedPage: true),
      ),
    );
  }

  void _onSyncSelectedFavoriteEvent(
    SyncSelectedFavoriteEvent event,
    Emitter<SelectedState> emit,
  ) {
    if (_favoriteMutations[event.listingId] == null) {
      _favoriteStatusOverrides[event.listingId] = event.isFavorite;
    } else {
      return;
    }

    if (event.isFavorite) return;

    if (_itemForId(state.items, event.listingId) == null) return;

    emit(
      SelectedLoadedState(
        state.copyWith(
          items: _removeById(state.items, event.listingId),
          count: state.count > 0 ? state.count - 1 : 0,
        ),
      ),
    );
  }

  Future<void> _loadSelected({
    required ListingFilters filters,
    required SelectedSort sort,
    required int page,
    required bool replaceItems,
    required Emitter<SelectedState> emit,
  }) async {
    final refreshGeneration = replaceItems
        ? ++_refreshGeneration
        : _refreshGeneration;
    final requestGeneration = ++_requestGeneration;
    final existingItems = state.items;
    if (replaceItems) {
      emit(
        SelectedLoadingState(
          state.copyWith(
            filters: filters,
            sort: sort,
            page: 1,
            hasReachedMax: false,
            isLoading: true,
            isLoadingMore: false,
            clearErrorMessage: true,
            clearFailedPage: true,
            clearFavoriteMutationErrorMessage: true,
            clearRemovedListing: true,
          ),
        ),
      );
    } else {
      emit(
        SelectedLoadingMoreState(
          state.copyWith(
            isLoadingMore: true,
            clearErrorMessage: true,
            clearFailedPage: true,
          ),
        ),
      );
    }

    // Defaults are omitted so default requests stay identical to the
    // unfiltered ones.
    final effectiveFilters = filters.isEmpty ? null : filters;
    final effectiveSort = sort == SelectedSort.recent ? null : sort;
    final result = await _getFavorites(
      GetFavoritesParams(
        page: page,
        filters: effectiveFilters,
        sort: effectiveSort,
      ),
    );
    if (!_isCurrentRequest(requestGeneration, refreshGeneration)) return;

    result.fold(
      (failure) {
        _emitLoadFailure(
          emit,
          selectedLoadErrorKey,
          items: replaceItems ? null : existingItems,
          failedPage: replaceItems ? null : page,
        );
      },
      (response) {
        if (response.pageNumber != page) {
          _emitLoadFailure(
            emit,
            selectedPageOutOfDateErrorKey,
            items: replaceItems ? null : existingItems,
            failedPage: replaceItems ? null : page,
          );
          return;
        }
        emit(
          SelectedLoadedState(
            state.copyWith(
              items: replaceItems
                  ? _applyPendingFavoriteMutations(response.items)
                  : _appendPendingFavoriteMutations(
                      existingItems,
                      response.items,
                    ),
              filters: filters,
              sort: sort,
              page: response.pageNumber,
              numPages: response.numPages,
              count: _countWithPendingMutations(response.count),
              hasReachedMax: response.pageNumber >= response.numPages,
              isLoading: false,
              isLoadingMore: false,
              hasLoaded: true,
              clearErrorMessage: true,
              clearFailedPage: true,
            ),
          ),
        );
      },
    );
  }

  void _emitLoadFailure(
    Emitter<SelectedState> emit,
    String errorMessage, {
    List<ListingCard>? items,
    int? failedPage,
  }) {
    final preservedItems = items ?? state.items;
    final nextState = state.copyWith(
      items: preservedItems,
      isLoading: false,
      isLoadingMore: false,
      errorMessage: errorMessage,
      failedPage: failedPage,
    );
    if (preservedItems.isEmpty) {
      emit(SelectedErrorState(nextState, errorMessage: errorMessage));
      return;
    }
    emit(SelectedLoadedState(nextState));
  }

  bool _isCurrentRequest(int requestGeneration, int refreshGeneration) {
    return requestGeneration == _requestGeneration &&
        refreshGeneration == _refreshGeneration;
  }

  bool _isCurrentFavoriteMutation(
    int listingId,
    _SelectedFavoriteMutation mutation,
  ) {
    return identical(_favoriteMutations[listingId], mutation) &&
        _favoriteMutations[listingId]?.version == mutation.version;
  }

  List<ListingCard> _applyPendingFavoriteMutations(List<ListingCard> items) {
    final seenIds = <int>{};
    return [
      for (final item in items)
        if (seenIds.add(item.id) &&
            (_favoriteMutations[item.id]?.isFavorite ??
                _favoriteStatusOverrides[item.id] ??
                true))
          item.copyWith(
            isFavorite:
                _favoriteMutations[item.id]?.isFavorite ??
                _favoriteStatusOverrides[item.id] ??
                item.isFavorite,
          ),
    ];
  }

  List<ListingCard> _appendPendingFavoriteMutations(
    List<ListingCard> existingItems,
    List<ListingCard> nextItems,
  ) {
    final merged = [
      ..._applyPendingFavoriteMutations(existingItems),
      ..._applyPendingFavoriteMutations(nextItems),
    ];
    return _dedupeListings(merged);
  }

  List<ListingCard> _dedupeListings(List<ListingCard> items) {
    final seenIds = <int>{};
    return [
      for (final item in items)
        if (seenIds.add(item.id)) item,
    ];
  }

  int _countWithPendingMutations(int count) {
    var adjusted = count;
    for (final mutation in _favoriteMutations.values) {
      adjusted += mutation.isFavorite ? 1 : -1;
    }
    return adjusted < 0 ? 0 : adjusted;
  }
}

class _SelectedFavoriteMutation {
  const _SelectedFavoriteMutation({
    required this.version,
    required this.isFavorite,
    required this.originalItem,
    required this.originalIndex,
  });

  final int version;
  final bool isFavorite;
  final ListingCard originalItem;
  final int originalIndex;
}

class _DebouncedSearchSelectedEvent extends SelectedEvent {
  const _DebouncedSearchSelectedEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

ListingCard? _itemForId(List<ListingCard> items, int listingId) {
  for (final item in items) {
    if (item.id == listingId) return item;
  }
  return null;
}

List<ListingCard> _removeById(List<ListingCard> items, int listingId) {
  return [
    for (final item in items)
      if (item.id != listingId) item,
  ];
}

List<ListingCard> _insertAtIndex(
  List<ListingCard> items,
  int index,
  ListingCard item,
) {
  if (items.isEmpty) return [item];
  final result = [...items];
  result.insert(index.clamp(0, result.length), item);
  return result;
}

List<ListingCard> _restoreById(
  List<ListingCard> items,
  int listingId,
  ListingCard originalItem,
) {
  if (_itemForId(items, listingId) != null) {
    return [
      for (final item in items)
        item.id == listingId ? item.copyWith(isFavorite: true) : item,
    ];
  }
  return [...items, originalItem.copyWith(isFavorite: true)];
}
