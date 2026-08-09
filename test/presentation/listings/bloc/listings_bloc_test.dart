import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/services/favorites_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetListings extends Mock implements GetListings {}

class MockGetFilterOptions extends Mock implements GetListingFilterOptions {}

class MockFavoritesService extends Mock implements FavoritesService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late ListingsBloc listingsBloc;
  late MockGetListings getListings;
  late MockGetFilterOptions getFilterOptions;
  late MockFavoritesService favoritesService;
  late MockPerformanceMonitoringService performanceService;

  ListingCard listing(int id) => ListingCard(
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
  );

  setUpAll(() {
    // mocktail needs a fallback instance for non-primitive types used with any().
    registerFallbackValue(const ListingFilters.empty());
    registerFallbackValue(
      const GetListingsParams(filters: ListingFilters.empty(), page: 1),
    );
  });

  setUp(() {
    getListings = MockGetListings();
    getFilterOptions = MockGetFilterOptions();
    favoritesService = MockFavoritesService();
    performanceService = MockPerformanceMonitoringService();

    final serviceLocator = GetIt.instance;
    if (serviceLocator.isRegistered<PerformanceMonitoringService>()) {
      serviceLocator.unregister<PerformanceMonitoringService>();
    }
    serviceLocator.registerSingleton<PerformanceMonitoringService>(
      performanceService,
    );

    listingsBloc = ListingsBloc(
      getListings: getListings,
      getFilterOptions: getFilterOptions,
      favoritesService: favoritesService,
    );
  });

  tearDown(() async {
    await listingsBloc.close();
    final serviceLocator = GetIt.instance;
    if (serviceLocator.isRegistered<PerformanceMonitoringService>()) {
      serviceLocator.unregister<PerformanceMonitoringService>();
    }
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
      'marks the state as reached max on the last page',
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
        isA<ListingsLoadedState>().having(
          (state) => state.hasReachedMax,
          'reached max',
          isTrue,
        ),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'does not request another page after reaching max',
      build: () => listingsBloc,
      seed: () => ListingsState.test(hasReachedMax: true, page: 1, numPages: 1),
      act: (bloc) => bloc.add(const LoadMoreListingsEvent()),
      expect: () => <ListingsState>[],
      verify: (_) {
        verifyNever(() => getListings(any()));
      },
    );

    blocTest<ListingsBloc, ListingsState>(
      'applying filters resets page and replaces items',
      build: () {
        when(() => getListings(any())).thenAnswer(
          (_) async => Right(
            ListingsPage(
              items: [listing(9)],
              count: 1,
              numPages: 1,
              perPage: 20,
              pageNumber: 1,
            ),
          ),
        );
        return listingsBloc;
      },
      seed: () => ListingsState.test(
        items: [listing(1), listing(2)],
        page: 2,
        numPages: 2,
        count: 4,
      ),
      act: (bloc) => bloc.add(
        const ApplyListingFiltersEvent(
          ListingFilters(districtId: 1, priceMax: 1000),
        ),
      ),
      expect: () => [
        isA<ListingsLoadingState>().having((state) => state.page, 'page', 1),
        isA<ListingsLoadedState>()
            .having((state) => state.items.map((item) => item.id), 'items', [9])
            .having((state) => state.page, 'page', 1)
            .having((state) => state.filters.districtId, 'district', 1),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'emits an error while retaining items when load more fails',
      build: () {
        when(() => getListings(any())).thenAnswer(
          (_) async =>
              const Left(APIFailure(message: 'Server error', statusCode: 500)),
        );
        return listingsBloc;
      },
      seed: () => ListingsState.test(items: [listing(1)], page: 1, numPages: 2),
      act: (bloc) => bloc.add(const LoadMoreListingsEvent()),
      expect: () => [
        isA<ListingsLoadingMoreState>(),
        isA<ListingsErrorState>()
            .having((state) => state.items.map((item) => item.id), 'items', [1])
            .having((state) => state.isLoadingMore, 'loading more', isFalse)
            .having(
              (state) => state.errorMessage,
              'error',
              '500 Error: Server error',
            ),
      ],
    );
  });
}
