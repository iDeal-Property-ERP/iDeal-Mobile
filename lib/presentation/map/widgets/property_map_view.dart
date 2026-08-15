import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_provider_selector.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/google_property_map.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/yandex_property_map.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

export 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
export 'package:ideal_mobile/presentation/map/services/property_map_provider_selector.dart';

typedef PropertyMapProviderViewBuilder =
    Widget Function(
      BuildContext context,
      PropertyMapProvider provider,
      PropertyMapView configuration,
      ValueChanged<PropertyMapProvider> onProviderReady,
      ValueChanged<PropertyMapProvider> onProviderFailed,
    );

class PropertyMapView extends StatefulWidget {
  const PropertyMapView({
    super.key,
    required this.markers,
    required this.initialCamera,
    this.interactive = false,
    this.fitMarkersOnCreate = false,
    this.controller,
    this.providerSelector,
    this.yandexLifecycle,
    this.providerViewBuilder,
    this.providerStartupTimeout = const Duration(seconds: 15),
    this.onProviderReady,
    this.onMarkerTap,
    this.onClusterTap,
    this.onMapTap,
    this.onCameraMove,
    this.onCameraIdle,
    this.onCameraSettled,
    this.onVisibleBoundsChanged,
  });

  final List<PropertyMapMarker> markers;
  final CameraTarget initialCamera;
  final bool interactive;
  final bool fitMarkersOnCreate;
  final PropertyMapController? controller;

  /// Injectable so tests and host screens do not depend on global SDK state.
  final PropertyMapProviderSelector? providerSelector;
  final YandexMapLifecycle? yandexLifecycle;

  /// Allows provider callbacks and failure paths to be tested without a
  /// platform view. Production callers normally leave this unset.
  @visibleForTesting
  final PropertyMapProviderViewBuilder? providerViewBuilder;

  @visibleForTesting
  final Duration providerStartupTimeout;

  final ValueChanged<PropertyMapProvider>? onProviderReady;
  final ValueChanged<int>? onMarkerTap;
  final ValueChanged<PropertyMapCluster>? onClusterTap;
  final ValueChanged<PropertyMapCoordinate>? onMapTap;
  final ValueChanged<PropertyMapCameraState>? onCameraMove;
  final ValueChanged<PropertyMapBounds>? onCameraIdle;
  final ValueChanged<PropertyMapCameraIdleState>? onCameraSettled;
  final ValueChanged<PropertyMapBounds>? onVisibleBoundsChanged;

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  final Set<PropertyMapProvider> _failedProviders = {};
  late Future<PropertyMapProvider?> _provider;
  Timer? _providerStartupTimer;
  int _selectionGeneration = 0;
  PropertyMapProvider? _activeProvider;

  YandexMapLifecycle get _yandexLifecycle =>
      widget.yandexLifecycle ?? MapkitService.instance;

  PropertyMapProviderSelector get _providerSelector =>
      widget.providerSelector ??
      PropertyMapProviderSelector.automatic(mapkitService: _yandexLifecycle);

  @override
  void initState() {
    super.initState();
    _provider = _selectProvider();
  }

  @override
  void didUpdateWidget(PropertyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.providerSelector != widget.providerSelector ||
        oldWidget.yandexLifecycle != widget.yandexLifecycle) {
      _failedProviders.clear();
      _provider = _selectProvider();
    }
  }

  @override
  void dispose() {
    _selectionGeneration++;
    _activeProvider = null;
    _providerStartupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PropertyMapProvider?>(
      future: _provider,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ColoredBox(color: context.currentTheme.bgNeutralLight100);
        }
        final provider = snapshot.data;
        final providerViewBuilder = widget.providerViewBuilder;
        if (provider != null && providerViewBuilder != null) {
          return providerViewBuilder(
            context,
            provider,
            widget,
            _handleProviderReady,
            _handleProviderFailed,
          );
        }
        return switch (provider) {
          PropertyMapProvider.yandex => YandexPropertyMap(
            key: const ValueKey(PropertyMapProvider.yandex),
            lifecycle: _yandexLifecycle,
            markers: widget.markers,
            initialCamera: widget.initialCamera,
            interactive: widget.interactive,
            fitMarkersOnCreate: widget.fitMarkersOnCreate,
            controller: widget.controller,
            onMapReady: _handleProviderReady,
            onProviderFailed: _handleProviderFailed,
            onMarkerTap: widget.onMarkerTap,
            onClusterTap: widget.onClusterTap,
            onMapTap: widget.onMapTap,
            onCameraMove: widget.onCameraMove,
            onCameraIdle: widget.onCameraIdle,
            onCameraSettled: widget.onCameraSettled,
            onVisibleBoundsChanged: widget.onVisibleBoundsChanged,
          ),
          PropertyMapProvider.google => GooglePropertyMap(
            key: const ValueKey(PropertyMapProvider.google),
            markers: widget.markers,
            initialCamera: widget.initialCamera,
            interactive: widget.interactive,
            fitMarkersOnCreate: widget.fitMarkersOnCreate,
            controller: widget.controller,
            onMapReady: _handleProviderReady,
            onProviderFailed: _handleProviderFailed,
            onMarkerTap: widget.onMarkerTap,
            onClusterTap: widget.onClusterTap,
            onMapTap: widget.onMapTap,
            onCameraMove: widget.onCameraMove,
            onCameraIdle: widget.onCameraIdle,
            onCameraSettled: widget.onCameraSettled,
            onVisibleBoundsChanged: widget.onVisibleBoundsChanged,
          ),
          null => const PropertyMapUnavailable(),
        };
      },
    );
  }

  Future<PropertyMapProvider?> _selectProvider() {
    _providerStartupTimer?.cancel();
    _activeProvider = null;
    final generation = ++_selectionGeneration;
    final selection = _providerSelector.select(excluding: _failedProviders);
    unawaited(
      selection.then((provider) {
        if (!mounted || generation != _selectionGeneration) return;
        _activeProvider = provider;
        _providerStartupTimer?.cancel();
        if (provider != null) {
          _providerStartupTimer = Timer(
            widget.providerStartupTimeout,
            () => _handleProviderFailed(provider),
          );
        }
      }),
    );
    return selection;
  }

  void _handleProviderReady(PropertyMapProvider provider) {
    if (_activeProvider != provider) return;
    _providerStartupTimer?.cancel();
    widget.onProviderReady?.call(provider);
  }

  void _handleProviderFailed(PropertyMapProvider provider) {
    if (!mounted ||
        _activeProvider != provider ||
        _failedProviders.contains(provider)) {
      return;
    }
    _providerStartupTimer?.cancel();
    setState(() {
      _failedProviders.add(provider);
      _provider = _selectProvider();
    });
  }
}

class PropertyMapUnavailable extends StatelessWidget {
  const PropertyMapUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.currentTheme.bgNeutralLight100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.map_off,
              color: context.currentTheme.textNeutralSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.listing_detail_map_unavailable,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
