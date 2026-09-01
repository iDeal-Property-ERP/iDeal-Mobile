import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_date_filter_button.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_screen_body.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

class MockNotificationBadgeCubit extends MockCubit<int>
    implements NotificationBadgeCubit {}

ListingCard _testListing(int id) => ListingCard(
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notificationBadgeCubit = MockNotificationBadgeCubit();
  when(() => notificationBadgeCubit.state).thenReturn(0);
  sl.allowReassignment = true;
  if (sl.isRegistered<NotificationBadgeCubit>()) {
    sl.unregister<NotificationBadgeCubit>();
  }
  sl.registerSingleton<NotificationBadgeCubit>(notificationBadgeCubit);

  group('Home date filter button', () {
    testWidgets('renders beside the all-filters button', (tester) async {
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          items: [_testListing(1)],
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const Scaffold(body: HomeScreenBody()),
      );

      expect(find.byType(HomeDateFilterButton), findsOneWidget);
      expect(find.text('All filters'), findsOneWidget);
    });

    testWidgets('reflects the active state when a date range is selected', (
      tester,
    ) async {
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          filters: ListingFilters(
            startDate: DateTime(2026, 9),
            endDate: DateTime(2026, 9, 10),
          ),
          items: [_testListing(1)],
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const Scaffold(body: HomeScreenBody()),
      );

      final button = tester.widget<HomeDateFilterButton>(
        find.byType(HomeDateFilterButton),
      );
      expect(button.isActive, isTrue);
    });

    testWidgets('opens the date-filter sheet on tap', (tester) async {
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          items: [_testListing(1)],
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const Scaffold(body: HomeScreenBody()),
      );

      await tester.tap(find.byType(HomeDateFilterButton));
      await tester.pumpAndSettle();

      expect(find.byKey(keys.dateFilter.sheet), findsOneWidget);
      expect(find.text('Availability dates'), findsOneWidget);
    });

    testWidgets('narrow layout renders the button without overflow', (
      tester,
    ) async {
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          filters: const ListingFilters(
            districtId: 1,
            roomsMin: 10,
            roomsMax: 20,
            priceMin: 5000,
            priceMax: 10000,
            tariff: 'extremely_long_tariff_name',
          ),
          items: [_testListing(1)],
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const SizedBox(
          width: 320,
          height: 600,
          child: Scaffold(body: HomeScreenBody()),
        ),
      );

      expect(find.byType(HomeDateFilterButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
