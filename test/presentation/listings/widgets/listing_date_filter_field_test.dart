import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_date_filter_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpField(
    WidgetTester tester, {
    DateTime? startDate,
    DateTime? endDate,
    int initialFlexibility = kDefaultFlexibilityDays,
    void Function(DateTime?, DateTime?, int)? onChanged,
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListingDateFilterField(
            key: UniqueKey(),
            initialStartDate: startDate,
            initialEndDate: endDate,
            initialFlexibilityDays: initialFlexibility,
            onChanged: onChanged ?? (_, _, _) {},
          ),
        ),
      ),
    );
  }

  group('ListingDateFilterField', () {
    testWidgets('shows the select-dates prompt with default flexibility', (
      tester,
    ) async {
      await pumpField(tester);

      expect(find.text('Select dates'), findsOneWidget);
      expect(find.byIcon(TablerIcons.calendar), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(keys.dateFilter.flexibilityValue)).data,
        '± 3 days',
      );
    });

    testWidgets('adjusts flexibility with the stepper and clamps bounds', (
      tester,
    ) async {
      await pumpField(tester);

      await tester.tap(find.byKey(keys.dateFilter.flexibilityDecrease));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(keys.dateFilter.flexibilityValue)).data,
        '± 2 days',
      );

      await tester.tap(find.byKey(keys.dateFilter.flexibilityIncrease));
      await tester.tap(find.byKey(keys.dateFilter.flexibilityIncrease));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(keys.dateFilter.flexibilityValue)).data,
        '± 4 days',
      );

      // Clamp at the upper bound.
      await pumpField(tester, initialFlexibility: kMaxFlexibilityDays);
      final increase = find.byKey(keys.dateFilter.flexibilityIncrease);
      await tester.tap(increase);
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(keys.dateFilter.flexibilityValue)).data,
        '± $kMaxFlexibilityDays days',
      );

      // Clamp at the lower bound.
      await pumpField(tester, initialFlexibility: 0);
      final decrease = find.byKey(keys.dateFilter.flexibilityDecrease);
      await tester.tap(decrease);
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(keys.dateFilter.flexibilityValue)).data,
        '± 0 days',
      );
    });

    testWidgets('renders the selected range and clears it via the X button', (
      tester,
    ) async {
      DateTime? changedStart;
      DateTime? changedEnd;
      int? changedFlex;

      await pumpField(
        tester,
        startDate: DateTime(2026, 9),
        endDate: DateTime(2026, 9, 10),
        onChanged: (start, end, flex) {
          changedStart = start;
          changedEnd = end;
          changedFlex = flex;
        },
      );

      expect(find.text('From 1 Sep to 10 Sep'), findsOneWidget);

      await tester.tap(find.byKey(keys.dateFilter.clearDates));
      await tester.pump();

      expect(changedStart, isNull);
      expect(changedEnd, isNull);
      expect(changedFlex, kDefaultFlexibilityDays);
      expect(find.text('Select dates'), findsOneWidget);
    });

    testWidgets('localizes the control in RU and UZ', (tester) async {
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      expect(ru.listings_select_dates, 'Выберите даты');
      expect(ru.listings_flexibility, 'Гибкость');
      expect(ru.listings_clear_dates, 'Очистить даты');
      expect(ru.listings_date_filter_title, 'Даты доступности');

      final uz = await AppLocalizations.delegate.load(const Locale('uz'));
      expect(uz.listings_select_dates, 'Sanani tanlang');
      expect(uz.listings_flexibility, 'Moslashuvchanlik');
      expect(uz.listings_clear_dates, 'Sanani tozalash');
      expect(uz.listings_date_filter_title, 'Mavjudlik sanasi');

      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(en.listings_select_dates, 'Select dates');
    });

    testWidgets(
      'range picker popup disables Apply and warns for a range under 1 month',
      (tester) async {
        await pumpField(
          tester,
          startDate: DateTime(2026, 9),
          endDate: DateTime(2026, 9, 10),
        );

        await tester.tap(find.byKey(keys.dateFilter.rangeSelector));
        await tester.pumpAndSettle();

        // Popup dialog with the localized title is shown.
        expect(find.text('Availability dates'), findsOneWidget);

        // Under 1 month -> Apply is disabled and a hint is shown.
        final apply = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Apply'),
        );
        expect(apply.onPressed, isNull);
        expect(
          find.text('Select a range of at least 1 month.'),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Availability dates'), findsNothing);
      },
    );

    testWidgets('range picker popup enables Apply for a range of 1 month', (
      tester,
    ) async {
      await pumpField(
        tester,
        startDate: DateTime(2026, 9),
        endDate: DateTime(2026, 10, 15),
      );

      await tester.tap(find.byKey(keys.dateFilter.rangeSelector));
      await tester.pumpAndSettle();

      final apply = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Apply'),
      );
      expect(apply.onPressed, isNotNull);
      expect(find.text('Select a range of at least 1 month.'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Availability dates'), findsNothing);
    });
  });
}
