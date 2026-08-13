import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';
import 'package:ideal_mobile/widgets/images/tiered_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ListingCardImage extends StatelessWidget {
  const ListingCardImage({
    super.key,
    required this.imageUrl,
    this.previewUrl,
    this.displayUrl,
    this.targetTier = ImageDisplayTier.display,
    this.priority = ImageLoadPriority.normal,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final String? previewUrl;
  final String? displayUrl;
  final ImageDisplayTier targetTier;
  final ImageLoadPriority priority;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl?.trim().isNotEmpty ?? false;

    if (AppEnvironment.isTestEnvironment) {
      return Image.asset(Assets.test.images.testImage.path, fit: fit);
    }

    if (!hasImage) {
      return ColoredBox(
        color: context.currentTheme.bgNeutralLight100,
        child: Center(
          child: Icon(
            TablerIcons.building,
            color: context.currentTheme.textNeutralDisable,
            size: 40,
          ),
        ),
      );
    }

    return TieredNetworkImage(
      originalUrl: imageUrl,
      previewUrl: previewUrl,
      displayUrl: displayUrl,
      targetTier: targetTier,
      priority: priority,
      fit: fit,
      loadingBuilder: (context) => Shimmer.fromColors(
        baseColor: context.currentTheme.bgNeutralLight100,
        highlightColor: context.currentTheme.bgNeutralLight100.withValues(
          alpha: 0.6,
        ),
        child: ColoredBox(color: context.currentTheme.bgNeutralLight100),
      ),
      errorBuilder: (context) => ColoredBox(
        color: context.currentTheme.bgNeutralLight100,
        child: Icon(
          Icons.error_outline,
          color: context.currentTheme.bgErrorHover,
        ),
      ),
    );
  }
}
