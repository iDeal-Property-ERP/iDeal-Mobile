import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/i18n.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';

class LocaleService {
  static const _localeKey = 'locale';

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final languageCode = await Prefs.getString(_localeKey);
    if (languageCode == null) return;

    final savedLocale = Locale(languageCode);
    if (I18n.all.contains(savedLocale)) {
      locale.value = savedLocale;
    }
  }

  static Future<void> setLocale(Locale nextLocale) async {
    if (!I18n.all.contains(nextLocale)) return;

    locale.value = nextLocale;
    await Prefs.setString(_localeKey, nextLocale.languageCode);
  }
}
