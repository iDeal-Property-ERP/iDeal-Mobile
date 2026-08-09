import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_sheet.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

void main() {
  testWidgets('opens the listings filter sheet with its bloc', (tester) async {
    final mockBloc = MockListingsBloc();
    when(() => mockBloc.state).thenReturn(
      ListingsState.test(
        filterOptions: const ListingFilterOptions(
          districts: [ListingDistrict(id: 1, name: 'Yunusobod')],
          tariffs: [ListingChoice(value: 'comfort', label: 'Comfort')],
          furnishings: [ListingChoice(value: 'furnished', label: 'Furnished')],
          priceMin: 100,
          priceMax: 1000,
          roomsMin: 1,
          roomsMax: 5,
        ),
      ),
    );

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
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);
  });
}
