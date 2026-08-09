import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailAbout extends StatefulWidget {
  const ListingDetailAbout({super.key, required this.description});

  final String description;

  @override
  State<ListingDetailAbout> createState() => _ListingDetailAboutState();
}

class _ListingDetailAboutState extends State<ListingDetailAbout> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description.trim();
    if (description.isEmpty) return const SizedBox.shrink();

    final bodyStyle = AppTextStyles.p3Regular.copyWith(
      color: context.currentTheme.textNeutralSecondary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: description, style: bodyStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 3,
        )..layout(maxWidth: constraints.maxWidth);
        final hasOverflow = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.localization.listing_detail_about,
              style: AppTextStyles.p2SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: bodyStyle,
            ),
            if (hasOverflow) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _isExpanded
                          ? context.localization.listing_detail_show_less
                          : context.localization.listing_detail_read_more,
                      style: AppTextStyles.p3Medium.copyWith(
                        color: context.currentTheme.textBrandPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
