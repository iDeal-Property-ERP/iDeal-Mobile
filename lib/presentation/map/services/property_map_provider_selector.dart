import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';

typedef PropertyMapProviderProbe = Future<bool> Function();

class PropertyMapProviderCandidate {
  const PropertyMapProviderCandidate({
    required this.provider,
    required this.probe,
  });

  final PropertyMapProvider provider;
  final PropertyMapProviderProbe probe;
}

class PropertyMapProviderSelector {
  const PropertyMapProviderSelector({
    required this.candidates,
    this.probeTimeout = const Duration(seconds: 4),
    this.selectionTimeout = const Duration(seconds: 9),
  }) : assert(probeTimeout > Duration.zero),
       assert(selectionTimeout > Duration.zero);

  factory PropertyMapProviderSelector.automatic({
    YandexMapLifecycle? mapkitService,
    String Function()? googleApiKey,
    Duration probeTimeout = const Duration(seconds: 4),
    Duration selectionTimeout = const Duration(seconds: 9),
  }) {
    final yandex = mapkitService ?? MapkitService.instance;
    final readGoogleApiKey = googleApiKey ?? () => AppConfig.googleMapsApiKey;
    return PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: yandex.initialize,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => readGoogleApiKey().trim().isNotEmpty,
        ),
      ],
      probeTimeout: probeTimeout,
      selectionTimeout: selectionTimeout,
    );
  }

  final List<PropertyMapProviderCandidate> candidates;
  final Duration probeTimeout;
  final Duration selectionTimeout;

  Future<PropertyMapProvider?> select({
    Set<PropertyMapProvider> excluding = const {},
  }) => _select(excluding).timeout(
    selectionTimeout,
    onTimeout: () {
      debugPrint('[Map] Provider selection timed out.');
      return null;
    },
  );

  Future<PropertyMapProvider?> _select(
    Set<PropertyMapProvider> excluding,
  ) async {
    for (final candidate in candidates) {
      if (excluding.contains(candidate.provider)) continue;
      try {
        if (await candidate.probe().timeout(probeTimeout)) {
          return candidate.provider;
        }
      } on TimeoutException catch (error, stackTrace) {
        debugPrint(
          '[Map] ${candidate.provider.name} probe timed out: '
          '$error\n$stackTrace',
        );
      } on Object catch (error, stackTrace) {
        debugPrint(
          '[Map] ${candidate.provider.name} initialization warning: '
          '$error\n$stackTrace',
        );
      }
    }
    return null;
  }
}
