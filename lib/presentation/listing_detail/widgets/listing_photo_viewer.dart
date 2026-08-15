import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';
import 'package:ideal_mobile/widgets/images/tiered_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

class ListingPhotoViewer extends StatefulWidget {
  const ListingPhotoViewer({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  final List<ListingPhoto> photos;
  final int initialIndex;

  @override
  State<ListingPhotoViewer> createState() => _ListingPhotoViewerState();
}

class _ListingPhotoViewerState extends State<ListingPhotoViewer> {
  late final PageController _pageController;
  late final List<PhotoViewController> _photoControllers;
  late final List<PhotoViewScaleStateController> _scaleStateControllers;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _safeIndex(widget.initialIndex, widget.photos.length);
    _pageController = PageController(initialPage: _currentIndex);
    _photoControllers = List.generate(
      widget.photos.length,
      (_) => PhotoViewController(),
    );
    _scaleStateControllers = List.generate(
      widget.photos.length,
      (_) => PhotoViewScaleStateController(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _photoControllers) {
      controller.dispose();
    }
    for (final controller in _scaleStateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => PhotoViewGallery.builder(
                pageController: _pageController,
                itemCount: photos.isEmpty ? 1 : photos.length,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                onPageChanged: _handlePageChanged,
                builder: (context, index) {
                  if (photos.isEmpty) {
                    return PhotoViewGalleryPageOptions.customChild(
                      child: const SizedBox.expand(
                        child: ListingCardImage(
                          imageUrl: null,
                          fit: BoxFit.contain,
                        ),
                      ),
                      childSize: constraints.biggest,
                    );
                  }

                  return PhotoViewGalleryPageOptions.customChild(
                    child: TieredNetworkImage(
                      originalUrl: photos[index].imageUrl,
                      previewUrl: photos[index].previewUrl,
                      displayUrl: photos[index].displayUrl,
                      targetTier: ImageDisplayTier.original,
                      priority: index == _currentIndex
                          ? ImageLoadPriority.critical
                          : ImageLoadPriority.high,
                      fit: BoxFit.contain,
                      loadingBuilder: _buildLoadingChild,
                      errorBuilder: _buildErrorChild,
                    ),
                    childSize: constraints.biggest,
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 4,
                    controller: _photoControllers[index],
                    scaleStateController: _scaleStateControllers[index],
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              child: AppTopBarAction(
                icon: TablerIcons.x,
                tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                onPressed: () => Navigator.of(context).pop(),
                style: AppTopBarActionStyle.overlay,
              ),
            ),
            if (photos.isNotEmpty)
              Positioned(
                top: 12,
                right: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      context.localization.listing_detail_photo_counter(
                        _currentIndex + 1,
                        photos.length,
                      ),
                      style: AppTextStyles.p4SemiBold.copyWith(
                        color: context.currentTheme.textNeutralWhite,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentCaption(photos) case final caption?)
              Positioned(
                left: 16,
                right: 16,
                bottom: photos.length > 1 ? 92 : 12,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.p3Medium.copyWith(
                          color: context.currentTheme.textNeutralWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (photos.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ViewerThumbStrip(
                  photos: photos,
                  selectedIndex: _currentIndex,
                  onSelected: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The caption of the photo on screen, or null when it has none.
  String? _currentCaption(List<ListingPhoto> photos) {
    if (photos.isEmpty || _currentIndex >= photos.length) return null;
    final caption = photos[_currentIndex].caption?.trim();
    return (caption == null || caption.isEmpty) ? null : caption;
  }

  int _safeIndex(int index, int length) {
    if (length <= 0 || index < 0) return 0;
    if (index >= length) return length - 1;
    return index;
  }

  void _handlePageChanged(int index) {
    final previousIndex = _currentIndex;
    setState(() => _currentIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resetScale(previousIndex);
      _resetScale(index);
    });
  }

  void _resetScale(int index) {
    if (index < 0 || index >= _scaleStateControllers.length) return;
    _photoControllers[index].reset();
    _scaleStateControllers[index].reset();
  }

  Widget _buildLoadingChild(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.currentTheme.bgNeutralLight100,
      highlightColor: context.currentTheme.bgNeutralLight100.withValues(
        alpha: 0.6,
      ),
      child: ColoredBox(color: context.currentTheme.bgNeutralLight100),
    );
  }

  Widget _buildErrorChild(BuildContext context) {
    return ColoredBox(
      color: context.currentTheme.bgNeutralLight100,
      child: Icon(
        Icons.error_outline,
        color: context.currentTheme.bgErrorHover,
      ),
    );
  }
}

class _ViewerThumbStrip extends StatelessWidget {
  const _ViewerThumbStrip({
    required this.photos,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ListingPhoto> photos;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55)),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          scrollDirection: Axis.horizontal,
          itemCount: photos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            return GestureDetector(
              key: Key('listing_photo_viewer_thumbnail_$index'),
              onTap: () => onSelected(index),
              child: Container(
                width: 64,
                height: 56,
                padding: EdgeInsets.all(selected ? 2 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: selected
                      ? Border.all(
                          color: context.currentTheme.strokeBrandDefault,
                          width: 2,
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(selected ? 6 : 10),
                  child: ListingCardImage(
                    imageUrl: photos[index].imageUrl,
                    previewUrl: photos[index].previewUrl,
                    displayUrl: photos[index].displayUrl,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
