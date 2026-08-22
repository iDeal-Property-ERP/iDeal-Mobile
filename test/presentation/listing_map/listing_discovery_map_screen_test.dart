import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_bloc.dart';
import 'package:ideal_mobile/presentation/listing_map/bloc/listing_map_event.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/entities/listing_map_result.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/listing_map/listing_discovery_map_screen.dart';
import 'package:ideal_mobile/presentation/listing_map/widgets/listing_map_preview_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_location_service.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements ListingMapRepository {}

class _MockLocationService extends Mock implements PropertyMapLocationService {}

class _RecordingMapControllerDelegate implements PropertyMapControllerDelegate {
  CameraTarget? lastTarget;

  @override
  Future<void> moveCamera(CameraTarget target) async {
    lastTarget = target;
  }

  @override
  Future<void> fitBounds(
    PropertyMapBounds bounds, {
    double padding = 48,
  }) async {}

  @override
  Future<PropertyMapBounds?> getVisibleBounds() async => null;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      PropertyMapBounds(
        southWest: const PropertyMapCoordinate(latitude: 41.2, longitude: 69.1),
        northEast: const PropertyMapCoordinate(latitude: 41.5, longitude: 69.4),
      ),
    );
    registerFallbackValue(const ListingFilters.empty());
    registerFallbackValue(CancelToken());
  });

  testWidgets('wraps quick filters and shows a safe-spaced selected preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
    addTearDown(tester.view.reset);
    final repository = _MockRepository();
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right(ListingMapResult(items: [], count: 0, truncated: false)),
    );
    final bloc = ListingMapBloc(repository: repository);
    addTearDown(bloc.close);
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
      ],
    );

    await tester.pumpWidget(
      _app(
        ListingDiscoveryMapScreen(
          bloc: bloc,
          providerSelector: selector,
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) {
                return ColoredBox(
                  color: context.currentTheme.bgNeutralLight100,
                  child: Center(
                    child: TextButton(
                      key: const ValueKey('fake_map_marker'),
                      onPressed: () => configuration.onMarkerTap?.call(
                        configuration.markers.single.id,
                      ),
                      child: const Text('Select marker'),
                    ),
                  ),
                );
              },
          seedListings: [_listing],
          filterOptions: const ListingFilterOptions(
            districts: [ListingDistrict(id: 1, name: 'Yunusobod')],
            propertyTypes: [
              ListingChoice(value: 'apartment', label: 'Apartment'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('District'), findsOneWidget);
    expect(find.text('Property type'), findsOneWidget);
    expect(find.text('Price range'), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);

    final overlayActions = tester.widgetList<AppTopBarAction>(
      find.byType(AppTopBarAction),
    );
    expect(overlayActions, hasLength(2));
    expect(
      overlayActions.every(
        (action) => action.style == AppTopBarActionStyle.surface,
      ),
      isTrue,
    );
    expect(
      tester.getSize(
        find.byTooltip(
          MaterialLocalizations.of(
            tester.element(find.byType(ListingDiscoveryMapScreen)),
          ).backButtonTooltip,
        ),
      ),
      const Size(44, 44),
    );
    final backAction = find.byTooltip(
      MaterialLocalizations.of(
        tester.element(find.byType(ListingDiscoveryMapScreen)),
      ).backButtonTooltip,
    );
    expect(tester.getTopLeft(backAction).dy, greaterThanOrEqualTo(24 + 12));
    expect(
      tester.getBottomRight(backAction).dy,
      lessThanOrEqualTo(24 + 12 + 44),
    );

    await tester.tap(find.byTooltip('Full filters'));
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('fake_map_marker')));
    await tester.pumpAndSettle();

    final preview = find.byKey(const ValueKey('listing_map_previews'));
    expect(preview, findsOneWidget);
    expect(tester.getTopLeft(preview).dx, 16);
    expect(tester.getSize(preview).width, 328);
    expect(find.text(r'$500'), findsOneWidget);
    expect(find.text('Full info'), findsNothing);
    expect(find.text('Call'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('listing_map_near_me_button')),
      findsNothing,
    );
  });

  testWidgets('preview card opens detail and keeps its call action', (
    tester,
  ) async {
    var calls = 0;
    var opened = 0;
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: ListingMapPreviewCard(
            listing: _listing,
            propertyTypeLabel: 'Apartment',
            onCall: () => calls++,
            onTap: () => opened++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ListingMapPreviewCard));
    await tester.tap(find.text('Call'));
    expect(opened, 1);
    expect(calls, 1);

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: ListingMapPreviewCard(
            listing: _listingWithoutPhone,
            propertyTypeLabel: 'House',
            onTap: () {},
          ),
        ),
      ),
    );
    expect(find.text('Call'), findsNothing);
    expect(find.text('Full info'), findsNothing);
    expect(find.text('900 UZS'), findsOneWidget);
  });

  testWidgets(
    'near me recenters the map through the provider-neutral controller',
    (tester) async {
      final repository = _MockRepository();
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          ListingMapResult(items: [], count: 0, truncated: false),
        ),
      );
      final locationService = _MockLocationService();
      when(() => locationService.getCurrentLocation()).thenAnswer(
        (_) async =>
            const PropertyMapCoordinate(latitude: 41.34, longitude: 69.28),
      );
      final controllerDelegate = _RecordingMapControllerDelegate();
      final bloc = ListingMapBloc(repository: repository);
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _app(
          ListingDiscoveryMapScreen(
            bloc: bloc,
            locationService: locationService,
            providerSelector: _availableSelector,
            providerViewBuilder:
                (context, provider, configuration, onReady, onFailed) {
                  configuration.controller?.attach(controllerDelegate);
                  onReady(provider);
                  return const SizedBox.expand();
                },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('listing_map_near_me_button')),
      );
      await tester.pumpAndSettle();

      verify(() => locationService.getCurrentLocation()).called(1);
      expect(
        controllerDelegate.lastTarget,
        const CameraTarget(latitude: 41.34, longitude: 69.28, zoom: 14),
      );
    },
  );

  testWidgets('pager syncs first non-zero selection and same-id reorder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _MockRepository();
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => const Right(
        ListingMapResult(
          items: [_secondListing, _listing],
          count: 2,
          truncated: false,
        ),
      ),
    );
    final bloc = ListingMapBloc(repository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _app(
        ListingDiscoveryMapScreen(
          bloc: bloc,
          providerSelector: _availableSelector,
          providerViewBuilder: _markerProviderBuilder(selectLast: true),
          seedListings: const [_listing, _secondListing],
          filterOptions: const ListingFilterOptions(
            propertyTypes: [
              ListingChoice(value: 'apartment', label: 'Apartment'),
              ListingChoice(value: 'house', label: 'House'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fake_map_marker')));
    await tester.pumpAndSettle();

    expect(_isHorizontallyVisible(tester, 2), isTrue);
    expect(find.text('900 UZS'), findsOneWidget);

    bloc.add(
      ListingMapCameraSettled(
        bounds: _testBounds,
        reason: PropertyMapCameraMoveReason.programmatic,
      ),
    );
    await tester.pump(ListingMapBloc.programmaticSettleDelay);
    await tester.pumpAndSettle();

    expect(bloc.state.items.map((item) => item.id), [2, 1]);
    expect(bloc.state.selectedListingId, 2);
    expect(_isHorizontallyVisible(tester, 2), isTrue);
  });

  for (final scenario in const [
    (locale: Locale('ru'), width: 320.0),
    (locale: Locale('uz'), width: 360.0),
  ]) {
    testWidgets('async notices follow wrapped toolbar at '
        '${scenario.width} ${scenario.locale.languageCode}', (tester) async {
      tester.view.physicalSize = Size(scenario.width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repository = _MockRepository();
      final loading = Completer<ListingMapResult>();
      var calls = 0;
      when(
        () => repository.getListings(
          bounds: any(named: 'bounds'),
          filters: any(named: 'filters'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) return Right(await loading.future);
        return const Left(APIFailure(message: 'offline', statusCode: 503));
      });
      final bloc = ListingMapBloc(repository: repository);
      addTearDown(bloc.close);

      await tester.pumpWidget(
        _app(
          ListingDiscoveryMapScreen(
            bloc: bloc,
            providerSelector: _availableSelector,
            providerViewBuilder: _markerProviderBuilder(),
            seedListings: const [_listing],
            filterOptions: const ListingFilterOptions(
              districts: [ListingDistrict(id: 1, name: 'Очень длинный район')],
              propertyTypes: [
                ListingChoice(
                  value: 'apartment',
                  label: 'Очень длинный тип жилья',
                ),
              ],
            ),
          ),
          locale: scenario.locale,
        ),
      );
      await tester.pumpAndSettle();

      bloc.add(
        ListingMapCameraSettled(
          bounds: _testBounds,
          reason: PropertyMapCameraMoveReason.gesture,
        ),
      );
      await _pumpBloc(tester);
      _expectBelowToolbar(
        tester,
        find.byKey(const ValueKey('listing_map_search_area')),
      );

      bloc.add(const SearchListingMapArea());
      await _pumpBloc(tester);
      _expectBelowToolbar(
        tester,
        find.byKey(const ValueKey('listing_map_loading_notice')),
      );

      loading.complete(
        const ListingMapResult(items: [_listing], count: 501, truncated: true),
      );
      await tester.pumpAndSettle();
      _expectBelowToolbar(
        tester,
        find.byKey(const ValueKey('listing_map_truncated_notice')),
      );

      bloc.add(const RetryListingMap());
      await tester.pumpAndSettle();
      _expectBelowToolbar(
        tester,
        find.byKey(const ValueKey('listing_map_error_notice')),
      );
      expect(bloc.state.items, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows empty, provider-unavailable, and call-failure feedback', (
    tester,
  ) async {
    final repository = _MockRepository();
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Right(ListingMapResult(items: [], count: 0, truncated: false)),
    );
    final bloc = ListingMapBloc(repository: repository);
    addTearDown(bloc.close);
    final unavailable = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => false,
        ),
      ],
    );

    await tester.pumpWidget(
      _app(
        ListingDiscoveryMapScreen(
          bloc: bloc,
          providerSelector: unavailable,
          seedListings: const [_listing],
          uriLauncher: (_) async => false,
          filterOptions: const ListingFilterOptions(
            propertyTypes: [
              ListingChoice(value: 'apartment', label: 'Localized apartment'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Map unavailable'), findsOneWidget);

    bloc.add(
      ListingMapCameraSettled(
        bounds: _testBounds,
        reason: PropertyMapCameraMoveReason.gesture,
      ),
    );
    await _pumpBloc(tester);
    bloc.add(const SearchListingMapArea());
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('listing_map_empty_notice')),
      findsOneWidget,
    );

    bloc.add(
      const InitializeListingMap(
        filters: ListingFilters.empty(),
        seedListings: [_listing],
      ),
    );
    await tester.pump();
    bloc.add(const SelectListingMapItem(1));
    await tester.pumpAndSettle();
    expect(find.textContaining('Localized apartment'), findsOneWidget);
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Couldn't start the call. Check your phone settings and try again.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('returns current bloc filters even before the next rebuild', (
    tester,
  ) async {
    final repository = _MockRepository();
    final bloc = ListingMapBloc(repository: repository);
    addTearDown(bloc.close);
    ListingFilters? returned;
    await tester.pumpWidget(
      _app(
        ListingDiscoveryMapScreen(
          bloc: bloc,
          providerSelector: _availableSelector,
          providerViewBuilder: _markerProviderBuilder(),
          seedListings: const [_listing],
          onFiltersChanged: (filters) => returned = filters,
        ),
      ),
    );
    await tester.pumpAndSettle();

    bloc.add(
      const ChangeListingMapFilters(ListingFilters(propertyType: 'apartment')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pumpWidget(_app(const SizedBox.shrink()));

    expect(returned, const ListingFilters(propertyType: 'apartment'));
  });

  testWidgets('animates smoothly between non-adjacent listing selections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _MockRepository();
    const listing3 = ListingCard(
      id: 3,
      propertyId: 4,
      title: 'Listing 3',
      district: null,
      address: 'Address 3',
      propertyType: 'apartment',
      rooms: 1,
      areaSqm: 45,
      floor: 1,
      totalFloors: 5,
      furnishing: 'unfurnished',
      price: 300,
      currency: 'USD',
      tariff: 'standard',
      isVerified: false,
      isFeatured: false,
      score: 7,
      reviewCount: 0,
      coverImageUrl: null,
      mapLat: 41.33,
      mapLon: 69.29,
    );
    when(
      () => repository.getListings(
        bounds: any(named: 'bounds'),
        filters: any(named: 'filters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => const Right(
        ListingMapResult(
          items: [_listing, _secondListing, listing3],
          count: 3,
          truncated: false,
        ),
      ),
    );
    final bloc = ListingMapBloc(repository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _app(
        ListingDiscoveryMapScreen(
          bloc: bloc,
          providerSelector: _availableSelector,
          providerViewBuilder: _markerProviderBuilder(),
          seedListings: const [_listing, _secondListing, listing3],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select listing 1
    bloc.add(const SelectListingMapItem(1));
    await tester.pumpAndSettle();
    expect(_isHorizontallyVisible(tester, 1), isTrue);

    // Select distant listing 3 (skipping listing 2)
    bloc.add(const SelectListingMapItem(3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    await tester.pumpAndSettle();
    expect(_isHorizontallyVisible(tester, 3), isTrue);
  });
}

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

final _availableSelector = PropertyMapProviderSelector(
  candidates: [
    PropertyMapProviderCandidate(
      provider: PropertyMapProvider.yandex,
      probe: () async => true,
    ),
  ],
);

PropertyMapProviderViewBuilder _markerProviderBuilder({
  bool selectLast = false,
}) {
  return (context, provider, configuration, onReady, onFailed) {
    return ColoredBox(
      color: context.currentTheme.bgNeutralLight100,
      child: Center(
        child: TextButton(
          key: const ValueKey('fake_map_marker'),
          onPressed: () {
            final marker = selectLast
                ? configuration.markers.last
                : configuration.markers.first;
            configuration.onMarkerTap?.call(marker.id);
          },
          child: const Text('Select marker'),
        ),
      ),
    );
  };
}

bool _isHorizontallyVisible(WidgetTester tester, int listingId) {
  final rect = tester.getRect(
    find.byKey(ValueKey('listing_map_preview_$listingId')),
  );
  return rect.left >= 0 && rect.right <= tester.view.physicalSize.width;
}

void _expectBelowToolbar(WidgetTester tester, Finder notice) {
  final toolbar = tester.getRect(
    find.byKey(const ValueKey('listing_map_toolbar')),
  );
  final status = tester.getRect(notice);
  expect(status.top, greaterThanOrEqualTo(toolbar.bottom + 8));
}

Future<void> _pumpBloc(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

final _testBounds = PropertyMapBounds(
  southWest: const PropertyMapCoordinate(latitude: 41.2, longitude: 69.1),
  northEast: const PropertyMapCoordinate(latitude: 41.5, longitude: 69.4),
);

const _listing = ListingCard(
  id: 1,
  propertyId: 2,
  title: 'Yunusobod apartment',
  district: 'Yunusobod',
  address: 'Tashkent, Amir Temur 1',
  propertyType: 'apartment',
  rooms: 2,
  areaSqm: 60,
  floor: 3,
  totalFloors: 9,
  furnishing: 'furnished',
  price: 500,
  currency: 'USD',
  tariff: 'comfort',
  isVerified: true,
  isFeatured: false,
  score: 9,
  reviewCount: 2,
  coverImageUrl: null,
  mapLat: 41.31,
  mapLon: 69.28,
  contactPhone: '+998712000000',
);

const _listingWithoutPhone = ListingCard(
  id: 2,
  propertyId: 3,
  title: 'House',
  district: null,
  address: 'Tashkent',
  propertyType: 'house',
  rooms: 3,
  areaSqm: 120,
  floor: null,
  totalFloors: null,
  furnishing: 'furnished',
  price: 900,
  currency: 'UZS',
  tariff: 'premium',
  isVerified: true,
  isFeatured: true,
  score: 8,
  reviewCount: 1,
  coverImageUrl: null,
  mapLat: 41.32,
  mapLon: 69.29,
);

const _secondListing = ListingCard(
  id: 2,
  propertyId: 3,
  title: 'House',
  district: null,
  address: 'Tashkent',
  propertyType: 'house',
  rooms: 3,
  areaSqm: 120,
  floor: null,
  totalFloors: null,
  furnishing: 'furnished',
  price: 900,
  currency: 'UZS',
  tariff: 'premium',
  isVerified: true,
  isFeatured: true,
  score: 8,
  reviewCount: 1,
  coverImageUrl: null,
  mapLat: 41.32,
  mapLon: 69.29,
  contactPhone: '+998712000001',
);
