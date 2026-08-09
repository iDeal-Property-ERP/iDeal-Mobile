import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:shimmer/shimmer.dart';

class ListingCardImage extends StatelessWidget {
  const ListingCardImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
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

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: context.currentTheme.bgNeutralLight100,
        highlightColor: context.currentTheme.bgNeutralLight100.withValues(
          alpha: 0.6,
        ),
        child: ColoredBox(color: context.currentTheme.bgNeutralLight100),
      ),
      errorWidget: (context, url, error) => ColoredBox(
        color: context.currentTheme.bgNeutralLight100,
        child: Icon(
          Icons.error_outline,
          color: context.currentTheme.bgErrorHover,
        ),
      ),
    );
  }
}
