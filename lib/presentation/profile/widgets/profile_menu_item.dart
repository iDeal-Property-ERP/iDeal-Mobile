import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
    this.rightWidget,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  final Widget? rightWidget;

  static const Color _navyIcon = Color(0xFF0F2A5C);
  static const Color _blueIconBg = Color(0xFFEAF1FE);
  static const Color _darkIconBg = Color(0xFF1E2E4A);
  static const Color _darkIconColor = Color(0xFF8EB6F9);

  static const Color _redColor = Color(0xFFDC2626);
  static const Color _redIconBg = Color(0xFFFDECEC);
  static const Color _darkRedIconBg = Color(0xFF3B1818);

  static const Color _chevronColor = Color(0xFF8891A5);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    final iconBg = isDanger
        ? (isDark ? _darkRedIconBg : _redIconBg)
        : (isDark ? _darkIconBg : _blueIconBg);

    final iconColor = isDanger
        ? _redColor
        : (isDark ? _darkIconColor : _navyIcon);

    final textColor = isDanger
        ? _redColor
        : context.currentTheme.textNeutralPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 13.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: context.currentTheme.strokeNeutralLight200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                  child: Center(
                    child: Icon(icon, size: 18.0, color: iconColor),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.p3SemiBold.copyWith(
                      color: textColor,
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                rightWidget ??
                    const Icon(
                      TablerIcons.chevron_right,
                      size: 18.0,
                      color: _chevronColor,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
