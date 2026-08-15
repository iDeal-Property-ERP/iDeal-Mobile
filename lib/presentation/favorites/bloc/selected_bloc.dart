import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/get_favorites.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';

class SelectedBloc extends Bloc<SelectedEvent, SelectedState> {
  SelectedBloc({
    GetFavorites? getFavorites,
    SetListingFavorite? setListingFavorite,
    FavoritesSyncService? favoritesSyncService,
    LegacyFavoritesCleanupService? legacyFavoritesCleanupService,
  }) : _getFavorites = getFavorites ?? sl<GetFavorites>(),
       _setListingFavorite = setListingFavorite ?? sl<SetListingFavorite>(),
       _favoritesSyncService =
           favoritesSyncService ?? sl<FavoritesSyncService>(),
       _legacyFavoritesCleanupService =
           legacyFavoritesCleanupService ?? sl<LegacyFavoritesCleanupService>(),
       super(SelectedState.initial()) {
    on<LoadSelectedEvent>(_onLoadSelectedEvent);
    on<LoadMoreSelectedEvent>(_onLoadMoreSelectedEvent);
    on<ToggleSelectedFavoriteEvent>(_onToggleSelectedFavoriteEvent);
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
  final FavoritesSyncService _favoritesSyncService;
  final LegacyFavoritesCleanupService _legacyFavoritesCleanupService;
  StreamSubscription<FavoriteStatusChange>? _favoriteSyncSubscription;
  int _refreshGeneration = 0;
  int _requestGeneration = 0;
  final Map<int, _SelectedFavoriteMutation> _favoriteMutations = {};
  final Map<int, bool> _favoriteStatusOverrides = {};
  final Map<int, Future<void>> _favoriteMutationTails = {};
  int _favoriteMutationVersion = 0;

  @override
  Future<void> close() async {
    await _favoriteSyncSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadSelectedEvent(
    LoadSelectedEvent event,
    Emitter<SelectedState> emit,
  ) async {
    final refreshGeneration = ++_refreshGeneration;
    final requestGeneration = ++_requestGeneration;
    emit(
      SelectedLoadingState(
        state.copyWith(
          page: 1,
          hasReachedMax: false,
          isLoading: true,
          isLoadingMore: false,
          clearErrorMessage: true,
          clearFailedPage: true,
          clearFavoriteMutationErrorMessage: true,
        ),
      ),
    );

    final result = await _getFavorites(const GetFavoritesParams(page: 1));
    if (!_isCurrentRequest(requestGeneration, refreshGeneration)) return;

    result.fold(
      (failure) {
        _emitLoadFailure(emit, selectedLoadErrorKey);
      },
      (response) {
        if (response.pageNumber != 1) {
          _emitLoadFailure(emit, selectedPageOutOfDateErrorKey);
          return;
        }
        emit(
          SelectedLoadedState(
            state.copyWith(
              items: _applyPendingFavoriteMutations(response.items),
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

  Future<void> _onLoadMoreSelectedEvent(
    LoadMoreSelectedEvent event,
    Emitter<SelectedState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.isLoading) return;

    final refreshGeneration = _refreshGeneration;
    final requestGeneration = ++_requestGeneration;
    final existingItems = state.items;
    final nextPage = state.page + 1;
    emit(
      SelectedLoadingMoreState(
        state.copyWith(
          isLoadingMore: true,
          clearErrorMessage: true,
          clearFailedPage: true,
        ),
      ),
    );

    final result = await _getFavorites(GetFavoritesParams(page: nextPage));
    if (!_isCurrentRequest(requestGeneration, refreshGeneration)) return;

    result.fold(
      (failure) {
        _emitLoadFailure(
          emit,
          selectedLoadErrorKey,
          items: existingItems,
          failedPage: nextPage,
        );
      },
      (response) {
        if (response.pageNumber != nextPage) {
          _emitLoadFailure(
            emit,
            selectedPageOutOfDateErrorKey,
            items: existingItems,
            failedPage: nextPage,
          );
          return;
        }
        emit(
          SelectedLoadedState(
            state.copyWith(
              items: _appendPendingFavoriteMutations(
                existingItems,
                response.items,
              ),
              page: response.pageNumber,
              numPages: response.numPages,
              count: _countWithPendingMutations(response.count),
              hasReachedMax: response.pageNumber >= response.numPages,
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

  Future<void> _onToggleSelectedFavoriteEvent(
    ToggleSelectedFavoriteEvent event,
    Emitter<SelectedState> emit,
  ) async {
    final originalItem = _itemForId(state.items, event.listingId);
    if (originalItem == null) return;

    final mutation = _SelectedFavoriteMutation(
      version: ++_favoriteMutationVersion,
      originalItem: originalItem,
    );
    _favoriteMutations[event.listingId] = mutation;
    _favoriteStatusOverrides[event.listingId] = false;
    emit(
      SelectedLoadedState(
        state.copyWith(
          items: _removeById(state.items, event.listingId),
          count: state.count > 0 ? state.count - 1 : 0,
          clearFavoriteMutationErrorMessage: true,
        ),
      ),
    );

    final previousMutation =
        _favoriteMutationTails[event.listingId] ?? Future<void>.value();
    final operation = previousMutation.then<void>(
      (_) => _completeSelectedFavoriteMutation(
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

  Future<void> _completeSelectedFavoriteMutation({
    required int listingId,
    required _SelectedFavoriteMutation mutation,
    required Emitter<SelectedState> emit,
  }) async {
    final result = await _setListingFavorite(
      SetListingFavoriteParams(listingId: listingId, isFavorite: false),
    );

    if (!_isCurrentFavoriteMutation(listingId, mutation)) return;

    _favoriteMutations.remove(listingId);
    result.fold(
      (failure) {
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
              favoriteMutationErrorMessage: selectedMutationErrorKey,
            ),
          ),
        );
      },
      (_) {
        _favoriteStatusOverrides[listingId] = false;
        _favoritesSyncService.publish(
          FavoriteStatusChange(listingId: listingId, isFavorite: false),
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
    final pendingUnfavorites = _favoriteMutations.values
        .where((mutation) => !mutation.isFavorite)
        .length;
    final adjusted = count - pendingUnfavorites;
    return adjusted < 0 ? 0 : adjusted;
  }
}

class _SelectedFavoriteMutation {
  const _SelectedFavoriteMutation({
    required this.version,
    required this.originalItem,
  });

  final int version;
  final ListingCard originalItem;
  bool get isFavorite => false;
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
