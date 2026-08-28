import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

/// Full-width outlined "All filters" button shown below the Home banner
/// carousel. Opens the existing full filter sheet and shows a brand count badge
/// when [activeFiltersCount] is greater than zero.
class HomeAllFiltersButton extends StatelessWidget {
  const HomeAllFiltersButton({
    required this.onTap,
    this.activeFiltersCount = 0,
    super.key,
  });

  final VoidCallback onTap;
  final int activeFiltersCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final hasActiveFilters = activeFiltersCount > 0;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.strokeNeutralLight200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          foregroundColor: theme.textNeutralPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.adjustments_horizontal,
              size: 20,
              color:
                  hasActiveFilters
                      ? theme.iconBrandPrimary
                      : theme.iconNeutralDefault,
            ),
            const SizedBox(width: 8),
            Text(
              context.localization.listings_all_filters,
              style: AppTextStyles.p3Medium.copyWith(
                color: theme.textNeutralPrimary,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.bgBrandDefault,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                child: Text(
                  activeFiltersCount.toString(),
                  style: AppTextStyles.c2SemiBold.copyWith(
                    color: theme.textNeutralWhite,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
