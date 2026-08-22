import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_search_sheet.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.kRecentSearches: ['Yunusobod', 'Chilonzor'],
    });
  });

  group('HomeSearchSheet', () {
    testWidgets('renders search input, recent searches, and submit button', (
      tester,
    ) async {
      String? submittedQuery;

      await tester.runWidgetTest(
        child: Scaffold(
          body: HomeSearchSheet(
            initialQuery: 'Mirzo Ulugbek',
            onSearchSubmitted: (query) => submittedQuery = query,
          ),
        ),
      );

      expect(find.text('Search homes'), findsOneWidget);
      expect(find.text('Mirzo Ulugbek'), findsOneWidget);
      expect(find.text('Show matching homes'), findsOneWidget);

      await tester.tap(find.text('Show matching homes'));
      expect(submittedQuery, 'Mirzo Ulugbek');
    });

    testWidgets('tapping recent search submits that query', (tester) async {
      String? submittedQuery;

      await tester.runWidgetTest(
        child: Scaffold(
          body: HomeSearchSheet(
            onSearchSubmitted: (query) => submittedQuery = query,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Yunusobod'), findsOneWidget);

      await tester.tap(find.text('Yunusobod'));
      expect(submittedQuery, 'Yunusobod');
    });
  });
}
