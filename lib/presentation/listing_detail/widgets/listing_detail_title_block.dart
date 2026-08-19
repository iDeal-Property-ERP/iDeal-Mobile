import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailTitleBlock extends StatelessWidget {
  const ListingDetailTitleBlock({super.key, required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    final hasStatusRow = detail.score > 0 || detail.isVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasStatusRow) ...[
          Row(
            children: [
              if (detail.score > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TablerIcons.star_filled,
                      size: 15,
                      color: context.currentTheme.textWarningPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detail.score.toString(),
                      style: AppTextStyles.p3SemiBold.copyWith(
                        color: context.currentTheme.textNeutralPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '(${context.localization.listing_detail_reviews_count(detail.reviewCount)})',
                      style: AppTextStyles.p3Regular.copyWith(
                        color: context.currentTheme.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              if (detail.isVerified) _buildVerifiedPill(context),
            ],
          ),
          const SizedBox(height: 9),
        ],
        Text(
          detail.title,
          style: AppTextStyles.h6SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              TablerIcons.map_pin,
              size: 15,
              color: context.currentTheme.textNeutralSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                detail.district ?? detail.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.p3Regular.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerifiedPill(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.currentTheme.bgBrandLight50,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.check,
              size: 14,
              color: context.currentTheme.iconBrandPrimary,
            ),
            const SizedBox(width: 5),
            Text(
              context.localization.listing_detail_verified,
              style: AppTextStyles.p4SemiBold.copyWith(
                color: context.currentTheme.textBrandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
