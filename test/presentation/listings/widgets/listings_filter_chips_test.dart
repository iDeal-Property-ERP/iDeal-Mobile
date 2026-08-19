import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_chips.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';

void _noop() {}

void main() {
  testWidgets('renders available filter dropdown chips', (tester) async {
    _useWideTestViewport(tester);

    await _pumpFilterChips(
      tester,
      filters: const ListingFilters.empty(),
      filterOptions: _populatedFilterOptions(),
    );

    expect(find.text('District'), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Price range'), findsOneWidget);
    expect(find.text('Tariff'), findsOneWidget);
    expect(find.text('Furnishing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reports a selected tariff', (tester) async {
    _useWideTestViewport(tester);
    final reportedFilters = <ListingFilters>[];

    await _pumpFilterChips(
      tester,
      filters: const ListingFilters.empty(),
      filterOptions: _populatedFilterOptions(),
      onFiltersChanged: reportedFilters.add,
    );
    await tester.tap(find.text('Tariff'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    expect(reportedFilters, hasLength(1));
    expect(reportedFilters.single.tariff, 'premium');
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears a selected tariff with Any', (tester) async {
    _useWideTestViewport(tester);
    final reportedFilters = <ListingFilters>[];

    await _pumpFilterChips(
      tester,
      filters: const ListingFilters(tariff: 'premium'),
      filterOptions: _populatedFilterOptions(),
      onFiltersChanged: reportedFilters.add,
    );
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any'));
    await tester.pumpAndSettle();

    expect(reportedFilters, hasLength(1));
    expect(reportedFilters.single.tariff, isNull);
    expect(tester.takeException(), isNull);
  });
}

void _useWideTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(2400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

ListingFilterOptions _populatedFilterOptions() {
  return const ListingFilterOptions(
    districts: [ListingDistrict(id: 1, name: 'Yunusobod')],
    tariffs: [
      ListingChoice(value: 'comfort', label: 'Comfort'),
      ListingChoice(value: 'premium', label: 'Premium'),
    ],
    furnishings: [ListingChoice(value: 'furnished', label: 'Furnished')],
  );
}

Future<void> _pumpFilterChips(
  WidgetTester tester, {
  required ListingFilters filters,
  required ListingFilterOptions filterOptions,
  ValueChanged<ListingFilters>? onFiltersChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
      localizationsDelegates: const [AppLocalizations.delegate],
      home: Scaffold(
        body: ListingsFilterChips(
          filters: filters,
          filterOptions: filterOptions,
          onFiltersChanged: onFiltersChanged ?? (_) {},
          onOpenFilters: _noop,
        ),
      ),
    ),
  );
  await tester.pump();
}
