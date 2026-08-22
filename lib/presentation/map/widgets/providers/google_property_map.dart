import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/google_camera_move_reason_tracker.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/google_map_style.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class GooglePropertyMap extends StatefulWidget {
  const GooglePropertyMap({
    super.key,
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
  State<GooglePropertyMap> createState() => _GooglePropertyMapState();
}

class _GooglePropertyMapState extends State<GooglePropertyMap>
    implements PropertyMapControllerDelegate {
  static const _clusterManagerId = google.ClusterManagerId('property_markers');

  google.GoogleMapController? _googleController;
  final GoogleCameraMoveReasonTracker _cameraReasonTracker =
      GoogleCameraMoveReasonTracker();

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(this);
  }

  @override
  void didUpdateWidget(GooglePropertyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?.detach(this);
    _cameraReasonTracker.dispose();
    _googleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    return google.GoogleMap(
      style: googleMapStyleFor(Theme.of(context).brightness),
      initialCameraPosition: google.CameraPosition(
        target: _latLng(widget.initialCamera.coordinate),
        zoom: widget.initialCamera.zoom,
      ),
      markers: widget.markers.map((marker) {
        final label = marker.priceLabel?.trim();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final glyphColor = marker.isSelected && !isDark
            ? theme.textNeutralWhite
            : theme.iconBrandPrimary;
        return google.Marker(
          markerId: google.MarkerId('${marker.id}'),
          position: _latLng(marker.coordinate),
          clusterManagerId: marker.clusterable ? _clusterManagerId : null,
          consumeTapEvents: true,
          zIndexInt: marker.isSelected ? 1 : 0,
          icon: google.BitmapDescriptor.pinConfig(
            backgroundColor: marker.isSelected
                ? theme.bgBrandDefault
                : theme.bgSurfaceBase,
            borderColor: theme.bgBrandDefault,
            glyph: label == null || label.isEmpty
                ? google.CircleGlyph(color: glyphColor)
                : google.TextGlyph(text: label, textColor: glyphColor),
          ),
          infoWindow: google.InfoWindow(
            // Best native marker metadata exposed by google_maps_flutter.
            // TalkBack/VoiceOver behavior still requires device validation.
            title: marker.accessibilityLabel,
          ),
          onTap: () => widget.onMarkerTap?.call(marker.id),
        );
      }).toSet(),
      clusterManagers: {
        // The plugin owns native cluster rendering and exposes no custom
        // cluster accessibility-label hook. The callback below still carries
        // structured app metadata; native behavior needs device validation.
        google.ClusterManager(
          clusterManagerId: _clusterManagerId,
          onClusterTap: _handleClusterTap,
        ),
      },
      onMapCreated: _onMapCreated,
      onCameraMoveStarted: _cameraReasonTracker.onCameraMoveStarted,
      onCameraMove: (position) {
        widget.onCameraMove?.call(
          PropertyMapCameraState(
            target: _coordinate(position.target),
            zoom: position.zoom,
            reason: _cameraReasonTracker.reason,
          ),
        );
      },
      onCameraIdle: _handleCameraIdle,
      onTap: (position) => widget.onMapTap?.call(_coordinate(position)),
      compassEnabled: widget.interactive,
      mapToolbarEnabled: false,
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: widget.interactive,
      myLocationButtonEnabled: false,
    );
  }

  void _onMapCreated(google.GoogleMapController controller) {
    if (!mounted) {
      controller.dispose();
      return;
    }
    final previousController = _googleController;
    if (previousController != null &&
        !identical(previousController, controller)) {
      previousController.dispose();
    }
    try {
      _googleController = controller;
      if (widget.fitMarkersOnCreate && widget.markers.length > 1) {
        unawaited(
          fitBounds(
            PropertyMapBounds.fromCoordinates(
              widget.markers.map((marker) => marker.coordinate),
            ),
          ),
        );
      }
      widget.onMapReady?.call(PropertyMapProvider.google);
    } on Object {
      _googleController = null;
      controller.dispose();
      widget.onProviderFailed?.call(PropertyMapProvider.google);
    }
  }

  void _handleClusterTap(google.Cluster cluster) {
    final markerIds = cluster.markerIds
        .map((markerId) => int.tryParse(markerId.value))
        .whereType<int>()
        .toSet();
    final bounds = _bounds(cluster.bounds);
    final markersById = {
      for (final marker in widget.markers) marker.id: marker,
    };
    final clusteredMarkers = markerIds
        .map((id) => markersById[id])
        .whereType<PropertyMapMarker>()
        .toList(growable: false);
    final accessibility = PropertyMapClusterAccessibilityMetadata.fromMarkers(
      clusteredMarkers,
    );
    widget.onClusterTap?.call(
      PropertyMapCluster(
        markerIds: markerIds,
        bounds: bounds,
        accessibilityLabel: accessibility.label,
        accessibilityMetadata: accessibility,
      ),
    );
    unawaited(fitBounds(bounds, padding: 72));
  }

  Future<void> _handleCameraIdle() async {
    final reason = _cameraReasonTracker.onCameraIdle();
    final bounds = await getVisibleBounds();
    if (!mounted || bounds == null) return;
    widget.onVisibleBoundsChanged?.call(bounds);
    widget.onCameraIdle?.call(bounds);
    widget.onCameraSettled?.call(
      PropertyMapCameraIdleState(bounds: bounds, reason: reason),
    );
  }

  @override
  Future<void> moveCamera(CameraTarget target) async {
    final controller = _googleController;
    if (controller == null) return;
    _cameraReasonTracker.expectProgrammaticMove();
    try {
      await controller.animateCamera(
        google.CameraUpdate.newCameraPosition(
          google.CameraPosition(
            target: _latLng(target.coordinate),
            zoom: target.zoom,
          ),
        ),
      );
    } on Object {
      _cameraReasonTracker.cancelProgrammaticMove();
      rethrow;
    }
  }

  @override
  Future<void> fitBounds(
    PropertyMapBounds bounds, {
    double padding = 48,
  }) async {
    final controller = _googleController;
    if (controller == null) return;
    if (bounds.southWest == bounds.northEast) {
      await moveCamera(
        CameraTarget(
          latitude: bounds.center.latitude,
          longitude: bounds.center.longitude,
        ),
      );
      return;
    }
    _cameraReasonTracker.expectProgrammaticMove();
    try {
      await controller.animateCamera(
        google.CameraUpdate.newLatLngBounds(_latLngBounds(bounds), padding),
      );
    } on Object {
      _cameraReasonTracker.cancelProgrammaticMove();
      rethrow;
    }
  }

  @override
  Future<PropertyMapBounds?> getVisibleBounds() async {
    final controller = _googleController;
    if (controller == null) return null;
    return _bounds(await controller.getVisibleRegion());
  }
}

google.LatLng _latLng(PropertyMapCoordinate coordinate) =>
    google.LatLng(coordinate.latitude, coordinate.longitude);

PropertyMapCoordinate _coordinate(google.LatLng coordinate) =>
    PropertyMapCoordinate(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
    );

google.LatLngBounds _latLngBounds(PropertyMapBounds bounds) =>
    google.LatLngBounds(
      southwest: _latLng(bounds.southWest),
      northeast: _latLng(bounds.northEast),
    );

PropertyMapBounds _bounds(google.LatLngBounds bounds) => PropertyMapBounds(
  southWest: _coordinate(bounds.southwest),
  northEast: _coordinate(bounds.northeast),
);
