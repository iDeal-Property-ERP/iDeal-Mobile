import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/i18n.dart';
import 'package:ideal_mobile/services/locale_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  static const _languageNames = <String, String>{
    'en': 'English',
    'uz': 'Oʻzbekcha',
    'ru': 'Русский',
  };

  @override
  Widget build(BuildContext context) {
    final currentLocale =
        LocaleService.locale.value ?? Localizations.localeOf(context);
    return PopupMenuButton<Locale>(
      tooltip: 'Language',
      onSelected: LocaleService.setLocale,
      itemBuilder: (context) => [
        for (final locale in I18n.all)
          PopupMenuItem(
            value: locale,
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(locale.languageCode.toUpperCase()),
                ),
                Text(_languageNames[locale.languageCode]!),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          currentLocale.languageCode.toUpperCase(),
          style: AppTextStyles.p3SemiBold.copyWith(
            color: context.currentTheme.textBrandSecondary,
          ),
        ),
      ),
    );
  }
}
