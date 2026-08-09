import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_photo_viewer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailHero extends StatefulWidget {
  const ListingDetailHero({
    super.key,
    required this.detail,
    this.initialIndex = 0,
  });

  final ListingDetail detail;
  final int initialIndex;

  @override
  State<ListingDetailHero> createState() => _ListingDetailHeroState();
}

class _ListingDetailHeroState extends State<ListingDetailHero> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _safeIndex(
      widget.initialIndex,
      widget.detail.photos.length,
    );
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant ListingDetailHero oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextIndex = _safeIndex(_currentIndex, widget.detail.photos.length);
    if (nextIndex == _currentIndex) return;

    _currentIndex = nextIndex;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.detail.photos;

    return SizedBox(
      key: keys.listingDetail.hero,
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: photos.isEmpty ? 1 : photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final imageUrl = photos.isEmpty ? null : photos[index].imageUrl;
              return GestureDetector(
                onTap: photos.isEmpty ? null : () => _openViewer(context),
                child: ClipRect(child: ListingCardImage(imageUrl: imageUrl)),
              );
            },
          ),
          Positioned(
            top: 12,
            left: 16,
            child: _HeroCircleButton(
              icon: TablerIcons.arrow_left,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: Row(
              children: [
                _HeroCircleButton(
                  icon: TablerIcons.share,
                  label: context.localization.listing_detail_share,
                  onPressed: () {
                    // TODO(listing-detail): wire share
                  },
                ),
                const SizedBox(width: 8),
                _HeroCircleButton(
                  icon: TablerIcons.heart,
                  label: context.localization.save,
                  onPressed: () {
                    // TODO(listing-detail): wire favourite
                  },
                ),
              ],
            ),
          ),
          if (photos.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 12,
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
        ],
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingPhotoViewer(
          photos: widget.detail.photos,
          initialIndex: _currentIndex,
        ),
      ),
    );
  }

  int _safeIndex(int index, int length) {
    if (length <= 0 || index < 0) return 0;
    if (index >= length) return length - 1;
    return index;
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
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
