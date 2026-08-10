import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, this.imageUrl, this.size = 48});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final fallback = Container(
      color: context.currentTheme.bgBrandLight50,
      alignment: Alignment.center,
      child: Icon(
        TablerIcons.building_store,
        size: size * .46,
        color: context.currentTheme.iconBrandHover,
      ),
    );
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => fallback,
                errorWidget: (context, url, error) => fallback,
              ),
      ),
    );
  }
}
