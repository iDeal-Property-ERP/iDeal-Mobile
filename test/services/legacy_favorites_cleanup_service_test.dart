import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

void main() {
  late MockSharedPreferencesAsync prefs;

  setUp(() {
    prefs = MockSharedPreferencesAsync();
    Prefs.setMockPrefs(prefs);
  });

  test(
    'deletes legacy favorites once and records the cleanup marker',
    () async {
      when(
        () => prefs.getBool('ideal_favorites_cleanup_done_v1'),
      ).thenAnswer((_) async => false);
      when(() => prefs.remove(any())).thenAnswer((_) async {});
      when(() => prefs.setBool(any(), any())).thenAnswer((_) async {});

      await const LegacyFavoritesCleanupService().clearLegacyFavoritesOnce();

      verify(() => prefs.remove('ideal_favorites')).called(1);
      verify(
        () => prefs.setBool('ideal_favorites_cleanup_done_v1', true),
      ).called(1);
    },
  );

  test('does not delete legacy favorites after the marker is set', () async {
    when(
      () => prefs.getBool('ideal_favorites_cleanup_done_v1'),
    ).thenAnswer((_) async => true);

    await const LegacyFavoritesCleanupService().clearLegacyFavoritesOnce();

    verifyNever(() => prefs.remove(any()));
    verifyNever(() => prefs.setBool(any(), any()));
  });
}
