import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/get_favorites.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetFavorites extends Mock implements GetFavorites {}

class MockSetListingFavorite extends Mock implements SetListingFavorite {}

class MockGetListingFilterOptions extends Mock
    implements GetListingFilterOptions {}

class MockLegacyFavoritesCleanupService extends Mock
    implements LegacyFavoritesCleanupService {}

void main() {
  late SelectedBloc selectedBloc;
  late MockGetFavorites getFavorites;
  late MockSetListingFavorite setListingFavorite;
  late MockGetListingFilterOptions getFilterOptions;
  late FavoritesSyncService favoritesSyncService;
  late MockLegacyFavoritesCleanupService legacyFavoritesCleanupService;

  ListingCard listing(int id, {bool isFavorite = true}) => ListingCard(
    id: id,
    propertyId: id + 100,
    title: 'Listing $id',
    district: 'Yunusobod',
    address: 'Address $id',
    propertyType: 'apartment',
    rooms: 2,
    areaSqm: 68,
    floor: 4,
    totalFloors: 9,
    furnishing: 'furnished',
    price: 520,
    currency: 'USD',
    tariff: 'comfort',
    isVerified: true,
    isFeatured: false,
    score: 9.2,
    reviewCount: 14,
    coverImageUrl: null,
    mapLat: null,
    mapLon: null,
    isFavorite: isFavorite,
  );

  setUpAll(() {
    registerFallbackValue(const GetFavoritesParams(page: 1));
    registerFallbackValue(
      const SetListingFavoriteParams(listingId: 1, isFavorite: false),
    );
  });

  setUp(() {
    getFavorites = MockGetFavorites();
    setListingFavorite = MockSetListingFavorite();
    getFilterOptions = MockGetListingFilterOptions();
    favoritesSyncService = FavoritesSyncService();
    legacyFavoritesCleanupService = MockLegacyFavoritesCleanupService();
    when(
      () => legacyFavoritesCleanupService.clearLegacyFavoritesOnce(),
    ).thenAnswer((_) async {});
    // Options load silently by default so existing emission sequences are
    // unaffected; dedicated tests override this with a success.
    when(() => getFilterOptions()).thenAnswer(
      (_) async => const Left(
        APIFailure(message: 'Options unavailable', statusCode: 500),
      ),
    );

    selectedBloc = SelectedBloc(
      getFavorites: getFavorites,
      setListingFavorite: setListingFavorite,
      getFilterOptions: getFilterOptions,
      favoritesSyncService: favoritesSyncService,
      legacyFavoritesCleanupService: legacyFavoritesCleanupService,
    );
  });

  tearDown(() async {
    await selectedBloc.close();
  });

  blocTest<SelectedBloc, SelectedState>(
    'loads selected listings',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(1)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    act: (bloc) => bloc.add(const LoadSelectedEvent(refresh: true)),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>()
          .having((state) => state.items.single.id, 'item', 1)
          .having((state) => state.hasReachedMax, 'max', isTrue),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'dedupes duplicate ids while preserving backend order on refresh',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(4), listing(4), listing(3)],
            count: 3,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    act: (bloc) => bloc.add(const LoadSelectedEvent(refresh: true)),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.items.map((item) => item.id).toList(),
        'items',
        [4, 3],
      ),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'keeps existing order and ignores duplicate ids on load more',
    build: () {
      when(() => getFavorites(const GetFavoritesParams(page: 2))).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(2), listing(1), listing(3), listing(3)],
            count: 4,
            numPages: 2,
            perPage: 20,
            pageNumber: 2,
          ),
        ),
      );
      return selectedBloc;
    },
    seed: () => SelectedState.test(
      items: [listing(1), listing(2)],
      page: 1,
      numPages: 2,
      count: 4,
      hasLoaded: true,
    ),
    act: (bloc) => bloc.add(const LoadMoreSelectedEvent()),
    expect: () => [
      isA<SelectedLoadingMoreState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.items.map((item) => item.id).toList(),
        'items',
        [1, 2, 3],
      ),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'surfaces refresh failures without dropping visible selected cards',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async =>
            const Left(APIFailure(message: 'Refresh failed', statusCode: 500)),
      );
      return selectedBloc;
    },
    seed: () =>
        SelectedState.test(items: [listing(1)], count: 1, hasLoaded: true),
    act: (bloc) => bloc.add(const LoadSelectedEvent(refresh: true)),
    expect: () => [
      isA<SelectedLoadingState>().having(
        (state) => state.items.map((item) => item.id).toList(),
        'items during refresh',
        [1],
      ),
      isA<SelectedLoadedState>()
          .having(
            (state) => state.items.map((item) => item.id).toList(),
            'preserved items',
            [1],
          )
          .having(
            (state) => state.errorMessage,
            'error message',
            selectedLoadErrorKey,
          ),
    ],
  );

  test(
    'ignores stale load-more completion after a refresh replaces the list',
    () async {
      final loadMoreCompleter = Completer<Either<Failure, ListingsPage>>();
      final refreshCompleter = Completer<Either<Failure, ListingsPage>>();
      when(
        () => getFavorites(const GetFavoritesParams(page: 2)),
      ).thenAnswer((_) => loadMoreCompleter.future);
      when(
        () => getFavorites(const GetFavoritesParams(page: 1)),
      ).thenAnswer((_) => refreshCompleter.future);

      selectedBloc.emit(
        SelectedState.test(
          items: [listing(1)],
          page: 1,
          numPages: 2,
          count: 2,
          hasLoaded: true,
        ),
      );
      selectedBloc.add(const LoadMoreSelectedEvent());
      await Future<void>.delayed(Duration.zero);
      selectedBloc.add(const LoadSelectedEvent(refresh: true));
      await Future<void>.delayed(Duration.zero);

      refreshCompleter.complete(
        Right(
          ListingsPage(
            items: [listing(9)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      loadMoreCompleter.complete(
        Right(
          ListingsPage(
            items: [listing(2)],
            count: 2,
            numPages: 2,
            perPage: 20,
            pageNumber: 2,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [9]);
      expect(selectedBloc.state.page, 1);
    },
  );

  test(
    'rejects an out-of-order page response without corrupting the list',
    () async {
      when(() => getFavorites(const GetFavoritesParams(page: 2))).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(9)],
            count: 3,
            numPages: 3,
            perPage: 20,
            pageNumber: 3,
          ),
        ),
      );

      selectedBloc.emit(
        SelectedState.test(
          items: [listing(1)],
          page: 1,
          numPages: 3,
          count: 3,
          hasLoaded: true,
        ),
      );
      selectedBloc.add(const LoadMoreSelectedEvent());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [1]);
      expect(selectedBloc.state.page, 1);
      expect(selectedBloc.state.failedPage, 2);
      expect(selectedBloc.state.errorMessage, selectedPageOutOfDateErrorKey);
    },
  );

  test('rolls back by listing id after Selected changes in flight', () async {
    final completer = Completer<Either<Failure, void>>();
    when(() => setListingFavorite(any())).thenAnswer((_) => completer.future);

    selectedBloc.emit(
      SelectedState.test(items: [listing(1), listing(2)], count: 2),
    );
    selectedBloc.add(const ToggleSelectedFavoriteEvent(1));
    await Future<void>.delayed(Duration.zero);

    selectedBloc.emit(
      SelectedState.test(items: [listing(2), listing(1)], count: 2),
    );
    completer.complete(
      const Left(APIFailure(message: 'Could not remove', statusCode: 400)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(selectedBloc.state.items.map((item) => item.id).toList(), [2, 1]);
    expect(selectedBloc.state.items.last.isFavorite, isTrue);
    expect(
      selectedBloc.state.favoriteMutationErrorMessage,
      selectedMutationErrorKey,
    );
  });

  test(
    'does not re-add a pending unlike when a refresh returns the old card',
    () async {
      final mutationCompleter = Completer<Either<Failure, void>>();
      final refreshCompleter = Completer<Either<Failure, ListingsPage>>();
      when(
        () => setListingFavorite(any()),
      ).thenAnswer((_) => mutationCompleter.future);
      when(
        () => getFavorites(const GetFavoritesParams(page: 1)),
      ).thenAnswer((_) => refreshCompleter.future);

      selectedBloc.emit(
        SelectedState.test(items: [listing(1), listing(2)], count: 2),
      );
      selectedBloc.add(const ToggleSelectedFavoriteEvent(1));
      await Future<void>.delayed(Duration.zero);
      selectedBloc.add(const LoadSelectedEvent(refresh: true));
      await Future<void>.delayed(Duration.zero);

      refreshCompleter.complete(
        Right(
          ListingsPage(
            items: [listing(1), listing(2)],
            count: 2,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [2]);
      mutationCompleter.complete(
        const Left(APIFailure(message: 'Could not remove', statusCode: 400)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [2, 1]);
      expect(
        selectedBloc.state.items.where((item) => item.id == 1),
        hasLength(1),
      );
      expect(selectedBloc.state.count, 2);
    },
  );

  test(
    'does not resurrect a completed unlike from a stale page response',
    () async {
      final mutationCompleter = Completer<Either<Failure, void>>();
      final pageCompleter = Completer<Either<Failure, ListingsPage>>();
      when(
        () => setListingFavorite(any()),
      ).thenAnswer((_) => mutationCompleter.future);
      when(
        () => getFavorites(const GetFavoritesParams(page: 2)),
      ).thenAnswer((_) => pageCompleter.future);

      selectedBloc.emit(
        SelectedState.test(
          items: [listing(1)],
          page: 1,
          numPages: 2,
          count: 2,
          hasLoaded: true,
        ),
      );
      selectedBloc.add(const LoadMoreSelectedEvent());
      await Future<void>.delayed(Duration.zero);
      selectedBloc.add(const ToggleSelectedFavoriteEvent(1));
      await Future<void>.delayed(Duration.zero);

      mutationCompleter.complete(const Right(null));
      await Future<void>.delayed(Duration.zero);
      pageCompleter.complete(
        Right(
          ListingsPage(
            items: [listing(2)],
            count: 1,
            numPages: 2,
            perPage: 1,
            pageNumber: 2,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [2]);
    },
  );

  test('repeated Selected toggles do not duplicate the rollback', () async {
    final completer = Completer<Either<Failure, void>>();
    when(() => setListingFavorite(any())).thenAnswer((_) => completer.future);

    selectedBloc.emit(SelectedState.test(items: [listing(1)], count: 1));
    selectedBloc
      ..add(const ToggleSelectedFavoriteEvent(1))
      ..add(const ToggleSelectedFavoriteEvent(1));
    await Future<void>.delayed(Duration.zero);
    completer.complete(
      const Left(APIFailure(message: 'Could not remove', statusCode: 400)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(selectedBloc.state.items.map((item) => item.id).toList(), [1]);
    verify(
      () => setListingFavorite(
        const SetListingFavoriteParams(listingId: 1, isFavorite: false),
      ),
    ).called(1);
  });

  blocTest<SelectedBloc, SelectedState>(
    'removes silently missing cards after refresh replaces selected data',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(2)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    seed: () => SelectedState.test(
      items: [listing(1), listing(2)],
      count: 2,
      numPages: 1,
      hasLoaded: true,
    ),
    act: (bloc) => bloc.add(const LoadSelectedEvent(refresh: true)),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.items.map((item) => item.id).toList(),
        'items',
        [2],
      ),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'removes a listing immediately when unlike succeeds',
    build: () {
      when(
        () => setListingFavorite(any()),
      ).thenAnswer((_) async => const Right(null));
      return selectedBloc;
    },
    seed: () =>
        SelectedState.test(items: [listing(1)], count: 1, hasLoaded: true),
    act: (bloc) => bloc.add(const ToggleSelectedFavoriteEvent(1)),
    expect: () => [
      isA<SelectedLoadedState>()
          .having((state) => state.items, 'items', isEmpty)
          .having((state) => state.count, 'count', 0),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'rolls back a removed listing when unlike fails',
    build: () {
      when(() => setListingFavorite(any())).thenAnswer(
        (_) async => const Left(
          APIFailure(message: 'Could not remove', statusCode: 400),
        ),
      );
      return selectedBloc;
    },
    seed: () =>
        SelectedState.test(items: [listing(1)], count: 1, hasLoaded: true),
    act: (bloc) => bloc.add(const ToggleSelectedFavoriteEvent(1)),
    expect: () => [
      isA<SelectedLoadedState>()
          .having((state) => state.items, 'items', isEmpty)
          .having((state) => state.count, 'count', 0),
      isA<SelectedLoadedState>()
          .having((state) => state.items.single.id, 'item', 1)
          .having((state) => state.count, 'count', 1)
          .having(
            (state) => state.favoriteMutationErrorMessage,
            'error',
            selectedMutationErrorKey,
          ),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'loads filter options after the first load',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(1)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      when(() => getFilterOptions()).thenAnswer(
        (_) async => const Right(
          ListingFilterOptions(
            districts: [ListingDistrict(id: 1, name: 'Yunusobod')],
          ),
        ),
      );
      return selectedBloc;
    },
    act: (bloc) => bloc.add(const LoadSelectedEvent(refresh: true)),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.filterOptions.districts,
        'districts',
        hasLength(1),
      ),
    ],
  );

  blocTest<SelectedBloc, SelectedState>(
    'reloads from the first page with the applied filters',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(5)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    seed: () => SelectedState.test(
      items: [listing(1)],
      page: 3,
      numPages: 3,
      count: 30,
      hasLoaded: true,
    ),
    act: (bloc) => bloc.add(
      const ApplySelectedFiltersEvent(ListingFilters(districtId: 3)),
    ),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>()
          .having((state) => state.filters.districtId, 'district', 3)
          .having((state) => state.page, 'page', 1)
          .having((state) => state.items.single.id, 'item', 5),
    ],
    verify: (_) {
      verify(
        () => getFavorites(
          const GetFavoritesParams(
            page: 1,
            filters: ListingFilters(districtId: 3),
          ),
        ),
      ).called(1);
    },
  );

  blocTest<SelectedBloc, SelectedState>(
    'clearing filters reloads the unfiltered list',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(1)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    seed: () => SelectedState.test(
      items: [listing(2)],
      count: 1,
      hasLoaded: true,
      filters: const ListingFilters(districtId: 3, query: 'loft'),
    ),
    act: (bloc) => bloc.add(const ClearSelectedFiltersEvent()),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.filters.isEmpty,
        'filters empty',
        isTrue,
      ),
    ],
    verify: (_) {
      verify(() => getFavorites(const GetFavoritesParams(page: 1))).called(1);
    },
  );

  blocTest<SelectedBloc, SelectedState>(
    'changing sort reloads with the new ordering',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(1)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    act: (bloc) =>
        bloc.add(const ChangeSelectedSortEvent(SelectedSort.priceDesc)),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.sort,
        'sort',
        SelectedSort.priceDesc,
      ),
    ],
    verify: (_) {
      verify(
        () => getFavorites(
          const GetFavoritesParams(page: 1, sort: SelectedSort.priceDesc),
        ),
      ).called(1);
    },
  );

  blocTest<SelectedBloc, SelectedState>(
    'debounces search and reloads with the query',
    build: () {
      when(() => getFavorites(any())).thenAnswer(
        (_) async => Right(
          ListingsPage(
            items: [listing(1)],
            count: 1,
            numPages: 1,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return selectedBloc;
    },
    act: (bloc) => bloc.add(const SearchSelectedEvent('loft')),
    wait: const Duration(milliseconds: 600),
    expect: () => [
      isA<SelectedLoadingState>(),
      isA<SelectedLoadedState>().having(
        (state) => state.filters.query,
        'query',
        'loft',
      ),
    ],
    verify: (_) {
      verify(
        () => getFavorites(
          const GetFavoritesParams(
            page: 1,
            filters: ListingFilters(query: 'loft'),
          ),
        ),
      ).called(1);
    },
  );

  test(
    'undo restores the removed listing at its index and re-favorites it',
    () async {
      final syncChanges = <FavoriteStatusChange>[];
      final subscription = favoritesSyncService.stream.listen(syncChanges.add);
      when(
        () => setListingFavorite(any()),
      ).thenAnswer((_) async => const Right(null));

      selectedBloc.emit(
        SelectedState.test(
          items: [listing(1), listing(2), listing(3)],
          count: 3,
          hasLoaded: true,
        ),
      );
      selectedBloc.add(const ToggleSelectedFavoriteEvent(2));
      await Future<void>.delayed(Duration.zero);

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [1, 3]);
      expect(selectedBloc.state.removedListing?.listingId, 2);
      expect(selectedBloc.state.removedListing?.index, 1);

      selectedBloc.add(const RestoreSelectedFavoriteEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(selectedBloc.state.items.map((item) => item.id).toList(), [
        1,
        2,
        3,
      ]);
      expect(selectedBloc.state.count, 3);
      expect(selectedBloc.state.removedListing, isNull);
      verify(
        () => setListingFavorite(
          const SetListingFavoriteParams(listingId: 2, isFavorite: true),
        ),
      ).called(1);
      expect(
        syncChanges.map((change) => '${change.listingId}:${change.isFavorite}'),
        ['2:false', '2:true'],
      );
      await subscription.cancel();
    },
  );

  test('a failed undo removes the listing again and re-offers undo', () async {
    final unlikeCompleter = Completer<Either<Failure, void>>();
    final restoreCompleter = Completer<Either<Failure, void>>();
    final answers = [unlikeCompleter.future, restoreCompleter.future];
    var call = 0;
    when(() => setListingFavorite(any())).thenAnswer((_) => answers[call++]);

    selectedBloc.emit(
      SelectedState.test(
        items: [listing(1), listing(2)],
        count: 2,
        hasLoaded: true,
      ),
    );
    selectedBloc.add(const ToggleSelectedFavoriteEvent(2));
    await Future<void>.delayed(Duration.zero);
    unlikeCompleter.complete(const Right(null));
    await Future<void>.delayed(Duration.zero);

    selectedBloc.add(const RestoreSelectedFavoriteEvent(2));
    await Future<void>.delayed(Duration.zero);
    expect(selectedBloc.state.items.map((item) => item.id).toList(), [1, 2]);

    restoreCompleter.complete(
      const Left(APIFailure(message: 'Could not restore', statusCode: 400)),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(selectedBloc.state.items.map((item) => item.id).toList(), [1]);
    expect(selectedBloc.state.count, 1);
    expect(selectedBloc.state.removedListing?.listingId, 2);
    expect(
      selectedBloc.state.favoriteMutationErrorMessage,
      selectedMutationErrorKey,
    );
  });
}
