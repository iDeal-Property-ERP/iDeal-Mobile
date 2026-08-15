import 'package:ideal_mobile/shared_pref/prefs.dart';

class LegacyFavoritesCleanupService {
  const LegacyFavoritesCleanupService();

  static const _legacyFavoritesKey = 'ideal_favorites';
  static const _cleanupMarkerKey = 'ideal_favorites_cleanup_done_v1';

  Future<void> clearLegacyFavoritesOnce() async {
    if (await Prefs.getBool(_cleanupMarkerKey) ?? false) return;
    await Prefs.remove(_legacyFavoritesKey);
    await Prefs.setBool(_cleanupMarkerKey, value: true);
  }
}
