import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ListingDetailNotFound extends StatelessWidget {
  const ListingDetailNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
                color: context.currentTheme.iconBrandPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.localization.listing_detail_not_found,
              textAlign: TextAlign.center,
              style: AppTextStyles.h6SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
