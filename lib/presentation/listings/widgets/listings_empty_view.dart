import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ListingsEmptyView extends StatelessWidget {
  const ListingsEmptyView({super.key, required this.onClearFilters});

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 320),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.currentTheme.bgBrandLight100,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(
                  TablerIcons.search_off,
                  size: 28,
                  color: context.currentTheme.textBrandPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.localization.listings_empty_title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.localization.listings_empty_subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.p3Regular.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: context.localization.listings_clear_filters,
                size: AppButtonSize.medium,
                onPressed: onClearFilters,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
