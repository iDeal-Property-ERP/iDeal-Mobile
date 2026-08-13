import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';
import 'package:ideal_mobile/widgets/images/tiered_network_image.dart';
import 'package:photo_view/photo_view.dart';

class ChatImageFullScreenView extends StatelessWidget {
  const ChatImageFullScreenView({
    super.key,
    required this.path,
    this.previewUrl,
    this.displayUrl,
  });

  final String path;
  final String? previewUrl;
  final String? displayUrl;

  @override
  Widget build(BuildContext context) {
    final isLocal = path.startsWith('/') || path.startsWith('file:');
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(TablerIcons.x),
        ),
      ),
      body: isLocal
          ? PhotoView(
              imageProvider: FileImage(File(path)),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
            )
          : PhotoView.customChild(
              child: TieredNetworkImage(
                originalUrl: path,
                previewUrl: previewUrl,
                displayUrl: displayUrl,
                targetTier: ImageDisplayTier.original,
                priority: ImageLoadPriority.critical,
                fit: BoxFit.contain,
                loadingBuilder: (_) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorBuilder: (_) => const Center(
                  child: Icon(TablerIcons.photo_off, color: Colors.white54),
                ),
              ),
              childSize: MediaQuery.sizeOf(context),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
            ),
    );
  }
}
