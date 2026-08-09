import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit_factory.dart' as mapkit_factory;

class MapkitService {
  MapkitService._();

  static final instance = MapkitService._();

  Future<void>? _initialization;
  bool _available = false;
  int _activeMapViews = 0;

  bool get isAvailable => _available;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    if (AppEnvironment.isTestEnvironment ||
        kIsWeb ||
        AppConfig.yandexMapKitApiKey.isEmpty) {
      return;
    }

    try {
      await init.initMapkit(apiKey: AppConfig.yandexMapKitApiKey);
      _available = true;
    } on Object catch (error, stackTrace) {
      debugPrint('[MapKit] Initialization warning: $error\n$stackTrace');
    }
  }

  void start() {
    if (!_available) return;

    if (_activeMapViews++ == 0) {
      mapkit_factory.mapkit.onStart();
    }
  }

  void stop() {
    if (!_available || _activeMapViews == 0) return;

    if (--_activeMapViews == 0) {
      mapkit_factory.mapkit.onStop();
    }
  }
}
