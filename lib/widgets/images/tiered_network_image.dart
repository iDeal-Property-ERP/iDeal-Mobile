import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';

enum ImageDisplayTier { preview, display, original }

/// Selects responsive URLs while retaining the legacy original as the final
/// fallback. It is public so the selection contract is easily unit-tested.
class ImageTierUrls {
  const ImageTierUrls({
    required this.originalUrl,
    this.previewUrl,
    this.displayUrl,
  });

  final String? originalUrl;
  final String? previewUrl;
  final String? displayUrl;

  List<String> candidates(ImageDisplayTier targetTier) {
    final hasResponsiveVariants = _usable(previewUrl) || _usable(displayUrl);
    final ordered = switch (targetTier) {
      ImageDisplayTier.preview || ImageDisplayTier.display =>
        hasResponsiveVariants ? [previewUrl, displayUrl] : [originalUrl],
      ImageDisplayTier.original => [displayUrl, originalUrl, previewUrl],
    };
    return ordered
        .map((url) => url?.trim())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  bool _usable(String? value) => value?.trim().isNotEmpty ?? false;
}

/// Small transition model used by [TieredNetworkImage]. A failed higher tier
/// never clears [bestLoadedUrl], so an already visible display rendition wins.
class ImageTierProgress {
  ImageTierProgress({
    required this.urls,
    required this.targetTier,
    required this.upgradeFromFirst,
  });

  final List<String> urls;
  final ImageDisplayTier targetTier;
  final bool upgradeFromFirst;
  int index = 0;
  String? bestLoadedUrl;

  String? get currentUrl => index < urls.length ? urls[index] : null;

  bool completeSuccess() {
    bestLoadedUrl = currentUrl;
    if (index != 0 || !upgradeFromFirst) {
      return false;
    }
    index++;
    return true;
  }

  bool completeFailure() {
    if (bestLoadedUrl != null) return false;
    index++;
    return currentUrl != null;
  }
}

/// Public-image widget with responsive tiers. It shows a low-cost preview
/// first where available, then upgrades without blanking a successfully loaded
/// image if the requested higher tier fails.
class TieredNetworkImage extends StatefulWidget {
  const TieredNetworkImage({
    super.key,
    required this.originalUrl,
    this.previewUrl,
    this.displayUrl,
    this.targetTier = ImageDisplayTier.display,
    this.priority = ImageLoadPriority.normal,
    this.fit = BoxFit.cover,
    this.loadingBuilder,
    this.errorBuilder,
    this.loader,
  });

  final String? originalUrl;
  final String? previewUrl;
  final String? displayUrl;
  final ImageDisplayTier targetTier;
  final ImageLoadPriority priority;
  final BoxFit fit;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final AppImageLoader? loader;

  @override
  State<TieredNetworkImage> createState() => _TieredNetworkImageState();
}

class _TieredNetworkImageState extends State<TieredNetworkImage> {
  ImageDownloadHandle<File>? _handle;
  File? _file;
  bool _loading = false;
  late ImageTierProgress _progress;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(covariant TieredNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.originalUrl != widget.originalUrl ||
        oldWidget.previewUrl != widget.previewUrl ||
        oldWidget.displayUrl != widget.displayUrl ||
        oldWidget.targetTier != widget.targetTier) {
      _restart();
    }
  }

  @override
  void dispose() {
    _handle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnvironment.isTestEnvironment) {
      return Image.asset(Assets.test.images.testImage.path, fit: widget.fit);
    }
    final file = _file;
    if (file == null) {
      if (_loading) {
        return widget.loadingBuilder?.call(context) ?? const SizedBox();
      }
      return widget.errorBuilder?.call(context) ?? const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final width = _physicalDimension(constraints.maxWidth, dpr);
        final height = _physicalDimension(constraints.maxHeight, dpr);
        final provider = ResizeImage(
          FileImage(file),
          width: width,
          height: height,
        );
        return Image(image: provider, fit: widget.fit);
      },
    );
  }

  int? _physicalDimension(double logicalPixels, double devicePixelRatio) {
    if (!logicalPixels.isFinite || logicalPixels <= 0) return null;
    return (logicalPixels * devicePixelRatio).round();
  }

  void _restart() {
    _handle?.cancel();
    _file = null;
    final candidates = _tierCandidates();
    _progress = ImageTierProgress(
      urls: candidates,
      targetTier: widget.targetTier,
      upgradeFromFirst:
          candidates.length > 1 &&
          ((widget.targetTier == ImageDisplayTier.display &&
                  candidates.first == widget.previewUrl?.trim()) ||
              (widget.targetTier == ImageDisplayTier.original &&
                  candidates.first == widget.displayUrl?.trim())),
    );
    if (candidates.isEmpty) return;
    _loadCurrent();
  }

  List<String> _tierCandidates() {
    return ImageTierUrls(
      originalUrl: widget.originalUrl,
      previewUrl: widget.previewUrl,
      displayUrl: widget.displayUrl,
    ).candidates(widget.targetTier);
  }

  void _loadCurrent() {
    final url = _progress.currentUrl;
    if (url == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final handle = (widget.loader ?? AppImageLoader.instance).load(
      url,
      priority: widget.priority,
    );
    _handle = handle;
    handle.future.then(
      (file) {
        if (!mounted || _handle != handle) return;
        setState(() {
          _file = file;
          _loading = false;
        });
        if (_progress.completeSuccess()) {
          _loadCurrent();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || _handle != handle) return;
        // A previously loaded preview/display stays rendered if a higher tier
        // fails. Otherwise keep trying the legacy original fallback.
        if (!_progress.completeFailure()) {
          setState(() => _loading = false);
          return;
        }
        _loadCurrent();
      },
    );
  }
}
