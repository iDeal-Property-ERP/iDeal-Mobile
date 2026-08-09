// The package exposes these Flutter bindings under `src` only.
// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_pin.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;

import 'package:yandex_maps_mapkit/ui_view.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';

class PropertyMapMarker {
  const PropertyMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final int id;
  final double latitude;
  final double longitude;
  final String? label;
}

class CameraTarget {
  const CameraTarget({
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
  });

  final double latitude;
  final double longitude;
  final double zoom;
}

class PropertyMapView extends StatefulWidget {
  const PropertyMapView({
    super.key,
    required this.markers,
    required this.initialCamera,
    this.interactive = false,
    this.onMarkerTap,
  });

  final List<PropertyMapMarker> markers;
  final CameraTarget initialCamera;
  final bool interactive;
  final ValueChanged<int>? onMarkerTap;

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  late final AppLifecycleListener _appLifecycleListener;
  late final _MarkerTapListener _markerTapListener;
  late final Future<void> _initialization;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    _initialization = MapkitService.instance.initialize();
    _markerTapListener = _MarkerTapListener(widget.onMarkerTap);
    _appLifecycleListener = AppLifecycleListener(
      onResume: _start,
      onInactive: _stop,
      onPause: _stop,
      onDetach: _stop,
    );
  }

  @override
  void dispose() {
    _stop();
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, _) {
        if (!MapkitService.instance.isAvailable) {
          return const _MapUnavailable();
        }

        // MapKit requires this before its native map view is created. Calling
        // it only from `onMapCreated` is too late for the first frame.
        _start();

        return YandexMap(
          platformViewType: PlatformViewType.Hybrid,
          onMapCreated: (mapWindow) {
            final map = mapWindow.map;
            map
              ..move(
                mapkit.CameraPosition(
                  mapkit.Point(
                    latitude: widget.initialCamera.latitude,
                    longitude: widget.initialCamera.longitude,
                  ),
                  zoom: widget.initialCamera.zoom,
                  azimuth: 0,
                  tilt: 0,
                ),
              )
              ..nightModeEnabled =
                  Theme.of(context).brightness == Brightness.dark
              ..zoomGesturesEnabled = widget.interactive
              ..scrollGesturesEnabled = widget.interactive
              ..rotateGesturesEnabled = widget.interactive
              ..tiltGesturesEnabled = widget.interactive;

            for (final marker in widget.markers) {
              final placemark = map.mapObjects.addPlacemark()
                ..geometry = mapkit.Point(
                  latitude: marker.latitude,
                  longitude: marker.longitude,
                )
                ..userData = marker.id
                ..setView(
                  ViewProvider(
                    builder: () => PropertyMapPin(
                      backgroundColor: context.currentTheme.bgBrandDefault,
                      iconColor: context.currentTheme.iconBrandPrimary,
                    ),
                  ),
                );

              if (widget.onMarkerTap != null) {
                placemark.addTapListener(_markerTapListener);
              }
            }
          },
        );
      },
    );
  }

  void _start() {
    if (_isStarted || !MapkitService.instance.isAvailable) return;
    _isStarted = true;
    MapkitService.instance.start();
  }

  void _stop() {
    if (!_isStarted) return;
    _isStarted = false;
    MapkitService.instance.stop();
  }
}

class _MarkerTapListener implements mapkit.MapObjectTapListener {
  const _MarkerTapListener(this.onMarkerTap);

  final ValueChanged<int>? onMarkerTap;

  @override
  bool onMapObjectTap(mapkit.MapObject mapObject, mapkit.Point point) {
    final id = mapObject.userData;
    if (id is int) onMarkerTap?.call(id);
    return true;
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable();

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
