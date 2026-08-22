import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:yandex_maps_mapkit/init.dart' as init;
import 'package:yandex_maps_mapkit/mapkit_factory.dart' as mapkit_factory;

abstract interface class YandexMapLifecycle {
  bool get isAvailable;

  Future<bool> initialize({String? apiKey});

  void start();

  void stop();
}

class YandexMapLifecycleLease {
  YandexMapLifecycle? _activeLifecycle;

  YandexMapLifecycle? get activeLifecycle => _activeLifecycle;

  void start(YandexMapLifecycle lifecycle) {
    if (identical(_activeLifecycle, lifecycle)) return;
    stop();
    if (!lifecycle.isAvailable) return;
    lifecycle.start();
    _activeLifecycle = lifecycle;
  }

  void stop() {
    _activeLifecycle?.stop();
    _activeLifecycle = null;
  }
}

class MapkitService implements YandexMapLifecycle {
  MapkitService._();

  static final instance = MapkitService._();

  Future<bool>? _initialization;
  bool _available = false;
  int _activeMapViews = 0;

  @override
  bool get isAvailable => _available;

  @override
  Future<bool> initialize({String? apiKey}) {
    if (_available) return Future.value(true);
    final key = apiKey?.trim() ?? '';
    if (key.isEmpty) return Future.value(false);
    return _initialization ??= _initialize(key);
  }

  Future<bool> _initialize(String apiKey) async {
    if (AppEnvironment.isTestEnvironment || kIsWeb || apiKey.isEmpty) {
      return false;
    }

    try {
      await init.initMapkit(apiKey: apiKey);
      _available = true;
    } on Object catch (error, stackTrace) {
      debugPrint('[MapKit] Initialization error: $error\n$stackTrace');
      _available = false;
      _initialization = null;
    }
    return _available;
  }

  @override
  void start() {
    if (!_available) return;

    if (_activeMapViews++ == 0) {
      mapkit_factory.mapkit.onStart();
    }
  }

  @override
  void stop() {
    if (!_available || _activeMapViews == 0) return;

    if (--_activeMapViews == 0) {
      mapkit_factory.mapkit.onStop();
    }
  }
}
