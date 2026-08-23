import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/services/locale_service.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileLanguageSheet extends StatelessWidget {
  const ProfileLanguageSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => const ProfileLanguageSheet(),
    );
  }

  static const List<_LanguageOption> _languages = [
    _LanguageOption(code: 'uz', name: "O'zbekcha", flag: '🇺🇿'),
    _LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    _LanguageOption(code: 'en', name: 'English', flag: '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocaleCode =
        LocaleService.locale.value?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                context.localization.language_settings,
                style: AppTextStyles.h6Bold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ..._languages.map((lang) {
              final isSelected = lang.code == currentLocaleCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Material(
                  color: isSelected
                      ? (context.isDark
                            ? const Color(0xFF1E2E4A)
                            : const Color(0xFFEAF1FE))
                      : (context.isDark
                            ? context.currentTheme.bgSurfaceBase2
                            : Colors.white),
                  borderRadius: BorderRadius.circular(14.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.0),
                    onTap: () async {
                      await HapticFeedbackUtil.light();
                      await LocaleService.setLocale(Locale(lang.code));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : context.currentTheme.strokeNeutralLight200,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            lang.flag,
                            style: const TextStyle(fontSize: 22.0),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Text(
                              lang.name,
                              style: AppTextStyles.p2SemiBold.copyWith(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : context.currentTheme.textNeutralPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              TablerIcons.check,
                              color: Color(0xFF3B82F6),
                              size: 20.0,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });

  final String code;
  final String name;
  final String flag;
}
