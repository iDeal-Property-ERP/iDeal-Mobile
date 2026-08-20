import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  late MockSharedPreferencesAsync prefs;
  late RecentSearchesService service;

  setUp(() {
    prefs = MockSharedPreferencesAsync();
    Prefs.setMockPrefs(prefs);
    service = RecentSearchesService();
  });

  group('RecentSearchesService', () {
    test(
      'getRecentSearches returns empty list when no stored searches',
      () async {
        when(
          () => prefs.getStringList(PrefKeys.kRecentSearches),
        ).thenAnswer((_) async => null);

        final result = await service.getRecentSearches();

        expect(result, isEmpty);
        verify(() => prefs.getStringList(PrefKeys.kRecentSearches)).called(1);
      },
    );

    test(
      'getRecentSearches trims, filters empty and caps at 3 items',
      () async {
        when(() => prefs.getStringList(PrefKeys.kRecentSearches)).thenAnswer(
          (_) async => [
            ' Tashkent ',
            '  ',
            'Samarkand',
            'Bukhara',
            'Chilanzar',
            'Yunusobod',
            'Mirzo Ulugbek',
          ],
        );

        final result = await service.getRecentSearches();

        expect(result, ['Tashkent', 'Samarkand', 'Bukhara']);
      },
    );

    test('saveSearch ignores empty/whitespace-only input', () async {
      await service.saveSearch('   ');

      verifyNever(() => prefs.setStringList(any(), any()));
    });

    test('saveSearch prepends new query to existing searches', () async {
      when(
        () => prefs.getStringList(PrefKeys.kRecentSearches),
      ).thenAnswer((_) async => ['Samarkand', 'Bukhara']);
      when(() => prefs.setStringList(any(), any())).thenAnswer((_) async {});

      await service.saveSearch('Tashkent');

      verify(
        () => prefs.setStringList(PrefKeys.kRecentSearches, [
          'Tashkent',
          'Samarkand',
          'Bukhara',
        ]),
      ).called(1);
    });

    test(
      'saveSearch removes duplicate case-insensitively and bumps to top',
      () async {
        when(
          () => prefs.getStringList(PrefKeys.kRecentSearches),
        ).thenAnswer((_) async => ['Tashkent', 'Samarkand', 'Bukhara']);
        when(() => prefs.setStringList(any(), any())).thenAnswer((_) async {});

        await service.saveSearch('samarkand');

        verify(
          () => prefs.setStringList(PrefKeys.kRecentSearches, [
            'samarkand',
            'Tashkent',
            'Bukhara',
          ]),
        ).called(1);
      },
    );

    test('saveSearch caps stored searches to max 3 items', () async {
      when(
        () => prefs.getStringList(PrefKeys.kRecentSearches),
      ).thenAnswer((_) async => ['A', 'B', 'C', 'D', 'E']);
      when(() => prefs.setStringList(any(), any())).thenAnswer((_) async {});

      await service.saveSearch('New');

      verify(
        () => prefs.setStringList(PrefKeys.kRecentSearches, ['New', 'A', 'B']),
      ).called(1);
    });

    test('removeSearch deletes matching query case-insensitively', () async {
      when(
        () => prefs.getStringList(PrefKeys.kRecentSearches),
      ).thenAnswer((_) async => ['Tashkent', 'Samarkand', 'Bukhara']);
      when(() => prefs.setStringList(any(), any())).thenAnswer((_) async {});

      await service.removeSearch('tashkent');

      verify(
        () => prefs.setStringList(PrefKeys.kRecentSearches, [
          'Samarkand',
          'Bukhara',
        ]),
      ).called(1);
    });

    test('clearAll removes the preference key', () async {
      when(() => prefs.remove(any())).thenAnswer((_) async {});

      await service.clearAll();

      verify(() => prefs.remove(PrefKeys.kRecentSearches)).called(1);
    });
  });
}
