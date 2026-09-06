import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

/// Data model representing a single promotional trust banner.
class HomeBannerItem {
  const HomeBannerItem({
    required this.title,
    required this.description,
    required this.icon,
    this.id,
    this.tag,
    this.sortOrder,
  });

  final int? id;
  final String title;
  final String description;
  final IconData icon;
  final String? tag;
  final int? sortOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeBannerItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          icon == other.icon &&
          tag == other.tag &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      tag.hashCode ^
      sortOrder.hashCode;
}

/// Horizontally scrollable banner carousel placed directly below search bar.
///
/// Features:
/// - Spacious two-column card with bold title and description.
/// - Right-side layered visual graphic container.
/// - Supports multiple banners with horizontal paging.
/// - Auto-slides every 5 seconds when idle.
/// - Touch/drag gestures immediately reset the 5-second timer.
/// - Loop rewind animation back to first banner when last is reached.
/// - Manual swiping bounds-limited to the last banner.
/// - Dot indicator below carousel with an expanded active pill indicator.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    this.banners,
    this.autoSlideDuration = const Duration(seconds: 5),
    this.pageController,
    super.key,
  });

  /// Custom banners for testing or override; defaults to 4 localized banners.
  final List<HomeBannerItem>? banners;

  /// Duration before auto-sliding to next banner. Set to Duration.zero to stop.
  final Duration autoSlideDuration;

  /// Optional [PageController] override, useful for widget tests.
  final PageController? pageController;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _pageController;
  late final bool _ownsController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.pageController == null;
    _pageController = widget.pageController ?? PageController();
    _startTimer();
  }

  @override
  void didUpdateWidget(HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoSlideDuration != widget.autoSlideDuration) {
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    if (_ownsController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    if (widget.autoSlideDuration == Duration.zero) return;
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(widget.autoSlideDuration, (_) {
      _onAutoSlideTick();
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  void _onAutoSlideTick() {
    if (!mounted || !_pageController.hasClients) return;

    final bannerCount = _resolveBanners(context).length;
    if (bannerCount <= 1) return;

    if (_currentPage < bannerCount - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      // Loop rewind back to index 0 with a smooth longer transition
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  List<HomeBannerItem> _resolveBanners(BuildContext context) {
    if (widget.banners != null) return widget.banners!;
    final loc = context.localization;

    return [
      HomeBannerItem(
        title: loc.home_banner_actual_title,
        description: loc.home_banner_actual_desc,
        icon: TablerIcons.circle_check,
      ),
      HomeBannerItem(
        title: loc.home_banner_verified_title,
        description: loc.home_banner_verified_desc,
        icon: TablerIcons.shield_check,
      ),
      HomeBannerItem(
        title: loc.home_banner_viewings_title,
        description: loc.home_banner_viewings_desc,
        icon: TablerIcons.calendar_event,
      ),
      HomeBannerItem(
        title: loc.home_banner_legal_title,
        description: loc.home_banner_legal_desc,
        icon: TablerIcons.file_certificate,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final banners = _resolveBanners(context);
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: keys.homePage.bannerCarouselKey,
          height: 140,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                // User started swiping manually — reset the 5s timer
                _resetTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _resetTimer();
              },
              itemBuilder: (context, index) {
                return _BannerCard(item: banners[index]);
              },
            ),
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            key: keys.homePage.bannerIndicatorKey,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isSelected = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 24.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.currentTheme.bgBrandDefault
                      : context.currentTheme.strokeNeutralDisabled,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.item});

  final HomeBannerItem item;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColors = isLight
        ? const [Color(0xFF2251E6), Color(0xFF183DBB)]
        : const [Color(0xFF0F224A), Color(0xFF08132B)];
    final shadowColor = isLight
        ? const Color(0xFF183DBB).withValues(alpha: 0.25)
        : const Color(0xFF08132B).withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.tag != null && item.tag!.trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          TablerIcons.sparkles,
                          size: 13,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.tag!,
                          style: AppTextStyles.p4SemiBold.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  item.title,
                  style: AppTextStyles.h6Bold.copyWith(
                    color: AppColors.white,
                    fontSize: 17.5,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: AppTextStyles.p3Regular.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.35,
                  ),
                  maxLines: item.tag != null && item.tag!.trim().isNotEmpty
                      ? 2
                      : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(item.icon, size: 32, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
