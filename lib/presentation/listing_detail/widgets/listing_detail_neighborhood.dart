import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailNeighborhood extends StatelessWidget {
  const ListingDetailNeighborhood({
    super.key,
    required this.district,
    this.onTap,
  });

  final String? district;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (district == null) return const SizedBox.shrink();

    final content = Row(
      children: [
        Expanded(
          child: Text(
            context.localization.listing_detail_neighborhood,
            style: AppTextStyles.p2SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            district!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 4),
          Icon(
            TablerIcons.chevron_right,
            size: 18,
            color: context.currentTheme.textNeutralSecondary,
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
