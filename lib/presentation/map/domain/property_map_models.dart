import 'package:equatable/equatable.dart';

enum PropertyMapProvider { yandex, google }

enum PropertyMapCameraMoveReason { gesture, programmatic }

class PropertyMapCoordinate extends Equatable {
  const PropertyMapCoordinate({required this.latitude, required this.longitude})
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class PropertyMapMarker extends Equatable {
  const PropertyMapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.label,
    this.priceLabel,
    this.semanticsLabel,
    this.isSelected = false,
    this.clusterable = true,
  }) : assert(latitude >= -90 && latitude <= 90),
       assert(longitude >= -180 && longitude <= 180);

  final int id;
  final double latitude;
  final double longitude;

  /// A provider-neutral descriptive label, such as a listing title.
  final String? label;

  /// Short text rendered inside a discovery pin, such as `12.5 mln`.
  final String? priceLabel;

  /// The complete accessibility label when it differs from [label].
  final String? semanticsLabel;

  final bool isSelected;
  final bool clusterable;

  PropertyMapCoordinate get coordinate =>
      PropertyMapCoordinate(latitude: latitude, longitude: longitude);

  /// Text supplied to provider-native accessibility metadata. Price is kept
  /// even when the caller provides a more descriptive semantic label.
  String? get accessibilityLabel {
    final description = _clean(semanticsLabel) ?? _clean(label);
    final price = _clean(priceLabel);
    if (description == null) return price;
    if (price == null || description.contains(price)) return description;
    return '$description, $price';
  }

  @override
  List<Object?> get props => [
    id,
    latitude,
    longitude,
    label,
    priceLabel,
    semanticsLabel,
    isSelected,
    clusterable,
  ];
}

class PropertyMapMarkerSnapshot {
  PropertyMapMarkerSnapshot.capture(Iterable<PropertyMapMarker> markers)
    : markers = List<PropertyMapMarker>.unmodifiable(markers);

  final List<PropertyMapMarker> markers;

  bool differsFrom(Iterable<PropertyMapMarker> current) {
    final iterator = current.iterator;
    for (final marker in markers) {
      if (!iterator.moveNext() || iterator.current != marker) return true;
    }
    return iterator.moveNext();
  }
}

class CameraTarget extends Equatable {
  const CameraTarget({
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
  }) : assert(latitude >= -90 && latitude <= 90),
       assert(longitude >= -180 && longitude <= 180),
       assert(zoom >= 0);

  final double latitude;
  final double longitude;
  final double zoom;

  PropertyMapCoordinate get coordinate =>
      PropertyMapCoordinate(latitude: latitude, longitude: longitude);

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}

class PropertyMapBounds extends Equatable {
  PropertyMapBounds({required this.southWest, required this.northEast})
    : assert(southWest.latitude <= northEast.latitude),
      assert(southWest.longitude <= northEast.longitude);

  factory PropertyMapBounds.fromCoordinates(
    Iterable<PropertyMapCoordinate> coordinates,
  ) {
    final iterator = coordinates.iterator;
    if (!iterator.moveNext()) {
      throw ArgumentError.value(
        coordinates,
        'coordinates',
        'Must not be empty',
      );
    }

    var minLatitude = iterator.current.latitude;
    var maxLatitude = iterator.current.latitude;
    var minLongitude = iterator.current.longitude;
    var maxLongitude = iterator.current.longitude;
    while (iterator.moveNext()) {
      final coordinate = iterator.current;
      minLatitude = _min(minLatitude, coordinate.latitude);
      maxLatitude = _max(maxLatitude, coordinate.latitude);
      minLongitude = _min(minLongitude, coordinate.longitude);
      maxLongitude = _max(maxLongitude, coordinate.longitude);
    }

    return PropertyMapBounds(
      southWest: PropertyMapCoordinate(
        latitude: minLatitude,
        longitude: minLongitude,
      ),
      northEast: PropertyMapCoordinate(
        latitude: maxLatitude,
        longitude: maxLongitude,
      ),
    );
  }

  final PropertyMapCoordinate southWest;
  final PropertyMapCoordinate northEast;

  PropertyMapCoordinate get center => PropertyMapCoordinate(
    latitude: (southWest.latitude + northEast.latitude) / 2,
    longitude: (southWest.longitude + northEast.longitude) / 2,
  );

  bool contains(PropertyMapCoordinate coordinate) =>
      coordinate.latitude >= southWest.latitude &&
      coordinate.latitude <= northEast.latitude &&
      coordinate.longitude >= southWest.longitude &&
      coordinate.longitude <= northEast.longitude;

  @override
  List<Object?> get props => [southWest, northEast];
}

class PropertyMapCameraState extends Equatable {
  const PropertyMapCameraState({
    required this.target,
    required this.zoom,
    required this.reason,
  });

  final PropertyMapCoordinate target;
  final double zoom;
  final PropertyMapCameraMoveReason reason;

  bool get isUserGesture => reason == PropertyMapCameraMoveReason.gesture;

  /// Discovery uses this to reveal, but not automatically execute,
  /// "Search this area" after user camera gestures.
  bool get shouldOfferAreaSearch => isUserGesture;

  @override
  List<Object?> get props => [target, zoom, reason];
}

class PropertyMapCameraIdleState extends Equatable {
  const PropertyMapCameraIdleState({
    required this.bounds,
    required this.reason,
  });

  final PropertyMapBounds bounds;
  final PropertyMapCameraMoveReason reason;

  bool get shouldOfferAreaSearch =>
      reason == PropertyMapCameraMoveReason.gesture;

  @override
  List<Object?> get props => [bounds, reason];
}

class PropertyMapCluster extends Equatable {
  const PropertyMapCluster({
    required this.markerIds,
    required this.bounds,
    this.accessibilityLabel = '',
    this.accessibilityMetadata =
        const PropertyMapClusterAccessibilityMetadata(),
  });

  final Set<int> markerIds;
  final PropertyMapBounds bounds;
  final String accessibilityLabel;

  /// Structured cluster content for app-owned announcements and non-native
  /// map affordances. Native map SDK screen-reader behavior is provider-owned.
  final PropertyMapClusterAccessibilityMetadata accessibilityMetadata;

  @override
  List<Object?> get props => [
    markerIds,
    bounds,
    accessibilityLabel,
    accessibilityMetadata,
  ];
}

class PropertyMapClusterAccessibilityMetadata extends Equatable {
  const PropertyMapClusterAccessibilityMetadata({
    this.markerCount = 0,
    this.memberLabels = const [],
    this.hiddenMemberCount = 0,
  });

  factory PropertyMapClusterAccessibilityMetadata.fromMarkers(
    Iterable<PropertyMapMarker> markers, {
    int maximumMemberLabels = 3,
  }) {
    assert(maximumMemberLabels >= 0);
    final snapshot = markers.toList(growable: false);
    final allLabels = snapshot
        .map((marker) => marker.accessibilityLabel)
        .map(_clean)
        .whereType<String>()
        .toList(growable: false);
    final memberLabels = allLabels
        .take(maximumMemberLabels)
        .toList(growable: false);
    return PropertyMapClusterAccessibilityMetadata(
      markerCount: snapshot.length,
      memberLabels: List.unmodifiable(memberLabels),
      hiddenMemberCount: allLabels.length - memberLabels.length,
    );
  }

  final int markerCount;
  final List<String> memberLabels;
  final int hiddenMemberCount;

  String get label {
    if (memberLabels.isEmpty) return '$markerCount';
    final hiddenSuffix = hiddenMemberCount == 0 ? '' : '; +$hiddenMemberCount';
    return '$markerCount: ${memberLabels.join('; ')}$hiddenSuffix';
  }

  @override
  List<Object?> get props => [markerCount, memberLabels, hiddenMemberCount];
}

abstract interface class PropertyMapControllerDelegate {
  Future<void> moveCamera(CameraTarget target);

  Future<void> fitBounds(PropertyMapBounds bounds, {double padding = 48});

  Future<PropertyMapBounds?> getVisibleBounds();
}

class PropertyMapController {
  PropertyMapControllerDelegate? _delegate;

  bool get isAttached => _delegate != null;

  Future<void> moveCamera(CameraTarget target) async {
    await _delegate?.moveCamera(target);
  }

  Future<void> fitBounds(
    PropertyMapBounds bounds, {
    double padding = 48,
  }) async {
    await _delegate?.fitBounds(bounds, padding: padding);
  }

  Future<void> fitMarkers(
    Iterable<PropertyMapMarker> markers, {
    double padding = 48,
  }) async {
    final coordinates = markers.map((marker) => marker.coordinate).toList();
    if (coordinates.isEmpty) return;
    await fitBounds(
      PropertyMapBounds.fromCoordinates(coordinates),
      padding: padding,
    );
  }

  Future<PropertyMapBounds?> getVisibleBounds() async =>
      _delegate?.getVisibleBounds();

  void attach(PropertyMapControllerDelegate delegate) {
    _delegate = delegate;
  }

  void detach(PropertyMapControllerDelegate delegate) {
    if (identical(_delegate, delegate)) _delegate = null;
  }
}

double _min(double left, double right) => left < right ? left : right;

double _max(double left, double right) => left > right ? left : right;

String? _clean(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

String propertyMapClusterAccessibilityLabel(
  Iterable<PropertyMapMarker> markers,
) => PropertyMapClusterAccessibilityMetadata.fromMarkers(markers).label;
