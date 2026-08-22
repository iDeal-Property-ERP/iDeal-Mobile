import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_recommended_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/record_search_activity.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetListings extends Mock implements GetListings {}

class MockGetFilterOptions extends Mock implements GetListingFilterOptions {}

class MockGetRecommendedListings extends Mock
    implements GetRecommendedListings {}

class MockRecordSearchActivity extends Mock implements RecordSearchActivity {}

class MockSetListingFavorite extends Mock implements SetListingFavorite {}

class MockFavoritesSyncService extends Mock implements FavoritesSyncService {}

class MockLegacyFavoritesCleanupService extends Mock
    implements LegacyFavoritesCleanupService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

class FakeGetListingsParams extends Fake implements GetListingsParams {}

class FakeRecordSearchActivityParams extends Fake
    implements RecordSearchActivityParams {}

ListingCard _testCard(int id) => ListingCard(
  id: id,
  propertyId: id + 100,
  title: 'Test listing $id',
  district: 'Yunusobod',
  address: 'Test address',
  propertyType: 'apartment',
  rooms: 2,
  areaSqm: 60,
  floor: 3,
  totalFloors: 9,
  furnishing: 'furnished',
  price: 500,
  currency: 'USD',
  tariff: 'standard',
  isVerified: true,
  isFeatured: false,
  score: 9.0,
  reviewCount: 5,
  coverImageUrl: null,
  mapLat: null,
  mapLon: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetListings mockGetListings;
  late MockGetFilterOptions mockGetFilterOptions;
  late MockGetRecommendedListings mockGetRecommendedListings;
  late MockRecordSearchActivity mockRecordSearchActivity;
  late MockSetListingFavorite mockSetListingFavorite;
  late MockFavoritesSyncService mockFavoritesSyncService;
  late MockLegacyFavoritesCleanupService mockLegacyFavoritesCleanupService;
  late MockPerformanceMonitoringService mockPerformanceMonitoringService;

  setUpAll(() {
    registerFallbackValue(FakeGetListingsParams());
    registerFallbackValue(FakeRecordSearchActivityParams());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockGetListings = MockGetListings();
    mockGetFilterOptions = MockGetFilterOptions();
    mockGetRecommendedListings = MockGetRecommendedListings();
    mockRecordSearchActivity = MockRecordSearchActivity();
    mockSetListingFavorite = MockSetListingFavorite();
    mockFavoritesSyncService = MockFavoritesSyncService();
    mockLegacyFavoritesCleanupService = MockLegacyFavoritesCleanupService();
    mockPerformanceMonitoringService = MockPerformanceMonitoringService();

    when(
      () => mockFavoritesSyncService.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockLegacyFavoritesCleanupService.clearLegacyFavoritesOnce(),
    ).thenAnswer((_) async {});
    when(
      () => mockGetFilterOptions.call(),
    ).thenAnswer((_) async => const Right(ListingFilterOptions.empty()));
  });

  ListingsBloc buildBloc() => ListingsBloc(
    getListings: mockGetListings,
    getFilterOptions: mockGetFilterOptions,
    getRecommendedListings: mockGetRecommendedListings,
    recordSearchActivity: mockRecordSearchActivity,
    setListingFavorite: mockSetListingFavorite,
    favoritesSyncService: mockFavoritesSyncService,
    legacyFavoritesCleanupService: mockLegacyFavoritesCleanupService,
    performanceService: mockPerformanceMonitoringService,
  );

  group('ListingsBloc recommendations', () {
    test(
      'guest user receives empty recommendations and does not call api',
      () async {
        final bloc = buildBloc();

        bloc.add(const LoadHomeRecommendationsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.recommendedListings, isEmpty);
        verifyNever(() => mockGetRecommendedListings.call());

        await bloc.close();
      },
    );

    test('authenticated user fetches recommendations successfully', () async {
      await Prefs.setString(
        PrefKeys.kUserDetails,
        '{"accessToken":"valid-token"}',
      );

      final cards = [_testCard(1), _testCard(2)];
      when(
        () => mockGetRecommendedListings.call(),
      ).thenAnswer((_) async => Right(cards));

      final bloc = buildBloc();
      bloc.add(const LoadHomeRecommendationsEvent());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.recommendedListings, cards);
      verify(() => mockGetRecommendedListings.call()).called(1);

      await bloc.close();
    });

    test(
      'authenticated user handles recommendation failure gracefully',
      () async {
        await Prefs.setString(
          PrefKeys.kUserDetails,
          '{"accessToken":"valid-token"}',
        );

        when(() => mockGetRecommendedListings.call()).thenAnswer(
          (_) async =>
              const Left(APIFailure(message: 'Error', statusCode: 500)),
        );

        final bloc = buildBloc();
        bloc.add(const LoadHomeRecommendationsEvent());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(bloc.state.recommendedListings, isEmpty);
        expect(bloc.state.errorMessage, isNull);

        await bloc.close();
      },
    );

    test(
      'records search activity on filter apply and refreshes recommendations',
      () async {
        await Prefs.setString(
          PrefKeys.kUserDetails,
          '{"accessToken":"valid-token"}',
        );

        when(
          () => mockRecordSearchActivity.call(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockGetRecommendedListings.call(),
        ).thenAnswer((_) async => Right([_testCard(1)]));
        when(() => mockGetListings.call(any())).thenAnswer(
          (_) async => const Right(
            ListingsPage(
              items: [],
              count: 0,
              numPages: 0,
              perPage: 20,
              pageNumber: 1,
            ),
          ),
        );

        final bloc = buildBloc();
        const filters = ListingFilters(districtId: 1);
        bloc.add(const ApplyListingFiltersEvent(filters));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        verify(() => mockRecordSearchActivity.call(any())).called(1);

        await bloc.close();
      },
    );
  });
}
