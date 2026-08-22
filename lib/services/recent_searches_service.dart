import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';

class RecentSearchesService {
  static const int maxRecentSearches = 3;

  Future<List<String>> getRecentSearches() async {
    try {
      final list = await Prefs.getStringList(PrefKeys.kRecentSearches);
      if (list == null) return const [];

      return list
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(maxRecentSearches)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSearch(String query) async {
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;

      final existing = await getRecentSearches();
      final updated = <String>[
        trimmed,
        ...existing.where(
          (item) => item.toLowerCase() != trimmed.toLowerCase(),
        ),
      ];

      await Prefs.setStringList(
        PrefKeys.kRecentSearches,
        updated.take(maxRecentSearches).toList(),
      );
    } catch (_) {}
  }

  Future<void> removeSearch(String query) async {
    try {
      final trimmed = query.trim().toLowerCase();
      final existing = await getRecentSearches();
      final updated = existing
          .where((item) => item.toLowerCase() != trimmed)
          .toList();

      await Prefs.setStringList(PrefKeys.kRecentSearches, updated);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      await Prefs.remove(PrefKeys.kRecentSearches);
    } catch (_) {}
  }
}
