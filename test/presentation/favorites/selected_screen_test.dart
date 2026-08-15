import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/i18n/app_localizations_ru.dart';
import 'package:ideal_mobile/i18n/app_localizations_uz.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/favorites/selected_screen.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class MockSelectedBloc extends MockBloc<SelectedEvent, SelectedState>
    implements SelectedBloc {}

void main() {
  ListingCard listing(int id, {bool isFavorite = true}) => ListingCard(
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
    isFavorite: isFavorite,
  );

  Future<void> pumpScreen(WidgetTester tester, SelectedBloc bloc) {
    return tester.runWidgetTest(
      providers: [BlocProvider<SelectedBloc>.value(value: bloc)],
      child: const Scaffold(body: SelectedScreen()),
    );
  }

  Future<void> pumpLocalizedScreen(
    WidgetTester tester,
    SelectedBloc bloc,
    Locale locale,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocProvider<SelectedBloc>.value(
          value: bloc,
          child: const Scaffold(body: SelectedScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows loading shimmer before the first selected response', (
    tester,
  ) async {
    final bloc = MockSelectedBloc();
    when(
      () => bloc.state,
    ).thenReturn(SelectedState.test(isLoading: true, hasLoaded: false));

    await pumpScreen(tester, bloc);

    expect(find.byType(ListingCardShimmerGrid), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
    expect(find.byType(SelectedScreen), findsOneWidget);
  });

  testWidgets('shows the empty selected state', (tester) async {
    final bloc = MockSelectedBloc();
    when(
      () => bloc.state,
    ).thenReturn(SelectedState.test(hasLoaded: true, items: const []));

    await pumpScreen(tester, bloc);

    expect(find.text('No selected homes yet'), findsOneWidget);
    expect(
      find.text('Tap the heart on any home to keep it here for later.'),
      findsOneWidget,
    );
  });

  testWidgets('shows full-screen retry on the initial selected error', (
    tester,
  ) async {
    final bloc = MockSelectedBloc();
    when(() => bloc.state).thenReturn(
      SelectedState.test(hasLoaded: true, errorMessage: selectedLoadErrorKey),
    );

    await pumpScreen(tester, bloc);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => bloc.add(const LoadSelectedEvent(refresh: true))).called(1);
  });

  testWidgets('shows pagination loading and inline retry while cards remain', (
    tester,
  ) async {
    final bloc = MockSelectedBloc();
    when(() => bloc.state).thenReturn(
      SelectedState.test(
        hasLoaded: true,
        items: [listing(1)],
        count: 2,
        isLoadingMore: true,
        errorMessage: selectedLoadErrorKey,
        failedPage: 2,
      ),
    );

    await pumpScreen(tester, bloc);

    expect(find.text('Loading more selected homes'), findsOneWidget);
    expect(
      find.text("Couldn't load your selected homes. Please try again."),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => bloc.add(const ClearSelectedLoadErrorEvent())).called(1);
    verify(() => bloc.add(const LoadMoreSelectedEvent())).called(1);
  });

  testWidgets(
    'shows snackbar feedback when load more fails with visible cards',
    (tester) async {
      final bloc = MockSelectedBloc();
      final initialState = SelectedState.test(
        hasLoaded: true,
        items: [listing(1)],
        count: 1,
      );
      final errorState = SelectedState.test(
        hasLoaded: true,
        items: [listing(1)],
        count: 1,
        errorMessage: 'backend response leaked',
      );
      when(() => bloc.state).thenReturn(errorState);
      whenListen(
        bloc,
        Stream.fromIterable([errorState]),
        initialState: initialState,
      );

      await pumpScreen(tester, bloc);
      await tester.pump();

      expect(
        find.text(
          'Something went wrong with your selected homes. Please try again.',
        ),
        findsWidgets,
      );
      expect(find.text('backend response leaked'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );

  test('selected error localization lookup covers Russian and Uzbek', () {
    final ru = AppLocalizationsRu();
    final uz = AppLocalizationsUz();

    expect(ru.selected_load_error, contains('Не удалось'));
    expect(ru.selected_mutation_error, contains('обновить'));
    expect(uz.selected_load_error, contains('yuklab bo‘lmadi'));
    expect(uz.selected_mutation_error, contains('yangilab bo‘lmadi'));
  });

  testWidgets('uses the localized title in the root top bar', (tester) async {
    for (final scenario in const [
      (Locale('en'), 'Selected'),
      (Locale('ru'), 'Избранное'),
      (Locale('uz'), 'Tanlanganlar'),
    ]) {
      final bloc = MockSelectedBloc();
      when(
        () => bloc.state,
      ).thenReturn(SelectedState.test(hasLoaded: true, items: const []));

      await pumpLocalizedScreen(tester, bloc, scenario.$1);
      expect(find.text(scenario.$2), findsOneWidget);
    }
  });
}
