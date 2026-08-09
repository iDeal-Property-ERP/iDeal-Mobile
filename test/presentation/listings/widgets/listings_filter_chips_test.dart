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
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_chips.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

void _noop() {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ApplyListingFiltersEvent(ListingFilters.empty()),
    );
  });

  testWidgets('renders available filter dropdown chips', (tester) async {
    _useWideTestViewport(tester);
    final listingsBloc = MockListingsBloc();
    when(
      () => listingsBloc.state,
    ).thenReturn(ListingsState.test(filterOptions: _populatedFilterOptions()));

    await _pumpFilterChips(tester, listingsBloc);

    expect(find.text('District'), findsOneWidget);
    expect(find.text('Rooms'), findsOneWidget);
    expect(find.text('Price range'), findsOneWidget);
    expect(find.text('Tariff'), findsOneWidget);
    expect(find.text('Furnishing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dispatches a selected tariff', (tester) async {
    _useWideTestViewport(tester);
    final listingsBloc = MockListingsBloc();
    when(
      () => listingsBloc.state,
    ).thenReturn(ListingsState.test(filterOptions: _populatedFilterOptions()));

    await _pumpFilterChips(tester, listingsBloc);
    await tester.tap(find.text('Tariff'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    final event =
        verify(() => listingsBloc.add(captureAny())).captured.single
            as ApplyListingFiltersEvent;
    expect(event.filters.tariff, 'premium');
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears a selected tariff with Any', (tester) async {
    _useWideTestViewport(tester);
    final listingsBloc = MockListingsBloc();
    when(() => listingsBloc.state).thenReturn(
      ListingsState.test(
        filters: const ListingFilters(tariff: 'premium'),
        filterOptions: _populatedFilterOptions(),
      ),
    );

    await _pumpFilterChips(tester, listingsBloc);
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any'));
    await tester.pumpAndSettle();

    final event =
        verify(() => listingsBloc.add(captureAny())).captured.single
            as ApplyListingFiltersEvent;
    expect(event.filters.tariff, isNull);
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
  WidgetTester tester,
  ListingsBloc listingsBloc,
) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
      localizationsDelegates: const [AppLocalizations.delegate],
      home: Scaffold(
        body: BlocProvider<ListingsBloc>.value(
          value: listingsBloc,
          child: const ListingsFilterChips(onOpenFilters: _noop),
        ),
      ),
    ),
  );
  await tester.pump();
}
