import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({super.key, required this.title});

  final String title;

  static const Color _mutedColor = Color(0xFF8891A5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 10.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.c1SemiBold.copyWith(
          color: context.isDark
              ? context.currentTheme.textNeutralSecondary
              : _mutedColor,
          letterSpacing: 0.8,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
