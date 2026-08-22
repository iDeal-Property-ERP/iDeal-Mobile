// The package exposes these Flutter bindings under `src` only.
// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_attachment_guard.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_pin.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:yandex_maps_mapkit/mapkit.dart' as mapkit;
import 'package:yandex_maps_mapkit/ui_view.dart';
import 'package:yandex_maps_mapkit/yandex_map.dart';

class YandexPropertyMap extends StatefulWidget {
  const YandexPropertyMap({
    super.key,
    required this.lifecycle,
    required this.markers,
    required this.initialCamera,
    required this.interactive,
    required this.fitMarkersOnCreate,
    this.controller,
    this.onMapReady,
    this.onProviderFailed,
    this.onMarkerTap,
    this.onClusterTap,
    this.onMapTap,
    this.onCameraMove,
    this.onCameraIdle,
    this.onCameraSettled,
    this.onVisibleBoundsChanged,
  });

  final YandexMapLifecycle lifecycle;
  final List<PropertyMapMarker> markers;
  final CameraTarget initialCamera;
  final bool interactive;
  final bool fitMarkersOnCreate;
  final PropertyMapController? controller;
  final ValueChanged<PropertyMapProvider>? onMapReady;
  final ValueChanged<PropertyMapProvider>? onProviderFailed;
  final ValueChanged<int>? onMarkerTap;
  final ValueChanged<PropertyMapCluster>? onClusterTap;
  final ValueChanged<PropertyMapCoordinate>? onMapTap;
  final ValueChanged<PropertyMapCameraState>? onCameraMove;
  final ValueChanged<PropertyMapBounds>? onCameraIdle;
  final ValueChanged<PropertyMapCameraIdleState>? onCameraSettled;
  final ValueChanged<PropertyMapBounds>? onVisibleBoundsChanged;

  @override
  State<YandexPropertyMap> createState() => _YandexPropertyMapState();
}

class _YandexPropertyMapState extends State<YandexPropertyMap>
    implements PropertyMapControllerDelegate {
  late final AppLifecycleListener _appLifecycleListener;
  late final _MarkerTapListener _markerTapListener;
  late final _ClusterListener _clusterListener;
  late final _ClusterTapListener _clusterTapListener;
  late final _CameraListener _cameraListener;
  late final _InputListener _inputListener;
  late PropertyMapMarkerSnapshot _markerSnapshot;
  final PropertyMapAttachmentGuard _attachmentGuard =
      PropertyMapAttachmentGuard();
  mapkit.Map? _map;
  bool _cameraListenerAttached = false;
  bool _inputListenerAttached = false;
  final YandexMapLifecycleLease _lifecycleLease = YandexMapLifecycleLease();

  @override
  void initState() {
    super.initState();
    _markerTapListener = _MarkerTapListener(_handleMarkerTap);
    _clusterListener = _ClusterListener(_handleClusterAdded);
    _clusterTapListener = _ClusterTapListener(_handleClusterTap);
    _cameraListener = _CameraListener(_handleCameraChanged);
    _inputListener = _InputListener(_handleMapTap);
    _markerSnapshot = PropertyMapMarkerSnapshot.capture(widget.markers);
    _appLifecycleListener = AppLifecycleListener(
      onResume: _start,
      onInactive: _stop,
      onPause: _stop,
      onDetach: _stop,
    );
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(YandexPropertyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
    if (_markerSnapshot.differsFrom(widget.markers)) {
      _markerSnapshot = PropertyMapMarkerSnapshot.capture(widget.markers);
      _replaceMarkers();
    }
    if (oldWidget.lifecycle != widget.lifecycle) {
      _stop();
      _start();
    }
    _configureMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureMap();
    _replaceMarkers();
  }

  @override
  void dispose() {
    _attachmentGuard.invalidate();
    widget.controller?.detach(this);
    final map = _map;
    _map = null;
    if (map != null) {
      _releaseMap(
        map,
        cameraListenerAttached: _cameraListenerAttached,
        inputListenerAttached: _inputListenerAttached,
      );
    }
    _cameraListenerAttached = false;
    _inputListenerAttached = false;
    _stop();
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _start();
    final map = _map;
    if (map != null && map.isValid()) {
      map.nightModeEnabled = Theme.of(context).brightness == Brightness.dark;
    }

    return YandexMap(
      platformViewType: PlatformViewType.Hybrid,
      onMapCreated: _onMapCreated,
    );
  }

  void _onMapCreated(mapkit.MapWindow mapWindow) {
    final map = mapWindow.map;
    if (!mounted || !_attachmentGuard.acceptAttachment()) {
      _releaseMap(
        map,
        cameraListenerAttached: false,
        inputListenerAttached: false,
      );
      return;
    }

    final previousMap = _map;
    if (identical(previousMap, map) &&
        (_cameraListenerAttached || _inputListenerAttached)) {
      return;
    }
    if (previousMap != null && !identical(previousMap, map)) {
      _releaseMap(
        previousMap,
        cameraListenerAttached: _cameraListenerAttached,
        inputListenerAttached: _inputListenerAttached,
      );
      _cameraListenerAttached = false;
      _inputListenerAttached = false;
    }

    try {
      _map = map;
      map.addCameraListener(_cameraListener);
      _cameraListenerAttached = true;
      map.addInputListener(_inputListener);
      _inputListenerAttached = true;
      map.move(_cameraPosition(widget.initialCamera));
      _configureMap();
      _replaceMarkers();
      if (widget.fitMarkersOnCreate && _markerSnapshot.markers.length > 1) {
        unawaited(
          fitBounds(
            PropertyMapBounds.fromCoordinates(
              _markerSnapshot.markers.map((marker) => marker.coordinate),
            ),
          ),
        );
      }
      if (mounted && _attachmentGuard.isActive) {
        widget.onMapReady?.call(PropertyMapProvider.yandex);
      }
    } on Object {
      _releaseMap(
        map,
        cameraListenerAttached: _cameraListenerAttached,
        inputListenerAttached: _inputListenerAttached,
      );
      if (identical(_map, map)) _map = null;
      _cameraListenerAttached = false;
      _inputListenerAttached = false;
      if (mounted && _attachmentGuard.isActive) {
        widget.onProviderFailed?.call(PropertyMapProvider.yandex);
      }
    }
  }

  void _configureMap() {
    final map = _map;
    if (map == null || !map.isValid()) return;
    map
      ..nightModeEnabled = Theme.of(context).brightness == Brightness.dark
      ..zoomGesturesEnabled = widget.interactive
      ..scrollGesturesEnabled = widget.interactive
      ..rotateGesturesEnabled = widget.interactive
      ..tiltGesturesEnabled = widget.interactive;
  }

  void _replaceMarkers() {
    final map = _map;
    if (map == null || !map.isValid()) return;
    map.mapObjects.clear();
    final markers = _markerSnapshot.markers;
    final clusterable = markers.where((marker) => marker.clusterable);
    final individual = markers.where((marker) => !marker.clusterable);

    if (clusterable.isNotEmpty) {
      final collection = map.mapObjects.addClusterizedPlacemarkCollection(
        _clusterListener,
      );
      for (final marker in clusterable) {
        _configurePlacemark(collection.addPlacemark(), marker);
      }
      collection.clusterPlacemarks(clusterRadius: 60, minZoom: 17);
    }

    for (final marker in individual) {
      _configurePlacemark(map.mapObjects.addPlacemark(), marker);
    }
  }

  void _configurePlacemark(
    mapkit.PlacemarkMapObject placemark,
    PropertyMapMarker marker,
  ) {
    placemark
      ..geometry = _point(marker.coordinate)
      ..userData = marker.id
      ..setView(
        ViewProvider(
          builder: () => Semantics(
            label: marker.accessibilityLabel,
            container: true,
            button: widget.onMarkerTap != null,
            onTap: widget.onMarkerTap == null
                ? null
                : () => _handleMarkerTap(marker.id),
            excludeSemantics: marker.accessibilityLabel != null,
            child: PropertyMapPin(
              label: marker.priceLabel,
              isSelected: marker.isSelected,
              backgroundColor: context.currentTheme.bgBrandDefault,
              iconColor: Theme.of(context).brightness == Brightness.dark
                  ? context.currentTheme.iconBrandPrimary
                  : context.currentTheme.textNeutralWhite,
            ),
          ),
        ),
      );
    placemark.addTapListener(_markerTapListener);
  }

  void _handleMarkerTap(int id) => widget.onMarkerTap?.call(id);

  void _handleClusterAdded(mapkit.Cluster cluster) {
    final markersById = {
      for (final marker in _markerSnapshot.markers) marker.id: marker,
    };
    final clusteredMarkers = cluster.placemarks
        .map((placemark) => placemark.userData)
        .whereType<int>()
        .map((id) => markersById[id])
        .whereType<PropertyMapMarker>()
        .toList(growable: false);
    final accessibility = PropertyMapClusterAccessibilityMetadata.fromMarkers(
      clusteredMarkers,
    );
    cluster.appearance.setView(
      ViewProvider(
        builder: () => Semantics(
          // This is the best metadata available to a Flutter-rendered Yandex
          // placemark. Native screen-reader behavior needs device validation.
          label: accessibility.label,
          container: true,
          button: true,
          onTap: () {
            _handleClusterTap(cluster);
          },
          excludeSemantics: true,
          child: PropertyMapClusterPin(
            count: cluster.size,
            backgroundColor: context.currentTheme.bgBrandDefault,
            textColor: Theme.of(context).brightness == Brightness.dark
                ? context.currentTheme.iconBrandPrimary
                : context.currentTheme.textNeutralWhite,
          ),
        ),
      ),
    );
    cluster.addClusterTapListener(_clusterTapListener);
  }

  bool _handleClusterTap(mapkit.Cluster cluster) {
    final coordinates = cluster.placemarks
        .map((placemark) => _coordinate(placemark.geometry))
        .toList();
    final ids = cluster.placemarks
        .map((placemark) => placemark.userData)
        .whereType<int>()
        .toSet();
    if (coordinates.isNotEmpty) {
      final bounds = PropertyMapBounds.fromCoordinates(coordinates);
      final markersById = {
        for (final marker in _markerSnapshot.markers) marker.id: marker,
      };
      final clusteredMarkers = ids
          .map((id) => markersById[id])
          .whereType<PropertyMapMarker>()
          .toList(growable: false);
      final accessibility = PropertyMapClusterAccessibilityMetadata.fromMarkers(
        clusteredMarkers,
      );
      widget.onClusterTap?.call(
        PropertyMapCluster(
          markerIds: ids,
          bounds: bounds,
          accessibilityLabel: accessibility.label,
          accessibilityMetadata: accessibility,
        ),
      );
      unawaited(fitBounds(bounds, padding: 72));
    }
    return true;
  }

  void _handleMapTap(mapkit.Point point) {
    widget.onMapTap?.call(_coordinate(point));
  }

  void _handleCameraChanged(
    mapkit.Map map,
    mapkit.CameraPosition position,
    mapkit.CameraUpdateReason reason,
    bool finished,
  ) {
    widget.onCameraMove?.call(
      PropertyMapCameraState(
        target: _coordinate(position.target),
        zoom: position.zoom,
        reason: reason == mapkit.CameraUpdateReason.Gestures
            ? PropertyMapCameraMoveReason.gesture
            : PropertyMapCameraMoveReason.programmatic,
      ),
    );
    if (!finished) return;
    final bounds = _bounds(map.visibleRegion);
    widget.onVisibleBoundsChanged?.call(bounds);
    widget.onCameraIdle?.call(bounds);
    widget.onCameraSettled?.call(
      PropertyMapCameraIdleState(
        bounds: bounds,
        reason: reason == mapkit.CameraUpdateReason.Gestures
            ? PropertyMapCameraMoveReason.gesture
            : PropertyMapCameraMoveReason.programmatic,
      ),
    );
  }

  @override
  Future<void> moveCamera(CameraTarget target) async {
    _map?.move(
      _cameraPosition(target),
      animation: const mapkit.Animation(
        type: mapkit.AnimationType.Smooth,
        duration: 0.3,
      ),
    );
  }

  @override
  Future<void> fitBounds(
    PropertyMapBounds bounds, {
    double padding = 48,
  }) async {
    final map = _map;
    if (map == null || !map.isValid()) return;
    if (bounds.southWest == bounds.northEast) {
      await moveCamera(
        CameraTarget(
          latitude: bounds.center.latitude,
          longitude: bounds.center.longitude,
        ),
      );
      return;
    }
    final position = map.cameraPositionForGeometry(
      mapkit.Geometry.fromBoundingBox(
        mapkit.BoundingBox(_point(bounds.southWest), _point(bounds.northEast)),
      ),
    );
    final paddingZoom = (padding / 96).clamp(0.25, 1.5);
    map.move(
      mapkit.CameraPosition(
        position.target,
        zoom: position.zoom - paddingZoom,
        azimuth: position.azimuth,
        tilt: position.tilt,
      ),
      animation: const mapkit.Animation(
        type: mapkit.AnimationType.Smooth,
        duration: 0.3,
      ),
    );
  }

  @override
  Future<PropertyMapBounds?> getVisibleBounds() async {
    final map = _map;
    if (map == null || !map.isValid()) return null;
    return _bounds(map.visibleRegion);
  }

  void _start() {
    _lifecycleLease.start(widget.lifecycle);
  }

  void _stop() {
    _lifecycleLease.stop();
  }

  void _releaseMap(
    mapkit.Map map, {
    required bool cameraListenerAttached,
    required bool inputListenerAttached,
  }) {
    try {
      if (!map.isValid()) return;
    } on Object {
      // The native platform view can finish disposal before its Dart callback.
      return;
    }
    if (cameraListenerAttached) {
      try {
        map.removeCameraListener(_cameraListener);
      } on Object {
        // Continue releasing the remaining native resources.
      }
    }
    if (inputListenerAttached) {
      try {
        map.removeInputListener(_inputListener);
      } on Object {
        // Continue releasing the remaining native resources.
      }
    }
    try {
      map.mapObjects.clear();
    } on Object {
      // The native platform view may already own disposal of its objects.
    }
  }
}

class _MarkerTapListener implements mapkit.MapObjectTapListener {
  const _MarkerTapListener(this.onTap);

  final ValueChanged<int> onTap;

  @override
  bool onMapObjectTap(mapkit.MapObject mapObject, mapkit.Point point) {
    final id = mapObject.userData;
    if (id is int) onTap(id);
    return true;
  }
}

class _ClusterListener implements mapkit.ClusterListener {
  const _ClusterListener(this.onAdded);

  final ValueChanged<mapkit.Cluster> onAdded;

  @override
  void onClusterAdded(mapkit.Cluster cluster) => onAdded(cluster);
}

class _ClusterTapListener implements mapkit.ClusterTapListener {
  const _ClusterTapListener(this.onTap);

  final bool Function(mapkit.Cluster) onTap;

  @override
  bool onClusterTap(mapkit.Cluster cluster) => onTap(cluster);
}

class _CameraListener implements mapkit.MapCameraListener {
  const _CameraListener(this.onChanged);

  final void Function(
    mapkit.Map,
    mapkit.CameraPosition,
    mapkit.CameraUpdateReason,
    // ignore: avoid_positional_boolean_parameters
    bool,
  )
  onChanged;

  @override
  void onCameraPositionChanged(
    mapkit.Map map,
    mapkit.CameraPosition cameraPosition,
    mapkit.CameraUpdateReason cameraUpdateReason,
    bool finished,
  ) => onChanged(map, cameraPosition, cameraUpdateReason, finished);
}

class _InputListener implements mapkit.MapInputListener {
  const _InputListener(this.onTap);

  final ValueChanged<mapkit.Point> onTap;

  @override
  void onMapTap(mapkit.Map map, mapkit.Point point) => onTap(point);

  @override
  void onMapLongTap(mapkit.Map map, mapkit.Point point) {}
}

mapkit.Point _point(PropertyMapCoordinate coordinate) => mapkit.Point(
  latitude: coordinate.latitude,
  longitude: coordinate.longitude,
);

PropertyMapCoordinate _coordinate(mapkit.Point point) =>
    PropertyMapCoordinate(latitude: point.latitude, longitude: point.longitude);

mapkit.CameraPosition _cameraPosition(CameraTarget target) =>
    mapkit.CameraPosition(
      _point(target.coordinate),
      zoom: target.zoom,
      azimuth: 0,
      tilt: 0,
    );

PropertyMapBounds _bounds(mapkit.VisibleRegion region) {
  final bounds = mapkit.VisibleRegionUtils.getBounds(region);
  return PropertyMapBounds(
    southWest: _coordinate(bounds.southWest),
    northEast: _coordinate(bounds.northEast),
  );
}
