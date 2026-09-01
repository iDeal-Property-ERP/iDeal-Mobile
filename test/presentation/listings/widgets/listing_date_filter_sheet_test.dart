import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_date_filter_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final start = DateTime(2026, 9);
  final end = DateTime(2026, 9, 10);

  // Captured by the button's onPressed in the test tree.
  Future<ListingFilters?>? openSheetFuture;

  Future<void> pumpApp(
    WidgetTester tester, {
    required ListingFilters initialFilters,
    required Key openButtonKey,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              key: openButtonKey,
              onPressed: () {
                openSheetFuture = showListingDateFilterSheet(
                  context,
                  initialFilters: initialFilters,
                  applyToListingsBloc: false,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('ListingDateFilterSheet', () {
    const openKey = Key('openSheetButton');

    testWidgets('opens with the title and the date field', (tester) async {
      await pumpApp(
        tester,
        initialFilters: ListingFilters(
          startDate: start,
          endDate: end,
          flexibilityDays: 5,
        ),
        openButtonKey: openKey,
      );

      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();

      expect(find.text('Availability dates'), findsOneWidget);
      expect(find.byKey(keys.dateFilter.field), findsOneWidget);
      expect(find.byKey(keys.dateFilter.sheet), findsOneWidget);
    });

    testWidgets('apply returns the seeded filters unchanged', (tester) async {
      await pumpApp(
        tester,
        initialFilters: ListingFilters(
          startDate: start,
          endDate: end,
          flexibilityDays: 7,
        ),
        openButtonKey: openKey,
      );

      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('listingDateFilterSheetApply')));
      await tester.pumpAndSettle();

      final result = await openSheetFuture;
      expect(result, isNotNull);
      expect(result?.hasDateRange, isTrue);
      expect(result?.flexibilityDays, 7);
    });

    testWidgets('clear returns filters without the date range', (tester) async {
      await pumpApp(
        tester,
        initialFilters: ListingFilters(
          startDate: start,
          endDate: end,
          flexibilityDays: 4,
        ),
        openButtonKey: openKey,
      );

      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('listingDateFilterSheetClear')));
      await tester.pumpAndSettle();

      final result = await openSheetFuture;
      expect(result, isNotNull);
      expect(result?.hasDateRange, isFalse);
      expect(result?.flexibilityDays, isNull);
    });

    testWidgets('cancel dismisses without applying', (tester) async {
      await pumpApp(
        tester,
        initialFilters: ListingFilters(
          startDate: start,
          endDate: end,
          flexibilityDays: 4,
        ),
        openButtonKey: openKey,
      );

      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(keys.dateFilter.cancel));
      await tester.pumpAndSettle();

      final result = await openSheetFuture;
      expect(result, isNull);
    });

    testWidgets('flexibility updates are applied with the range', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initialFilters: ListingFilters(
          startDate: start,
          endDate: end,
          flexibilityDays: 3,
        ),
        openButtonKey: openKey,
      );

      await tester.tap(find.byKey(openKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(keys.dateFilter.flexibilityIncrease));
      await tester.pump();
      await tester.tap(find.byKey(const Key('listingDateFilterSheetApply')));
      await tester.pumpAndSettle();

      final result = await openSheetFuture;
      expect(result, isNotNull);
      expect(result?.flexibilityDays, 4);
      expect(result?.hasDateRange, isTrue);
    });
  });
}
