import 'dart:convert';

import 'package:ideal_mobile/shared_pref/prefs.dart';

class FavoritesService {
  const FavoritesService();

  static const _favoritesKey = 'ideal_favorites';

  Future<Set<int>> load() async {
    final encoded = await Prefs.getString(_favoritesKey);
    if (encoded == null || encoded.isEmpty) return <int>{};

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return <int>{};

      return decoded.map(_toInt).whereType<int>().toSet();
    } on FormatException {
      return <int>{};
    }
  }

  Future<Set<int>> toggle(int id) async {
    final favorites = await load();
    if (!favorites.add(id)) {
      favorites.remove(id);
    }

    final sortedIds = favorites.toList()..sort();
    await Prefs.setString(_favoritesKey, jsonEncode(sortedIds));
    return favorites;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
