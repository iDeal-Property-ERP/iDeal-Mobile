import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_my_listings_sheet.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfilePropertiesCard extends StatelessWidget {
  const ProfilePropertiesCard({
    super.key,
    this.totalCount = 3,
    this.approvedCount = 2,
    this.pendingCount = 1,
    this.rentedCount = 1,
  });

  final int totalCount;
  final int approvedCount;
  final int pendingCount;
  final int rentedCount;

  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _pendingColor = Color(0xFFD97706);
  static const Color _rentedColor = Color(0xFF16A34A);
  static const Color _mutedColor = Color(0xFF8891A5);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    return Transform.translate(
      offset: const Offset(0, -18.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: context.currentTheme.strokeNeutralLight200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F2A5C),
              blurRadius: 20.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(18.0),
            onTap: () => ProfileMyListingsSheet.show(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        context.localization.properties_count_label(totalCount),
                        style: AppTextStyles.p2Bold.copyWith(
                          color: context.currentTheme.textNeutralPrimary,
                          fontSize: 15.0,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.localization.view_all,
                            style: AppTextStyles.p4SemiBold.copyWith(
                              color: _accentColor,
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(width: 3.0),
                          const Icon(
                            TablerIcons.chevron_right,
                            size: 14.0,
                            color: _accentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999.0),
                    child: SizedBox(
                      height: 8.0,
                      child: Row(
                        children: [
                          Expanded(
                            flex: approvedCount > 0 ? approvedCount : 1,
                            child: const ColoredBox(color: _accentColor),
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            flex: pendingCount > 0 ? pendingCount : 1,
                            child: const ColoredBox(color: _pendingColor),
                          ),
                          const SizedBox(width: 2.0),
                          Expanded(
                            flex: rentedCount > 0 ? rentedCount : 1,
                            child: const ColoredBox(color: _rentedColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusLegendItem(
                          dotColor: _accentColor,
                          label:
                              '${context.localization.status_approved} '
                              '· $approvedCount',
                          textColor: isDark
                              ? context.currentTheme.textNeutralSecondary
                              : _mutedColor,
                        ),
                        const SizedBox(width: 16.0),
                        _StatusLegendItem(
                          dotColor: _pendingColor,
                          label:
                              '${context.localization.status_pending} '
                              '· $pendingCount',
                          textColor: isDark
                              ? context.currentTheme.textNeutralSecondary
                              : _mutedColor,
                        ),
                        const SizedBox(width: 16.0),
                        _StatusLegendItem(
                          dotColor: _rentedColor,
                          label:
                              '${context.localization.status_rented} '
                              '· $rentedCount',
                          textColor: isDark
                              ? context.currentTheme.textNeutralSecondary
                              : _mutedColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  const _StatusLegendItem({
    required this.dotColor,
    required this.label,
    required this.textColor,
  });

  final Color dotColor;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: AppTextStyles.p4Medium.copyWith(
            color: textColor,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
