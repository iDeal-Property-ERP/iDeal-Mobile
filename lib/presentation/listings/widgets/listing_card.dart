import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/gen/fonts.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_listing_rail.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as domain;
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class ListingCardTile extends StatelessWidget {
  const ListingCardTile({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.imagePriority = ImageLoadPriority.normal,
    this.onTap,
    this.width,
    this.isRail = false,
  });

  final domain.ListingCard listing;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final ImageLoadPriority imagePriority;
  final VoidCallback? onTap;
  final double? width;
  final bool isRail;

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.currentTheme.bgSurfaceBase2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.currentTheme.strokeNeutralLight100),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor3,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageBlock(context),
            Expanded(child: _buildInfoBlock(context)),
          ],
        ),
      ),
    );

    if (width != null || isRail) {
      final cardWidth = width ?? kHomeRailCardWidth;
      card = SizedBox(width: cardWidth, child: card);
    }
    return card;
  }

  Widget _buildImageBlock(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ListingCardImage(
            imageUrl: listing.coverImageUrl,
            previewUrl: listing.coverPreviewUrl,
            displayUrl: listing.coverDisplayUrl,
            priority: imagePriority,
          ),
          Positioned(
            top: 7,
            right: 7,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              label: context.localization.listings_save,
              onPressed: onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            listing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: FontFamily.inter,
              height: 1.25,
              letterSpacing: -0.15,
            ).copyWith(color: context.currentTheme.textNeutralPrimary),
          ),
          _buildPriceRow(context),
          _buildFooterRow(context),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _formatPrice(listing.price, listing.currency),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.inter,
            height: 1.1,
          ).copyWith(color: context.currentTheme.textNeutralPrimary),
        ),
        const SizedBox(width: 3),
        Text(
          context.localization.listings_per_month,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: FontFamily.inter,
            height: 1.2,
          ).copyWith(color: context.currentTheme.textNeutralSecondary),
        ),
      ],
    );
  }

  Widget _buildFooterRow(BuildContext context) {
    final districtName = listing.district ?? listing.address;
    return Row(
      children: [
        Expanded(
          child: Text(
            districtName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: FontFamily.inter,
              height: 1.2,
            ).copyWith(color: context.currentTheme.textNeutralSecondary),
          ),
        ),
        if (listing.score > 0) ...[
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                TablerIcons.star_filled,
                color: context.currentTheme.textWarningPrimary,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                listing.score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.inter,
                  height: 1.2,
                ).copyWith(color: context.currentTheme.textNeutralPrimary),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.label,
    required this.onPressed,
  });

  final bool isFavorite;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                isFavorite ? TablerIcons.heart_filled : TablerIcons.heart,
                color: isFavorite ? AppColors.heartFavorite : Colors.white,
                size: 22,
                shadows: isFavorite
                    ? const [
                        Shadow(
                          color: Color(0x80000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                        Shadow(
                          color: Color(0x4D000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : const [
                        Shadow(
                          color: Color(0xCC000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                        Shadow(color: Color(0x80000000), blurRadius: 4),
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
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

String _formatPrice(double? price, String currency) {
  if (price == null) return '—';

  final amount = price == price.roundToDouble()
      ? price.toInt().toString()
      : price.toString();

  return currency == 'USD' ? '\$$amount' : '$amount $currency';
}
