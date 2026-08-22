import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_quick_filter_sheet.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

import '../../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testDistricts = [
    ListingDistrict(id: 1, name: 'Chilanzar'),
    ListingDistrict(id: 2, name: 'Yunusobod'),
    ListingDistrict(id: 3, name: 'Mirzo Ulugbek'),
  ];

  const testTariffs = [
    ListingChoice(value: 'standard', label: 'Standard'),
    ListingChoice(value: 'comfort', label: 'Comfort'),
    ListingChoice(value: 'premium', label: 'Premium'),
  ];

  const testFilterOptions = ListingFilterOptions(
    districts: testDistricts,
    tariffs: testTariffs,
    priceMin: 100,
    priceMax: 3000,
    roomsMin: 1,
    roomsMax: 6,
  );

  group('HomeQuickFilterSheet - District', () {
    testWidgets('renders district choices and checkmark when selected', (
      tester,
    ) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.district,
                    filters: const ListingFilters(districtId: 2),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('District'), findsOneWidget);
      expect(find.text('Chilanzar'), findsOneWidget);
      expect(find.text('Yunusobod'), findsOneWidget);
      expect(find.text('Mirzo Ulugbek'), findsOneWidget);
      expect(find.byIcon(TablerIcons.check), findsOneWidget);

      // Select another district
      await tester.tap(find.text('Chilanzar'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.districtId, 1);
    });

    testWidgets('tapping selected district deselects it, Clear resets draft', (
      tester,
    ) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.district,
                    filters: const ListingFilters(districtId: 2),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap selected Yunusobod to deselect
      await tester.tap(find.text('Yunusobod'));
      await tester.pumpAndSettle();
      expect(find.byIcon(TablerIcons.check), findsNothing);

      // Tap Chilanzar to select
      await tester.tap(find.text('Chilanzar'));
      await tester.pumpAndSettle();
      expect(find.byIcon(TablerIcons.check), findsOneWidget);

      // Tap Clear All
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(find.byIcon(TablerIcons.check), findsNothing);

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.districtId, isNull);
    });

    testWidgets('shows empty message when no districts', (tester) async {
      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.district,
                    filters: const ListingFilters(),
                    filterOptions: const ListingFilterOptions.empty(),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No districts available'), findsOneWidget);
    });

    testWidgets('dismiss / close button pops null without mutating', (
      tester,
    ) async {
      ListingFilters? result = const ListingFilters(districtId: 2);

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.district,
                    filters: const ListingFilters(districtId: 2),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap close (X button in header)
      await tester.tap(find.byIcon(TablerIcons.x));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('HomeQuickFilterSheet - Tariff', () {
    testWidgets('renders tariffs, selection, clear, apply', (tester) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.tariff,
                    filters: const ListingFilters(
                      tariff: 'comfort',
                      districtId: 5,
                    ),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Tariff'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Comfort'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
      expect(find.byIcon(TablerIcons.check), findsOneWidget);

      // Select Premium
      await tester.tap(find.text('Premium'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.tariff, 'premium');
      // Unrelated filters preserved
      expect(result?.districtId, 5);
    });
  });

  group('HomeQuickFilterSheet - Rooms', () {
    testWidgets('selecting presets fills custom fields', (tester) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.rooms,
                    filters: const ListingFilters(),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Rooms'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2)); // preset + hint
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4+'), findsOneWidget);

      // Tap preset 2
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.roomsMin, 2);
      expect(result?.roomsMax, 2);
    });

    testWidgets('normalizes inverted room ranges on Apply', (tester) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.rooms,
                    filters: const ListingFilters(),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter min 4, max 2
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '4');
      await tester.enterText(textFields.at(1), '2');
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Swapped/normalized
      expect(result?.roomsMin, 2);
      expect(result?.roomsMax, 4);
    });

    testWidgets('tapping active preset clears it', (tester) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.rooms,
                    filters: const ListingFilters(roomsMin: 2, roomsMax: 2),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap active preset 2
      await tester.tap(find.widgetWithText(InkWell, '2'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.roomsMin, isNull);
      expect(result?.roomsMax, isNull);
    });
  });

  group('HomeQuickFilterSheet - Price', () {
    testWidgets('presets, custom range, and inverted normalization', (
      tester,
    ) async {
      ListingFilters? result;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showHomeQuickFilterSheet(
                    context,
                    kind: HomeQuickFilterKind.price,
                    filters: const ListingFilters(),
                    filterOptions: testFilterOptions,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Price'), findsOneWidget);
      expect(find.text('≤\$300'), findsOneWidget);
      expect(find.text('\$300–\$600'), findsOneWidget);
      expect(find.text('\$600–\$1000'), findsOneWidget);
      expect(find.text('\$1000+'), findsOneWidget);

      // Tap $300–$600
      await tester.tap(find.text('\$300–\$600'));
      await tester.pumpAndSettle();

      // Enter inverted custom range 1200 - 400
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '1200');
      await tester.enterText(textFields.at(1), '400');
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(result?.priceMin, 400);
      expect(result?.priceMax, 1200);
    });
  });
}
