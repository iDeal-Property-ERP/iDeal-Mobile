import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';

void main() {
  testWidgets('shows localized unavailable state when no provider works', (
    tester,
  ) async {
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => false,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => false,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PropertyMapView(
            providerSelector: selector,
            markers: const [],
            initialCamera: const CameraTarget(
              latitude: 41.31,
              longitude: 69.28,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PropertyMapUnavailable), findsOneWidget);
    expect(find.text('Map unavailable'), findsOneWidget);
  });

  testWidgets('forwards provider-neutral marker and empty-map callbacks', (
    tester,
  ) async {
    int? tappedMarker;
    PropertyMapCoordinate? tappedMap;
    PropertyMapCameraState? movedCamera;
    PropertyMapBounds? idleBounds;
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PropertyMapView(
          providerSelector: selector,
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) {
                return Column(
                  children: [
                    TextButton(
                      key: const ValueKey('fake_marker'),
                      onPressed: () => configuration.onMarkerTap?.call(42),
                      child: const Text('Marker'),
                    ),
                    TextButton(
                      key: const ValueKey('fake_map'),
                      onPressed: () => configuration.onMapTap?.call(
                        const PropertyMapCoordinate(
                          latitude: 41.31,
                          longitude: 69.28,
                        ),
                      ),
                      child: const Text('Map'),
                    ),
                    TextButton(
                      key: const ValueKey('fake_camera'),
                      onPressed: () {
                        configuration.onCameraMove?.call(
                          const PropertyMapCameraState(
                            target: PropertyMapCoordinate(
                              latitude: 41.32,
                              longitude: 69.29,
                            ),
                            zoom: 12,
                            reason: PropertyMapCameraMoveReason.gesture,
                          ),
                        );
                        configuration.onCameraIdle?.call(
                          PropertyMapBounds(
                            southWest: const PropertyMapCoordinate(
                              latitude: 41.20,
                              longitude: 69.10,
                            ),
                            northEast: const PropertyMapCoordinate(
                              latitude: 41.40,
                              longitude: 69.40,
                            ),
                          ),
                        );
                      },
                      child: const Text('Camera'),
                    ),
                  ],
                );
              },
          markers: const [],
          initialCamera: const CameraTarget(latitude: 41.31, longitude: 69.28),
          onMarkerTap: (id) => tappedMarker = id,
          onMapTap: (coordinate) => tappedMap = coordinate,
          onCameraMove: (camera) => movedCamera = camera,
          onCameraIdle: (bounds) => idleBounds = bounds,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('fake_marker')));
    await tester.tap(find.byKey(const ValueKey('fake_map')));
    await tester.tap(find.byKey(const ValueKey('fake_camera')));

    expect(tappedMarker, 42);
    expect(
      tappedMap,
      const PropertyMapCoordinate(latitude: 41.31, longitude: 69.28),
    );
    expect(movedCamera?.reason, PropertyMapCameraMoveReason.gesture);
    expect(idleBounds?.northEast.longitude, 69.40);
  });

  testWidgets('reselects Google after a fake Yandex native failure', (
    tester,
  ) async {
    final builtProviders = <PropertyMapProvider>[];
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PropertyMapView(
          providerSelector: selector,
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) {
                builtProviders.add(provider);
                return TextButton(
                  key: ValueKey(provider),
                  onPressed: () => onFailed(provider),
                  child: Text(provider.name),
                );
              },
          markers: const [],
          initialCamera: const CameraTarget(latitude: 41.31, longitude: 69.28),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey(PropertyMapProvider.yandex)), findsOne);

    await tester.tap(find.byKey(const ValueKey(PropertyMapProvider.yandex)));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey(PropertyMapProvider.google)), findsOne);
    expect(builtProviders, containsAllInOrder(PropertyMapProvider.values));
  });

  testWidgets('ignores late callbacks from a replaced provider selection', (
    tester,
  ) async {
    late ValueChanged<PropertyMapProvider> staleReady;
    late ValueChanged<PropertyMapProvider> staleFailed;
    late ValueChanged<PropertyMapProvider> currentReady;
    final readyEvents = <PropertyMapProvider>[];
    final yandexSelector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
      ],
    );
    final googleSelector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => true,
        ),
      ],
    );

    Widget buildMap(PropertyMapProviderSelector selector) {
      return MaterialApp(
        home: PropertyMapView(
          key: const ValueKey('provider_map'),
          providerSelector: selector,
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) {
                if (provider == PropertyMapProvider.yandex) {
                  staleReady = onReady;
                  staleFailed = onFailed;
                } else {
                  currentReady = onReady;
                }
                return SizedBox(key: ValueKey(provider));
              },
          markers: const [],
          initialCamera: const CameraTarget(latitude: 41.31, longitude: 69.28),
          onProviderReady: readyEvents.add,
        ),
      );
    }

    await tester.pumpWidget(buildMap(yandexSelector));
    await tester.pump();
    expect(find.byKey(const ValueKey(PropertyMapProvider.yandex)), findsOne);

    await tester.pumpWidget(buildMap(googleSelector));
    await tester.pump();
    expect(find.byKey(const ValueKey(PropertyMapProvider.google)), findsOne);

    staleReady(PropertyMapProvider.yandex);
    staleFailed(PropertyMapProvider.yandex);
    await tester.pump();

    expect(find.byKey(const ValueKey(PropertyMapProvider.google)), findsOne);
    expect(readyEvents, isEmpty);

    currentReady(PropertyMapProvider.google);
    expect(readyEvents, [PropertyMapProvider.google]);
  });

  testWidgets('provider startup timeout reselects the next provider', (
    tester,
  ) async {
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PropertyMapView(
          providerSelector: selector,
          providerStartupTimeout: const Duration(milliseconds: 10),
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) =>
                  SizedBox(key: ValueKey(provider)),
          markers: const [],
          initialCamera: const CameraTarget(latitude: 41.31, longitude: 69.28),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey(PropertyMapProvider.yandex)), findsOne);

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump();

    expect(find.byKey(const ValueKey(PropertyMapProvider.google)), findsOne);
  });

  testWidgets('provider readiness cancels its startup timeout', (tester) async {
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PropertyMapView(
          providerSelector: selector,
          providerStartupTimeout: const Duration(milliseconds: 10),
          providerViewBuilder:
              (context, provider, configuration, onReady, onFailed) =>
                  TextButton(
                    key: ValueKey(provider),
                    onPressed: () => onReady(provider),
                    child: const Text('Ready'),
                  ),
          markers: const [],
          initialCamera: const CameraTarget(latitude: 41.31, longitude: 69.28),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey(PropertyMapProvider.yandex)));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byKey(const ValueKey(PropertyMapProvider.yandex)), findsOne);
  });
}
