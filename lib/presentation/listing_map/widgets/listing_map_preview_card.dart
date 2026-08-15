import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_map/widgets/listing_map_price_formatter.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingMapPreviewCard extends StatelessWidget {
  const ListingMapPreviewCard({
    super.key,
    required this.listing,
    required this.propertyTypeLabel,
    required this.onTap,
    this.onCall,
  });

  final ListingCard listing;
  final String propertyTypeLabel;
  final VoidCallback onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(20));
    return Semantics(
      button: true,
      label: listing.title,
      child: Material(
        color: context.currentTheme.bgSurfaceBase2,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            height: 360,
            child: Column(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: ListingCardImage(
                    imageUrl: listing.coverImageUrl,
                    previewUrl: listing.coverPreviewUrl,
                    displayUrl: listing.coverDisplayUrl,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          formatListingMapPrice(
                            listing.price,
                            listing.currency,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h5Bold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.p2SemiBold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                        Text(
                          listing.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.p3Regular.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _facts(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.c2Medium.copyWith(
                            color: context.currentTheme.textNeutralSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (onCall != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: onCall,
                              icon: const Icon(TablerIcons.phone, size: 17),
                              label: Text(
                                context.localization.listing_map_call,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _facts(BuildContext context) {
    final parts = <String>[
      propertyTypeLabel,
      if (listing.rooms != null)
        context.localization.listings_rooms_count(listing.rooms!),
      if (listing.areaSqm != null)
        context.localization.listings_area_sqm(listing.areaSqm!),
    ];
    return parts.join(' · ');
  }
}
