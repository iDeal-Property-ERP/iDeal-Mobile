import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart'
    as domain;
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';

class ListingCardTile extends StatelessWidget {
  const ListingCardTile({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.imagePriority = ImageLoadPriority.normal,
    this.onTap,
  });

  final domain.ListingCard listing;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final ImageLoadPriority imagePriority;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.currentTheme.bgSurfaceBase2,
          borderRadius: BorderRadius.circular(AppRadius.card),
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
          children: [_buildImageBlock(context), _buildInfoBlock(context)],
        ),
      ),
    );
  }

  Widget _buildImageBlock(BuildContext context) {
    return AspectRatio(
      aspectRatio: 388 / 210,
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
            top: 12,
            right: 12,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildPriceRow(context)),
              const SizedBox(width: 8),
              _buildTariffPill(context),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.p2SemiBold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
              ),
              if (listing.score > 0) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      TablerIcons.star_filled,
                      color: context.currentTheme.textWarningPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      listing.score.toString(),
                      style: AppTextStyles.p3Medium.copyWith(
                        color: context.currentTheme.textNeutralPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _metaLine(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
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
          style: AppTextStyles.h5Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          context.localization.listings_per_month,
          style: AppTextStyles.p3Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTariffPill(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.currentTheme.bgNeutralLight100,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          _tariffLabel(context),
          style: AppTextStyles.c2Medium.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ),
    );
  }

  String _metaLine(BuildContext context) {
    final segments = <String>[
      listing.district ?? listing.address,
      if (listing.rooms != null)
        context.localization.listings_rooms_count(listing.rooms!),
      if (listing.areaSqm != null)
        context.localization.listings_area_sqm(listing.areaSqm!),
      if (listing.floor != null)
        _floorLabel(context, listing.floor!, listing.totalFloors),
    ];

    return segments.join(' · ');
  }

  String _floorLabel(BuildContext context, int floor, int? totalFloors) {
    // A dedicated string rather than substituting into listings_floor_of: in
    // Uzbek the total precedes the floor ('{total} dan {floor}-qavat'), so
    // patching the rendered string corrupts the floor number instead.
    if (totalFloors == null) {
      return context.localization.listings_floor_only(floor);
    }
    return context.localization.listings_floor_of(floor, totalFloors);
  }

  String _tariffLabel(BuildContext context) {
    switch (listing.tariff.toLowerCase()) {
      case 'comfort':
        return context.localization.listings_tariff_comfort;
      case 'premium':
        return context.localization.listings_tariff_premium;
      case 'standard':
      default:
        return context.localization.listings_tariff_standard;
    }
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.currentTheme.bgSurfaceBase2,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor3.withOpacity(0.16),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                isFavorite ? TablerIcons.heart_filled : TablerIcons.heart,
                color: isFavorite
                    ? context.currentTheme.iconBrandPrimary
                    : context.currentTheme.textNeutralPrimary,
                size: 20,
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
