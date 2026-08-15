import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class NetworkImageScreen extends StatelessWidget {
  const NetworkImageScreen({super.key, required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar.page(title: ''),
      body: Center(
        child: Hero(
          tag: link,
          child: CachedNetworkImage(
            imageUrl: link,
            progressIndicatorBuilder: (context, url, progress) {
              return const Center(child: CircularProgressIndicator());
            },
            errorWidget: (context, url, error) => Center(
              child: Icon(
                Icons.error,
                color: context.currentTheme.strokeBrandPressed,
              ),
            ),
            imageBuilder: (context, imageProvider) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider, fit: .contain),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
