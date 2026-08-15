import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

void main() {
  group('PropertyMapBounds', () {
    test('derives bounds and center from provider-neutral coordinates', () {
      final bounds = PropertyMapBounds.fromCoordinates(const [
        PropertyMapCoordinate(latitude: 41.20, longitude: 69.10),
        PropertyMapCoordinate(latitude: 41.40, longitude: 69.40),
        PropertyMapCoordinate(latitude: 41.30, longitude: 69.20),
      ]);

      expect(
        bounds.southWest,
        const PropertyMapCoordinate(latitude: 41.20, longitude: 69.10),
      );
      expect(
        bounds.northEast,
        const PropertyMapCoordinate(latitude: 41.40, longitude: 69.40),
      );
      expect(bounds.center.latitude, closeTo(41.30, 0.000001));
      expect(bounds.center.longitude, closeTo(69.25, 0.000001));
      expect(
        bounds.contains(
          const PropertyMapCoordinate(latitude: 41.35, longitude: 69.30),
        ),
        isTrue,
      );
    });

    test('rejects an empty coordinate collection', () {
      expect(
        () => PropertyMapBounds.fromCoordinates(const []),
        throwsArgumentError,
      );
    });
  });

  group('map marker metadata', () {
    test('snapshot detects in-place list mutations by marker value', () {
      final markers = <PropertyMapMarker>[
        const PropertyMapMarker(
          id: 1,
          latitude: 41.31,
          longitude: 69.28,
          priceLabel: r'$500',
        ),
      ];
      final snapshot = PropertyMapMarkerSnapshot.capture(markers);

      markers[0] = const PropertyMapMarker(
        id: 1,
        latitude: 41.32,
        longitude: 69.29,
        priceLabel: r'$550',
        isSelected: true,
      );

      expect(snapshot.differsFrom(markers), isTrue);
      expect(snapshot.markers.single.priceLabel, r'$500');
    });

    test('accessibility metadata includes description, price, and cluster', () {
      const marker = PropertyMapMarker(
        id: 1,
        latitude: 41.31,
        longitude: 69.28,
        label: 'Yunusobod apartment',
        priceLabel: r'$500',
      );
      const second = PropertyMapMarker(
        id: 2,
        latitude: 41.32,
        longitude: 69.29,
        semanticsLabel: 'Accessible apartment',
        priceLabel: r'$650',
      );

      expect(marker.accessibilityLabel, r'Yunusobod apartment, $500');
      expect(second.accessibilityLabel, r'Accessible apartment, $650');
      expect(
        propertyMapClusterAccessibilityLabel(const [marker, second]),
        r'2: Yunusobod apartment, $500; Accessible apartment, $650',
      );

      final metadata = PropertyMapClusterAccessibilityMetadata.fromMarkers(
        const [marker, second],
      );
      expect(metadata.markerCount, 2);
      expect(metadata.memberLabels, const [
        r'Yunusobod apartment, $500',
        r'Accessible apartment, $650',
      ]);
      expect(metadata.hiddenMemberCount, 0);
      expect(
        metadata.label,
        propertyMapClusterAccessibilityLabel(const [marker, second]),
      );
    });

    test(
      'cluster metadata reports labels omitted from its concise summary',
      () {
        final markers = List.generate(
          5,
          (index) => PropertyMapMarker(
            id: index,
            latitude: 41.31,
            longitude: 69.28,
            label: 'Listing ${index + 1}',
            priceLabel: '\$${500 + index}',
          ),
        );

        final metadata = PropertyMapClusterAccessibilityMetadata.fromMarkers(
          markers,
        );

        expect(metadata.markerCount, 5);
        expect(metadata.memberLabels, hasLength(3));
        expect(metadata.hiddenMemberCount, 2);
        expect(metadata.label, contains(r'Listing 1, $500'));
        expect(metadata.label, endsWith('; +2'));
      },
    );

    test('camera state exposes discovery search-area semantics', () {
      const gesture = PropertyMapCameraState(
        target: PropertyMapCoordinate(latitude: 41.31, longitude: 69.28),
        zoom: 12,
        reason: PropertyMapCameraMoveReason.gesture,
      );
      const programmatic = PropertyMapCameraState(
        target: PropertyMapCoordinate(latitude: 41.31, longitude: 69.28),
        zoom: 12,
        reason: PropertyMapCameraMoveReason.programmatic,
      );

      expect(gesture.shouldOfferAreaSearch, isTrue);
      expect(programmatic.shouldOfferAreaSearch, isFalse);
    });
  });

  group('PropertyMapController', () {
    test(
      'forwards camera commands and detaches only the active delegate',
      () async {
        final controller = PropertyMapController();
        final delegate = _FakeMapControllerDelegate();
        final otherDelegate = _FakeMapControllerDelegate();
        controller.attach(delegate);

        const target = CameraTarget(
          latitude: 41.31,
          longitude: 69.28,
          zoom: 13,
        );
        await controller.moveCamera(target);
        await controller.fitMarkers(const [
          PropertyMapMarker(
            id: 1,
            latitude: 41.20,
            longitude: 69.10,
            priceLabel: r'$500',
            isSelected: true,
          ),
          PropertyMapMarker(id: 2, latitude: 41.40, longitude: 69.40),
        ]);

        expect(delegate.movedTo, target);
        expect(delegate.fittedBounds?.southWest.latitude, 41.20);
        expect(delegate.fittedBounds?.northEast.longitude, 69.40);
        controller.detach(otherDelegate);
        expect(controller.isAttached, isTrue);
        controller.detach(delegate);
        expect(controller.isAttached, isFalse);
      },
    );
  });
}

class _FakeMapControllerDelegate implements PropertyMapControllerDelegate {
  CameraTarget? movedTo;
  PropertyMapBounds? fittedBounds;

  @override
  Future<void> fitBounds(
    PropertyMapBounds bounds, {
    double padding = 48,
  }) async {
    fittedBounds = bounds;
  }

  @override
  Future<PropertyMapBounds?> getVisibleBounds() async => fittedBounds;

  @override
  Future<void> moveCamera(CameraTarget target) async {
    movedTo = target;
  }
}
