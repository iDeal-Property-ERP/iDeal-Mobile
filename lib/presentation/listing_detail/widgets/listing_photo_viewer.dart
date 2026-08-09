import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _safeIndex(widget.initialIndex, widget.photos.length);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            PageView.builder(
              controller: _pageController,
              itemCount: photos.isEmpty ? 1 : photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final imageUrl = photos.isEmpty ? null : photos[index].imageUrl;
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(32),
                  child: SizedBox.expand(
                    child: ListingCardImage(imageUrl: imageUrl),
                  ),
                );
              },
            ),
            Positioned(
              top: 12,
              left: 16,
              child: _ViewerCircleButton(
                icon: TablerIcons.x,
                label: MaterialLocalizations.of(context).closeButtonLabel,
                onPressed: () => Navigator.of(context).pop(),
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
}

class _ViewerCircleButton extends StatelessWidget {
  const _ViewerCircleButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
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
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            return GestureDetector(
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
                  child: ListingCardImage(imageUrl: photos[index].imageUrl),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
