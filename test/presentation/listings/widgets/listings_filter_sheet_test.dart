import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

void main() {
  const testOptions = ListingFilterOptions(
    districts: [
      ListingDistrict(id: 1, name: 'Yunusobod'),
      ListingDistrict(id: 2, name: 'Chilonzor'),
      ListingDistrict(id: 3, name: 'Mirzo Ulugbek'),
      ListingDistrict(id: 4, name: 'Yakkasaroy'),
      ListingDistrict(id: 5, name: 'Yashnobod'),
    ],
    propertyTypes: [
      ListingChoice(value: 'apartment', label: 'Apartment'),
      ListingChoice(value: 'house', label: 'House'),
    ],
    tariffs: [
      ListingChoice(value: 'standard', label: 'Standard'),
      ListingChoice(value: 'comfort', label: 'Comfort'),
      ListingChoice(value: 'premium', label: 'Premium'),
    ],
    furnishings: [
      ListingChoice(value: 'furnished', label: 'Furnished'),
      ListingChoice(value: 'unfurnished', label: 'Unfurnished'),
    ],
    priceMin: 100,
    priceMax: 1000,
    roomsMin: 1,
    roomsMax: 5,
  );

  testWidgets('opens the listings filter sheet with its bloc', (tester) async {
    final mockBloc = MockListingsBloc();
    when(
      () => mockBloc.state,
    ).thenReturn(ListingsState.test(filterOptions: testOptions));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<ListingsBloc>.value(
          value: mockBloc,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => showListingsFilterSheet(context),
                  child: const Text('Open filters'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final sheet = find.byType(DraggableScrollableSheet);
    expect(sheet, findsOneWidget);
    expect(
      tester.getSize(sheet).height,
      lessThan(tester.view.physicalSize.height * 0.7),
    );
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);
  });

  testWidgets('choice groups do not have "Any" and toggle selection', (
    tester,
  ) async {
    ListingFilters? appliedFilters;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  appliedFilters = await showListingsFilterSheet(
                    context,
                    initialFilters: const ListingFilters.empty(),
                    filterOptions: testOptions,
                    applyToListingsBloc: false,
                  );
                },
                child: const Text('Open filters'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    // "Any" choice pill should not exist in choice groups
    expect(find.text('Any'), findsNothing);

    // Tap 'Apartment' to select
    await tester.ensureVisible(find.text('Apartment'));
    await tester.tap(find.text('Apartment'));
    await tester.pumpAndSettle();

    // Tap 'Comfort' to select
    await tester.ensureVisible(find.text('Comfort'));
    await tester.tap(find.text('Comfort'));
    await tester.pumpAndSettle();

    // Tap 'Comfort' again to deselect
    await tester.ensureVisible(find.text('Comfort'));
    await tester.tap(find.text('Comfort'));
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.propertyType, 'apartment');
    expect(appliedFilters?.tariff, isNull);
  });

  testWidgets('verification checkbox toggles verified flag', (tester) async {
    ListingFilters? appliedFilters;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  appliedFilters = await showListingsFilterSheet(
                    context,
                    initialFilters: const ListingFilters.empty(),
                    filterOptions: testOptions,
                    applyToListingsBloc: false,
                  );
                },
                child: const Text('Open filters'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    expect(find.text('Verification'), findsOneWidget);
    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);

    // Ensure visible and tap checkbox / row to check
    await tester.ensureVisible(find.text('Verified only'));
    await tester.tap(find.text('Verified only'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.verified, isTrue);
  });

  testWidgets(
    'district custom dropdown shows max 3 items and filters by search query',
    (tester) async {
      ListingFilters? appliedFilters;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    appliedFilters = await showListingsFilterSheet(
                      context,
                      initialFilters: const ListingFilters.empty(),
                      filterOptions: testOptions,
                      applyToListingsBloc: false,
                    );
                  },
                  child: const Text('Open filters'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();

      // Open district dropdown
      expect(find.text('Select district'), findsOneWidget);
      await tester.tap(find.text('Select district'));
      await tester.pumpAndSettle();

      // Search input should appear
      expect(find.text('Search district...'), findsOneWidget);

      // Max 3 items visible initially from list of 5
      expect(find.text('Yunusobod'), findsOneWidget);
      expect(find.text('Chilonzor'), findsOneWidget);
      expect(find.text('Mirzo Ulugbek'), findsOneWidget);
      expect(find.text('Yakkasaroy'), findsNothing);
      expect(find.text('Yashnobod'), findsNothing);

      // Type search query 'Yakk'
      await tester.enterText(
        find.widgetWithText(TextField, 'Search district...'),
        'Yakk',
      );
      await tester.pumpAndSettle();

      // Only matching district appears
      expect(find.text('Yakkasaroy'), findsOneWidget);
      expect(find.text('Yunusobod'), findsNothing);

      // Tap Yakkasaroy to select
      await tester.tap(find.text('Yakkasaroy'));
      await tester.pumpAndSettle();

      // Dropdown closed and selected district displayed
      expect(find.text('Yakkasaroy'), findsOneWidget);

      // Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(appliedFilters?.districtId, 4);
    },
  );

  testWidgets('clears all filters with Clear all button', (tester) async {
    ListingFilters? appliedFilters;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  appliedFilters = await showListingsFilterSheet(
                    context,
                    initialFilters: const ListingFilters(
                      districtId: 1,
                      verified: true,
                      propertyType: 'apartment',
                      tariff: 'comfort',
                    ),
                    filterOptions: testOptions,
                    applyToListingsBloc: false,
                  );
                },
                child: const Text('Open filters'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    // Verify initial values
    expect(find.text('Yunusobod'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    // Tap Clear all
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    // Verify reset to defaults
    expect(find.text('Select district'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.districtId, isNull);
    expect(appliedFilters?.verified, isNull);
    expect(appliedFilters?.propertyType, isNull);
    expect(appliedFilters?.tariff, isNull);
  });
}
