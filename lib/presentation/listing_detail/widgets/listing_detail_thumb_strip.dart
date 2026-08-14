import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_photo_viewer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:shimmer/shimmer.dart';

class ListingDetailThumbStrip extends StatelessWidget {
  const ListingDetailThumbStrip({
    super.key,
    required this.detail,
    this.showLoadingPlaceholder = false,
  });

  final ListingDetail detail;
  final bool showLoadingPlaceholder;

  @override
  Widget build(BuildContext context) {
    final photos = detail.photos;
    if (photos.length < 2) {
      return showLoadingPlaceholder
          ? const _ListingDetailThumbStripLoading()
          : const SizedBox.shrink();
    }

    final visibleCount = photos.length > 4 ? 4 : photos.length;

    return SizedBox(
      height: 76,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 4),
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: visibleCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final hasMorePhotos = photos.length > 4 && index == 3;
          return GestureDetector(
            onTap: () => _openViewer(context, hasMorePhotos ? 3 : index),
            child: SizedBox(
              width: 84,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ListingCardImage(
                      imageUrl: photos[index].imageUrl,
                      previewUrl: photos[index].previewUrl,
                      displayUrl: photos[index].displayUrl,
                    ),
                    if (hasMorePhotos)
                      ColoredBox(
                        color: Colors.black.withValues(alpha: 0.50),
                        child: Center(
                          child: Text(
                            context.localization.listing_detail_more_photos(
                              photos.length - 3,
                            ),
                            style: AppTextStyles.p4SemiBold.copyWith(
                              color: context.currentTheme.textNeutralWhite,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingPhotoViewer(
          photos: detail.photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ListingDetailThumbStripLoading extends StatelessWidget {
  const _ListingDetailThumbStripLoading();

  @override
  Widget build(BuildContext context) {
    final baseColor = context.currentTheme.bgNeutralLight100;
    return SizedBox(
      key: const ValueKey('listing_detail_thumb_strip_loading'),
      height: 76,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: baseColor.withValues(alpha: 0.6),
        child: ListView.separated(
          padding: const EdgeInsets.only(
            left: 16,
            top: 12,
            right: 16,
            bottom: 4,
          ),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, _) => SizedBox(
            width: 84,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(color: baseColor),
            ),
          ),
        ),
      ),
    );
  }
}
