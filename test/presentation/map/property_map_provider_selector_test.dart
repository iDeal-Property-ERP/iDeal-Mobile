import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/domain/entities/map_config.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/domain/repositories/map_config_repository.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_provider_selector.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapConfigRepository extends Mock implements MapConfigRepository {}

void main() {
  test('selects Yandex first when initialization succeeds', () async {
    var googleProbeCount = 0;
    final selector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => true,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async {
            googleProbeCount++;
            return true;
          },
        ),
      ],
    );

    expect(await selector.select(), PropertyMapProvider.yandex);
    expect(googleProbeCount, 0);
  });

  test('falls back to Google when Yandex is missing or fails', () async {
    final missingSelector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => false,
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => true,
        ),
      ],
    );
    final failingSelector = PropertyMapProviderSelector(
      candidates: [
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.yandex,
          probe: () async => throw StateError('Yandex init failed'),
        ),
        PropertyMapProviderCandidate(
          provider: PropertyMapProvider.google,
          probe: () async => true,
        ),
      ],
    );

    expect(await missingSelector.select(), PropertyMapProvider.google);
    expect(await failingSelector.select(), PropertyMapProvider.google);
  });

  test('automatic selector checks injected lifecycle and Google key', () async {
    final yandex = _FakeYandexLifecycle(available: false);
    final selector = PropertyMapProviderSelector.automatic(
      mapkitService: yandex,
      googleApiKey: () => 'restricted-google-key',
    );

    expect(await selector.select(), PropertyMapProvider.google);
    expect(yandex.initializeCount, 1);
  });

  test('returns unavailable when neither configured provider works', () async {
    final selector = PropertyMapProviderSelector.automatic(
      mapkitService: _FakeYandexLifecycle(available: false),
      googleApiKey: () => ' ',
    );

    expect(await selector.select(), isNull);
  });

  test('excludes a provider that failed after native view creation', () async {
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

    expect(
      await selector.select(excluding: {PropertyMapProvider.yandex}),
      PropertyMapProvider.google,
    );
  });

  test(
    'times out a hung Yandex probe and deterministically selects Google',
    () {
      fakeAsync((async) {
        PropertyMapProvider? selected;
        final selector = PropertyMapProviderSelector(
          candidates: [
            PropertyMapProviderCandidate(
              provider: PropertyMapProvider.yandex,
              probe: () => Completer<bool>().future,
            ),
            PropertyMapProviderCandidate(
              provider: PropertyMapProvider.google,
              probe: () async => true,
            ),
          ],
          probeTimeout: const Duration(milliseconds: 10),
          selectionTimeout: const Duration(milliseconds: 30),
        );

        selector.select().then((provider) => selected = provider);
        async.elapse(const Duration(milliseconds: 10));
        async.flushMicrotasks();

        expect(selected, PropertyMapProvider.google);
      });
    },
  );

  test('overall selection timeout bounds custom candidate sequences', () {
    fakeAsync((async) {
      var completed = false;
      PropertyMapProvider? selected = PropertyMapProvider.google;
      final selector = PropertyMapProviderSelector(
        candidates: [
          PropertyMapProviderCandidate(
            provider: PropertyMapProvider.yandex,
            probe: () => Completer<bool>().future,
          ),
        ],
        probeTimeout: const Duration(hours: 1),
        selectionTimeout: const Duration(milliseconds: 10),
      );

      selector.select().then((provider) {
        selected = provider;
        completed = true;
      });
      async.elapse(const Duration(milliseconds: 10));
      async.flushMicrotasks();

      expect(completed, isTrue);
      expect(selected, isNull);
    });
  });

  test(
    'automatic selector prioritizes Yandex when backend designates it',
    () async {
      final mockRepo = _MockMapConfigRepository();
      when(() => mockRepo.getMapConfig()).thenAnswer(
        (_) async => PropertyMapConfig(
          provider: PropertyMapProvider.yandex,
          token: 'dynamic-yandex-token',
          fetchedAt: DateTime.now(),
        ),
      );

      final yandex = _FakeYandexLifecycle(available: true);
      final selector = PropertyMapProviderSelector.automatic(
        mapConfigRepository: mockRepo,
        mapkitService: yandex,
        googleApiKey: () => 'static-google-key',
      );

      expect(await selector.select(), PropertyMapProvider.yandex);
      expect(yandex.initializeCount, 1);
      expect(yandex.lastApiKey, 'dynamic-yandex-token');
    },
  );

  test(
    'automatic selector prioritizes Google when backend designates it',
    () async {
      final mockRepo = _MockMapConfigRepository();
      when(() => mockRepo.getMapConfig()).thenAnswer(
        (_) async => PropertyMapConfig(
          provider: PropertyMapProvider.google,
          token: 'dynamic-google-token',
          fetchedAt: DateTime.now(),
        ),
      );

      final yandex = _FakeYandexLifecycle(available: true);
      final selector = PropertyMapProviderSelector.automatic(
        mapConfigRepository: mockRepo,
        mapkitService: yandex,
        googleApiKey: () => '',
      );

      expect(await selector.select(), PropertyMapProvider.google);
      expect(yandex.initializeCount, 0);
    },
  );
}

class _FakeYandexLifecycle implements YandexMapLifecycle {
  _FakeYandexLifecycle({required this.available});

  final bool available;
  int initializeCount = 0;
  String? lastApiKey;

  @override
  bool get isAvailable => available;

  @override
  Future<bool> initialize({String? apiKey}) async {
    initializeCount++;
    lastApiKey = apiKey;
    return available;
  }

  @override
  void start() {}

  @override
  void stop() {}
}
