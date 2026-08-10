import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:photo_view/photo_view.dart';

class ChatImageFullScreenView extends StatelessWidget {
  const ChatImageFullScreenView({super.key, required this.path});

  final String path;

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
      body: PhotoView(
        imageProvider: _imageProvider(isLocal),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 4,
        loadingBuilder: (_, _) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        errorBuilder: (_, _, _) => const Center(
          child: Icon(TablerIcons.photo_off, color: Colors.white54),
        ),
      ),
    );
  }

  ImageProvider _imageProvider(bool isLocal) {
    if (AppEnvironment.isTestEnvironment) {
      return AssetImage(Assets.test.images.testImage.path);
    }
    if (isLocal) {
      return FileImage(File(path));
    }
    return CachedNetworkImageProvider(path);
  }
}
