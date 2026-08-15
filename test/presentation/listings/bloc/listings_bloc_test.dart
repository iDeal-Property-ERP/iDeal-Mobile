import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings_cached.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockGetListings extends Mock implements GetListings {}

class MockGetFilterOptions extends Mock implements GetListingFilterOptions {}

class MockGetListingsCached extends Mock implements GetListingsCached {}

class MockGetFilterOptionsCached extends Mock
    implements GetListingFilterOptionsCached {}

class MockSetListingFavorite extends Mock implements SetListingFavorite {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

class MockLegacyFavoritesCleanupService extends Mock
    implements LegacyFavoritesCleanupService {}

void main() {
  late ListingsBloc listingsBloc;
  late MockGetListings getListings;
  late MockGetFilterOptions getFilterOptions;
  late MockSetListingFavorite setListingFavorite;
  late MockPerformanceMonitoringService performanceService;
  late MockGetListingsCached getListingsCached;
  late MockGetFilterOptionsCached getFilterOptionsCached;
  late FavoritesSyncService favoritesSyncService;
  late MockLegacyFavoritesCleanupService legacyFavoritesCleanupService;

  ListingCard listing(int id, {bool isFavorite = false}) => ListingCard(
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
    registerFallbackValue(const ListingFilters.empty());
    registerFallbackValue(
      const GetListingsParams(filters: ListingFilters.empty(), page: 1),
    );
    registerFallbackValue(
      const SetListingFavoriteParams(listingId: 1, isFavorite: true),
    );
  });

  setUp(() {
    getListings = MockGetListings();
    getFilterOptions = MockGetFilterOptions();
    setListingFavorite = MockSetListingFavorite();
    performanceService = MockPerformanceMonitoringService();
    getListingsCached = MockGetListingsCached();
    getFilterOptionsCached = MockGetFilterOptionsCached();
    favoritesSyncService = FavoritesSyncService();
    legacyFavoritesCleanupService = MockLegacyFavoritesCleanupService();
    when(
      () => legacyFavoritesCleanupService.clearLegacyFavoritesOnce(),
    ).thenAnswer((_) async {});

    listingsBloc = ListingsBloc(
      getListings: getListings,
      getFilterOptions: getFilterOptions,
      setListingFavorite: setListingFavorite,
      favoritesSyncService: favoritesSyncService,
      legacyFavoritesCleanupService: legacyFavoritesCleanupService,
      performanceService: performanceService,
    );
  });

  tearDown(() async {
    await listingsBloc.close();
  });

  group('ListingsBloc', () {
    blocTest<ListingsBloc, ListingsState>(
      'emits loading then loaded on the first page',
      build: () {
        when(() => getListings(any())).thenAnswer(
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
        return listingsBloc;
      },
      act: (bloc) => bloc.add(const LoadListingsEvent()),
      expect: () => [
        isA<ListingsLoadingState>(),
        isA<ListingsLoadedState>()
            .having((state) => state.items.length, 'items', 1)
            .having((state) => state.page, 'page', 1),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'appends load-more results and increments page',
      build: () {
        when(() => getListings(any())).thenAnswer((invocation) async {
          final params =
              invocation.positionalArguments.first as GetListingsParams;
          return Right(
            ListingsPage(
              items: [listing(params.page)],
              count: 2,
              numPages: 2,
              perPage: 1,
              pageNumber: params.page,
            ),
          );
        });
        return listingsBloc;
      },
      seed: () => ListingsState.test(
        items: [listing(1)],
        page: 1,
        numPages: 2,
        count: 2,
      ),
      act: (bloc) => bloc.add(const LoadMoreListingsEvent()),
      expect: () => [
        isA<ListingsLoadingMoreState>().having(
          (state) => state.isLoadingMore,
          'loading more',
          isTrue,
        ),
        isA<ListingsLoadedState>()
            .having((state) => state.items.map((item) => item.id), 'items', [
              1,
              2,
            ])
            .having((state) => state.page, 'page', 2),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'optimistically updates favorite and keeps it on success',
      build: () {
        when(
          () => setListingFavorite(any()),
        ).thenAnswer((_) async => const Right(null));
        return listingsBloc;
      },
      seed: () => ListingsState.test(items: [listing(1)]),
      act: (bloc) => bloc.add(const ToggleFavoriteEvent(1)),
      expect: () => [
        isA<ListingsLoadedState>().having(
          (state) => state.items.single.isFavorite,
          'favorite',
          isTrue,
        ),
      ],
      verify: (_) {
        verify(
          () => setListingFavorite(
            const SetListingFavoriteParams(listingId: 1, isFavorite: true),
          ),
        ).called(1);
      },
    );

    blocTest<ListingsBloc, ListingsState>(
      'rolls back optimistic favorite update on failure',
      build: () {
        when(() => setListingFavorite(any())).thenAnswer(
          (_) async => const Left(
            APIFailure(message: 'Could not save', statusCode: 400),
          ),
        );
        return listingsBloc;
      },
      seed: () => ListingsState.test(items: [listing(1)]),
      act: (bloc) => bloc.add(const ToggleFavoriteEvent(1)),
      expect: () => [
        isA<ListingsLoadedState>().having(
          (state) => state.items.single.isFavorite,
          'favorite',
          isTrue,
        ),
        isA<ListingsLoadedState>()
            .having(
              (state) => state.items.single.isFavorite,
              'favorite',
              isFalse,
            )
            .having(
              (state) => state.favoriteMutationErrorMessage,
              'error',
              'Could not save',
            ),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'applies synced favorite updates from the shared service',
      build: () => listingsBloc,
      seed: () => ListingsState.test(items: [listing(1)]),
      act: (_) => favoritesSyncService.publish(
        const FavoriteStatusChange(listingId: 1, isFavorite: true),
      ),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<ListingsLoadedState>().having(
          (state) => state.items.single.isFavorite,
          'favorite',
          isTrue,
        ),
      ],
    );

    test('rolls back by listing id after the list changes in flight', () async {
      final completer = Completer<Either<Failure, void>>();
      when(() => setListingFavorite(any())).thenAnswer((_) => completer.future);

      listingsBloc.emit(
        ListingsState.test(items: [listing(1), listing(2)], count: 2),
      );
      listingsBloc.add(const ToggleFavoriteEvent(1));
      await Future<void>.delayed(Duration.zero);

      listingsBloc.emit(
        ListingsState.test(items: [listing(2), listing(1)], count: 2),
      );
      completer.complete(
        const Left(APIFailure(message: 'Could not save', statusCode: 400)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(listingsBloc.state.items.map((item) => item.id).toList(), [2, 1]);
      expect(listingsBloc.state.items.last.isFavorite, isFalse);
      expect(listingsBloc.state.favoriteMutationErrorMessage, 'Could not save');
    });

    test(
      'keeps an optimistic favorite across a refresh response in flight',
      () async {
        final mutationCompleter = Completer<Either<Failure, void>>();
        final refreshCompleter = Completer<Either<Failure, ListingsPage>>();
        when(
          () => setListingFavorite(any()),
        ).thenAnswer((_) => mutationCompleter.future);
        when(
          () => getListings(any()),
        ).thenAnswer((_) => refreshCompleter.future);

        listingsBloc.emit(ListingsState.test(items: [listing(1)], count: 1));
        listingsBloc.add(const ToggleFavoriteEvent(1));
        await Future<void>.delayed(Duration.zero);
        listingsBloc.add(const LoadListingsEvent());
        await Future<void>.delayed(Duration.zero);

        refreshCompleter.complete(
          Right(
            ListingsPage(
              items: [listing(3), listing(1)],
              count: 2,
              numPages: 1,
              perPage: 20,
              pageNumber: 1,
            ),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        expect(listingsBloc.state.items.first.id, 3);
        expect(listingsBloc.state.items.last.isFavorite, isTrue);

        mutationCompleter.complete(
          const Left(APIFailure(message: 'Could not save', statusCode: 400)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(listingsBloc.state.items.map((item) => item.id).toList(), [
          3,
          1,
        ]);
        expect(listingsBloc.state.items.last.isFavorite, isFalse);
      },
    );

    test(
      'keeps a completed unlike from being overwritten by a stale page',
      () async {
        final mutationCompleter = Completer<Either<Failure, void>>();
        final pageCompleter = Completer<Either<Failure, ListingsPage>>();
        when(
          () => setListingFavorite(any()),
        ).thenAnswer((_) => mutationCompleter.future);
        when(() => getListings(any())).thenAnswer((_) => pageCompleter.future);

        listingsBloc.emit(
          ListingsState.test(
            items: [listing(1, isFavorite: true)],
            page: 1,
            numPages: 2,
            count: 2,
          ),
        );
        listingsBloc.add(const LoadMoreListingsEvent());
        await Future<void>.delayed(Duration.zero);
        listingsBloc.add(const ToggleFavoriteEvent(1));
        await Future<void>.delayed(Duration.zero);

        mutationCompleter.complete(const Right(null));
        await Future<void>.delayed(Duration.zero);
        pageCompleter.complete(
          Right(
            ListingsPage(
              items: [listing(2)],
              count: 2,
              numPages: 2,
              perPage: 1,
              pageNumber: 2,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(listingsBloc.state.items.map((item) => item.id).toList(), [
          1,
          2,
        ]);
        expect(listingsBloc.state.items.first.isFavorite, isFalse);
      },
    );

    test('ignores an older concurrent toggle completion', () async {
      final first = Completer<Either<Failure, void>>();
      final second = Completer<Either<Failure, void>>();
      when(
        () => setListingFavorite(
          const SetListingFavoriteParams(listingId: 1, isFavorite: true),
        ),
      ).thenAnswer((_) => first.future);
      when(
        () => setListingFavorite(
          const SetListingFavoriteParams(listingId: 1, isFavorite: false),
        ),
      ).thenAnswer((_) => second.future);

      listingsBloc.emit(ListingsState.test(items: [listing(1)]));
      listingsBloc
        ..add(const ToggleFavoriteEvent(1))
        ..add(const ToggleFavoriteEvent(1));
      await Future<void>.delayed(Duration.zero);

      expect(listingsBloc.state.items.single.isFavorite, isFalse);
      verify(
        () => setListingFavorite(
          const SetListingFavoriteParams(listingId: 1, isFavorite: true),
        ),
      ).called(1);

      first.complete(
        const Left(APIFailure(message: 'First failed', statusCode: 400)),
      );
      await Future<void>.delayed(Duration.zero);
      expect(listingsBloc.state.items.single.isFavorite, isFalse);
      verify(
        () => setListingFavorite(
          const SetListingFavoriteParams(listingId: 1, isFavorite: false),
        ),
      ).called(1);

      second.complete(const Right(null));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(listingsBloc.state.items.single.isFavorite, isFalse);
    });

    blocTest<ListingsBloc, ListingsState>(
      'renders cache then fresh and retains cached data after refresh failure',
      build: () {
        final page = ListingsPage(
          items: [listing(7)],
          count: 1,
          numPages: 1,
          perPage: 20,
          pageNumber: 1,
        );
        when(
          () => getListingsCached(filters: any(named: 'filters'), page: 1),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            Right<Failure, PublicCacheResult<ListingsPage>>(
              PublicCacheResult(data: page, origin: PublicDataOrigin.cache),
            ),
            Right<Failure, PublicCacheResult<ListingsPage>>(
              PublicCacheResult(data: page, origin: PublicDataOrigin.fresh),
            ),
            Right<Failure, PublicCacheResult<ListingsPage>>(
              PublicCacheResult(
                data: page,
                origin: PublicDataOrigin.cache,
                isStale: true,
                refreshError: StateError('offline'),
              ),
            ),
          ]),
        );
        return ListingsBloc(
          getListings: getListings,
          getFilterOptions: getFilterOptions,
          getListingsCached: getListingsCached,
          setListingFavorite: setListingFavorite,
          favoritesSyncService: favoritesSyncService,
          legacyFavoritesCleanupService: legacyFavoritesCleanupService,
          performanceService: performanceService,
        );
      },
      act: (bloc) => bloc.add(const LoadListingsEvent()),
      expect: () => [
        isA<ListingsLoadingState>(),
        isA<ListingsLoadedState>()
            .having(
              (state) => state.dataOrigin,
              'origin',
              PublicDataOrigin.cache,
            )
            .having((state) => state.isStale, 'stale', isFalse),
        isA<ListingsLoadedState>().having(
          (state) => state.dataOrigin,
          'origin',
          PublicDataOrigin.fresh,
        ),
        isA<ListingsLoadedState>()
            .having((state) => state.items.single.id, 'cached item', 7)
            .having((state) => state.isStale, 'stale', isTrue)
            .having(
              (state) => state.listingRefreshError,
              'retry message',
              contains('offline'),
            ),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'cached filter refresh preserves stale listing retry signal',
      build: () {
        when(() => getFilterOptionsCached()).thenAnswer(
          (_) => Stream.value(
            const Right<Failure, PublicCacheResult<ListingFilterOptions>>(
              PublicCacheResult<ListingFilterOptions>(
                data: ListingFilterOptions.empty(),
                origin: PublicDataOrigin.fresh,
              ),
            ),
          ),
        );
        return ListingsBloc(
          getListings: getListings,
          getFilterOptions: getFilterOptions,
          getFilterOptionsCached: getFilterOptionsCached,
          setListingFavorite: setListingFavorite,
          favoritesSyncService: favoritesSyncService,
          legacyFavoritesCleanupService: legacyFavoritesCleanupService,
          performanceService: performanceService,
        );
      },
      seed: () => ListingsState.test(
        items: [listing(1)],
        dataOrigin: PublicDataOrigin.cache,
        isStale: true,
        listingRefreshError: 'offline',
      ),
      act: (bloc) => bloc.add(const LoadFilterOptionsEvent()),
      expect: () => [
        isA<ListingFilterOptionsLoadedState>()
            .having(
              (state) => state.dataOrigin,
              'listing origin',
              PublicDataOrigin.cache,
            )
            .having((state) => state.isStale, 'listing stale', isTrue)
            .having(
              (state) => state.listingRefreshError,
              'listing retry',
              'offline',
            ),
      ],
    );
  });
}
