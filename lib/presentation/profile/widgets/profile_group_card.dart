import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class ProfileGroupItem {
  const ProfileGroupItem({
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
}

class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({super.key, required this.items});

  final List<ProfileGroupItem> items;

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
    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDark;
    final cardBg = isDark
        ? context.currentTheme.bgSurfaceBase2
        : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.currentTheme.strokeNeutralLight200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1.0,
                thickness: 1.0,
                indent: 64.0,
                color: context.currentTheme.strokeNeutralLight200,
              ),
            _ProfileGroupRow(
              item: items[i],
              isDark: isDark,
              navyIcon: _navyIcon,
              blueIconBg: _blueIconBg,
              darkIconBg: _darkIconBg,
              darkIconColor: _darkIconColor,
              redColor: _redColor,
              redIconBg: _redIconBg,
              darkRedIconBg: _darkRedIconBg,
              chevronColor: _chevronColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileGroupRow extends StatelessWidget {
  const _ProfileGroupRow({
    required this.item,
    required this.isDark,
    required this.navyIcon,
    required this.blueIconBg,
    required this.darkIconBg,
    required this.darkIconColor,
    required this.redColor,
    required this.redIconBg,
    required this.darkRedIconBg,
    required this.chevronColor,
  });

  final ProfileGroupItem item;
  final bool isDark;
  final Color navyIcon;
  final Color blueIconBg;
  final Color darkIconBg;
  final Color darkIconColor;
  final Color redColor;
  final Color redIconBg;
  final Color darkRedIconBg;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    final iconBg = item.isDanger
        ? (isDark ? darkRedIconBg : redIconBg)
        : (isDark ? darkIconBg : blueIconBg);

    final iconColor = item.isDanger
        ? redColor
        : (isDark ? darkIconColor : navyIcon);

    final textColor = item.isDanger
        ? redColor
        : context.currentTheme.textNeutralPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
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
                  child: Icon(item.icon, size: 18.0, color: iconColor),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.p3SemiBold.copyWith(
                    color: textColor,
                    fontSize: 14.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8.0),
              item.rightWidget ??
                  Icon(
                    TablerIcons.chevron_right,
                    size: 18.0,
                    color: chevronColor,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
