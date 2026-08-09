import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailTrustCard extends StatelessWidget {
  const ListingDetailTrustCard({super.key, required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    final checklist = detail.verificationChecklist;
    if (checklist.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.currentTheme.bgBrandLight50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                TablerIcons.shield_check,
                size: 22,
                color: context.currentTheme.iconBrandPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.localization.listing_detail_trust_heading,
                  style: AppTextStyles.p3SemiBold.copyWith(
                    color: context.currentTheme.textBrandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < checklist.length; index++) ...[
                if (index > 0) const SizedBox(height: 8),
                _TrustRow(item: checklist[index]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.item});

  final VerificationItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          TablerIcons.check,
          size: 16,
          color: context.currentTheme.iconBrandPrimary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.label,
            style: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
