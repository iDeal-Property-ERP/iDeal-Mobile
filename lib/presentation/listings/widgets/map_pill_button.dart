import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class MapPillButton extends StatelessWidget {
  const MapPillButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.currentTheme.bgBrandDefault,
      elevation: 6,
      shadowColor: context.currentTheme.bgShadesBlack.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap ?? _noop,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                TablerIcons.map,
                size: 20,
                color: context.currentTheme.textNeutralWhite,
              ),
              const SizedBox(width: 8),
              Text(
                context.localization.listings_view_map,
                style: AppTextStyles.p3SemiBold.copyWith(
                  color: context.currentTheme.textNeutralWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _noop() {
    // TODO(listings): wire up the map view — intentionally inert for now.
  }
}
