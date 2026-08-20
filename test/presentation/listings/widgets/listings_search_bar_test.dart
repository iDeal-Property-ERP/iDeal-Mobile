import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_search_bar.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers.dart';

class MockRecentSearchesService extends Mock implements RecentSearchesService {}

void main() {
  late MockRecentSearchesService recentSearchesService;

  setUp(() {
    recentSearchesService = MockRecentSearchesService();
    when(
      () => recentSearchesService.getRecentSearches(),
    ).thenAnswer((_) async => ['Tashkent', 'Samarkand']);
    when(
      () => recentSearchesService.saveSearch(any()),
    ).thenAnswer((_) async {});
    when(
      () => recentSearchesService.removeSearch(any()),
    ).thenAnswer((_) async {});
    when(() => recentSearchesService.clearAll()).thenAnswer((_) async {});
  });

  group('ListingsSearchBar', () {
    testWidgets('renders input and initial query', (tester) async {
      await tester.runWidgetTest(
        child: Scaffold(
          body: ListingsSearchBar(
            query: 'Chilanzar',
            recentSearchesService: recentSearchesService,
          ),
        ),
      );

      expect(find.text('Chilanzar'), findsOneWidget);
      expect(find.byIcon(TablerIcons.search), findsOneWidget);
    });

    testWidgets('shows recent searches overlay on focus when available', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: Scaffold(
          body: ListingsSearchBar(recentSearchesService: recentSearchesService),
        ),
      );

      expect(find.text('Recent searches'), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('Tashkent'), findsOneWidget);
      expect(find.text('Samarkand'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets(
      'tapping recent item fills input, fires callback, and hides overlay',
      (tester) async {
        String? searchedQuery;

        await tester.runWidgetTest(
          child: Scaffold(
            body: ListingsSearchBar(
              recentSearchesService: recentSearchesService,
              onQueryChanged: (query) => searchedQuery = query,
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Tashkent'));
        await tester.pumpAndSettle();

        expect(searchedQuery, 'Tashkent');
        expect(find.text('Recent searches'), findsNothing);
        verify(() => recentSearchesService.saveSearch('Tashkent')).called(1);
      },
    );

    testWidgets('tapping remove icon deletes item without triggering search', (
      tester,
    ) async {
      String? searchedQuery;
      when(
        () => recentSearchesService.getRecentSearches(),
      ).thenAnswer((_) async => ['Tashkent']);

      await tester.runWidgetTest(
        child: Scaffold(
          body: ListingsSearchBar(
            recentSearchesService: recentSearchesService,
            onQueryChanged: (query) => searchedQuery = query,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      when(
        () => recentSearchesService.getRecentSearches(),
      ).thenAnswer((_) async => []);

      final removeButton = find.byTooltip('Remove').first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      verify(() => recentSearchesService.removeSearch('Tashkent')).called(1);
      expect(searchedQuery, isNull);
      expect(find.text('Recent searches'), findsNothing);
    });

    testWidgets(
      'tapping Clear all removes all recent searches and hides overlay',
      (tester) async {
        await tester.runWidgetTest(
          child: Scaffold(
            body: ListingsSearchBar(
              recentSearchesService: recentSearchesService,
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clear all'));
        await tester.pumpAndSettle();

        verify(() => recentSearchesService.clearAll()).called(1);
        expect(find.text('Recent searches'), findsNothing);
      },
    );

    testWidgets('typing query hides recent searches and debounces search', (
      tester,
    ) async {
      String? searchedQuery;

      await tester.runWidgetTest(
        child: Scaffold(
          body: ListingsSearchBar(
            recentSearchesService: recentSearchesService,
            onQueryChanged: (query) => searchedQuery = query,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Recent searches'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Bukhara');
      await tester.pump();

      expect(find.text('Recent searches'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));

      expect(searchedQuery, 'Bukhara');
      verify(() => recentSearchesService.saveSearch('Bukhara')).called(1);
    });

    testWidgets(
      'clearing text with suffix X restores recent searches on focus',
      (tester) async {
        await tester.runWidgetTest(
          child: Scaffold(
            body: ListingsSearchBar(
              query: 'Existing',
              recentSearchesService: recentSearchesService,
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        expect(find.text('Recent searches'), findsNothing);

        await tester.tap(find.byIcon(TablerIcons.x));
        await tester.pumpAndSettle();

        expect(find.text('Recent searches'), findsOneWidget);
      },
    );

    testWidgets('does not show overlay when enableRecentSearches is false', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: Scaffold(
          body: ListingsSearchBar(
            enableRecentSearches: false,
            recentSearchesService: recentSearchesService,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text('Recent searches'), findsNothing);
      verifyNever(() => recentSearchesService.getRecentSearches());
    });
  });
}
