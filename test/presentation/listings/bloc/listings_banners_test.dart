import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_banner_carousel.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_home_banners.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetListings extends Mock implements GetListings {}

class MockGetFilterOptions extends Mock implements GetListingFilterOptions {}

class MockGetHomeBanners extends Mock implements GetHomeBanners {}

class MockSetListingFavorite extends Mock implements SetListingFavorite {}

class MockFavoritesSyncService extends Mock implements FavoritesSyncService {}

class MockLegacyFavoritesCleanupService extends Mock
    implements LegacyFavoritesCleanupService {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  late MockGetListings getListings;
  late MockGetFilterOptions getFilterOptions;
  late MockGetHomeBanners getHomeBanners;
  late MockSetListingFavorite setListingFavorite;
  late MockFavoritesSyncService favoritesSyncService;
  late MockLegacyFavoritesCleanupService legacyFavoritesCleanupService;
  late MockPerformanceMonitoringService performanceService;

  final testBanners = [
    const HomeBannerItem(
      id: 1,
      title: '100% Actual Listings',
      description: 'Whatever you see is available.',
      icon: TablerIcons.circle_check,
      tag: 'iDeal Guarantee',
      sortOrder: 1,
    ),
    const HomeBannerItem(
      id: 2,
      title: 'Verified Properties',
      description: 'Our team inspects each home.',
      icon: TablerIcons.shield_check,
      tag: 'iDeal Guarantee',
      sortOrder: 2,
    ),
  ];

  setUp(() {
    getListings = MockGetListings();
    getFilterOptions = MockGetFilterOptions();
    getHomeBanners = MockGetHomeBanners();
    setListingFavorite = MockSetListingFavorite();
    favoritesSyncService = MockFavoritesSyncService();
    legacyFavoritesCleanupService = MockLegacyFavoritesCleanupService();
    performanceService = MockPerformanceMonitoringService();

    when(
      () => favoritesSyncService.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => legacyFavoritesCleanupService.clearLegacyFavoritesOnce(),
    ).thenAnswer((_) async {});
    when(
      () => getFilterOptions.call(),
    ).thenAnswer((_) async => const Right(ListingFilterOptions.empty()));
  });

  ListingsBloc buildBloc() => ListingsBloc(
    getListings: getListings,
    getFilterOptions: getFilterOptions,
    getHomeBanners: getHomeBanners,
    setListingFavorite: setListingFavorite,
    favoritesSyncService: favoritesSyncService,
    legacyFavoritesCleanupService: legacyFavoritesCleanupService,
    performanceService: performanceService,
  );

  group('ListingsBloc - Home Banners', () {
    blocTest<ListingsBloc, ListingsState>(
      'LoadHomeBannersEvent updates state.banners on success',
      setUp: () {
        when(
          () => getHomeBanners.call(),
        ).thenAnswer((_) async => Right(testBanners));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadHomeBannersEvent()),
      expect: () => [
        isA<ListingsLoadedState>().having(
          (s) => s.banners,
          'banners',
          testBanners,
        ),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'LoadHomeBannersEvent keeps previous banners on failure',
      setUp: () {
        when(() => getHomeBanners.call()).thenAnswer(
          (_) async =>
              const Left(APIFailure(message: 'Network error', statusCode: 500)),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadHomeBannersEvent()),
      expect: () => [],
    );
  });
}
