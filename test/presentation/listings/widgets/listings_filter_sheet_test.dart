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
import 'package:ideal_mobile/presentation/listings/widgets/district_picker_sheet.dart';
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
      ListingChoice(value: 'studio', label: 'Studio'),
      ListingChoice(value: 'room', label: 'Room'),
    ],
    tariffs: [
      ListingChoice(value: 'standard', label: 'Standard'),
      ListingChoice(value: 'comfort', label: 'Comfort'),
      ListingChoice(value: 'premium', label: 'Premium'),
    ],
    furnishings: [
      ListingChoice(value: 'unfurnished', label: 'None'),
      ListingChoice(value: 'semi_furnished', label: 'Partial'),
      ListingChoice(value: 'furnished', label: 'Full'),
    ],
    priceMin: 100,
    priceMax: 1000,
    roomsMin: 1,
    roomsMax: 5,
  );

  testWidgets('opens the listings filter sheet with its bloc', (tester) async {
    tester.view.physicalSize = const Size(411, 896);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
      greaterThan(tester.view.physicalSize.height * 0.7),
    );
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);
  });

  testWidgets('property type 2x2 grid toggles selection', (tester) async {
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

    // Verify grid items exist
    expect(find.text('Apartment'), findsOneWidget);
    expect(find.text('House'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Room'), findsOneWidget);

    // Tap Apartment to select
    await tester.ensureVisible(find.text('Apartment'));
    await tester.tap(find.text('Apartment'));
    await tester.pumpAndSettle();

    // Tap Comfort in tariff
    await tester.ensureVisible(find.text('Comfort'));
    await tester.tap(find.text('Comfort'));
    await tester.pumpAndSettle();

    // Tap Comfort again to deselect
    await tester.ensureVisible(find.text('Comfort'));
    await tester.tap(find.text('Comfort'));
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.propertyType, 'apartment');
    expect(appliedFilters?.tariff, isNull);
  });

  testWidgets('rooms preset row selects and deselects', (tester) async {
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

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5+'), findsOneWidget);

    // Tap 3 rooms
    await tester.ensureVisible(find.text('3'));
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    // Tap 5+ rooms
    await tester.ensureVisible(find.text('5+'));
    await tester.tap(find.text('5+'));
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.roomsMin, 5);
    expect(appliedFilters?.roomsMax, isNull);
  });

  testWidgets('furnishing 3-position slider toggles and selects', (
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

    expect(find.text('None'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Full'), findsOneWidget);

    // Tap Full
    await tester.ensureVisible(find.text('Full'));
    await tester.tap(find.text('Full'));
    await tester.pumpAndSettle();

    // Tap Full again to deselect
    await tester.ensureVisible(find.text('Full'));
    await tester.tap(find.text('Full'));
    await tester.pumpAndSettle();

    // Tap Partial
    await tester.ensureVisible(find.text('Partial'));
    await tester.tap(find.text('Partial'));
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.furnishing, 'semi_furnished');
  });

  testWidgets('district selector opens popup sheet and filters search', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(411, 896);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

    // Tap district button to open DistrictPickerSheet
    expect(find.text('Select district'), findsOneWidget);
    await tester.tap(find.text('Select district'));
    await tester.pumpAndSettle();

    expect(find.byType(DistrictPickerSheet), findsOneWidget);
    expect(find.text('Search district...'), findsOneWidget);

    // Search query 'Yakk'
    await tester.enterText(
      find.widgetWithText(TextField, 'Search district...'),
      'Yakk',
    );
    await tester.pumpAndSettle();

    expect(find.text('Yakkasaroy'), findsOneWidget);
    expect(find.text('Yunusobod'), findsNothing);

    // Tap Yakkasaroy to select
    await tester.tap(find.text('Yakkasaroy'));
    await tester.pumpAndSettle();

    // Returned to filter sheet and selected district displayed
    expect(find.text('Yakkasaroy'), findsOneWidget);

    // Apply
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(appliedFilters?.districtId, 4);
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

  testWidgets('currency switch updates price values and step', (tester) async {
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
                onPressed: () => showListingsFilterSheet(
                  context,
                  initialFilters: const ListingFilters(
                    currency: 'USD',
                    priceMin: 150,
                  ),
                  filterOptions: testOptions,
                  applyToListingsBloc: false,
                ),
                child: const Text('Open filters'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    // Check USD active
    expect(find.text('150'), findsOneWidget);

    // Switch to UZS
    await tester.ensureVisible(find.text('UZS'));
    await tester.tap(find.text('UZS'));
    await tester.pumpAndSettle();

    // Both controllers cleared
    final minField = find.widgetWithText(TextField, '0');
    expect(minField, findsOneWidget);
  });

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

  testWidgets(
    'district search empty state renders in DarkTheme without errors',
    (tester) async {
      tester.view.physicalSize = const Size(411, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          theme: AppThemesData.themeData[AppThemeEnum.DarkTheme],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => showListingsFilterSheet(
                    context,
                    initialFilters: const ListingFilters.empty(),
                    filterOptions: testOptions,
                    applyToListingsBloc: false,
                  ),
                  child: const Text('Open filters'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select district'));
      await tester.pumpAndSettle();

      // Type query with no matches
      await tester.enterText(
        find.widgetWithText(TextField, 'Search district...'),
        'NonExistentDistrict',
      );
      await tester.pumpAndSettle();

      expect(find.text('No districts found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
