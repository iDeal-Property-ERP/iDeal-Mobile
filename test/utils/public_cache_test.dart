import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockCacheManager extends Mock implements CacheManager {}

void main() {
  late _MockCacheManager cacheManager;
  late CacheOptions cacheOptions;

  setUpAll(() {
    registerFallbackValue(PublicCacheRequest.cacheFirst);
  });

  Response<dynamic> response(int value, {bool network = false}) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/mobile/home/listings/'),
        statusCode: 200,
        data: value,
        extra: {extraFromNetworkKey: network},
      );

  setUp(() {
    cacheManager = _MockCacheManager();
    cacheOptions = CacheOptions(store: MemCacheStore());
    when(
      () => cacheManager.publicCacheOptions(request: any(named: 'request')),
    ).thenReturn(cacheOptions);
  });

  test('key partitions schema, resolved URI query, and locale', () {
    final listUz = CacheManager.buildPublicCacheKey(
      url: Uri.parse('https://api.example/listings/?page=1&q=flat'),
      locale: 'uz',
    );
    final listRu = CacheManager.buildPublicCacheKey(
      url: Uri.parse('https://api.example/listings/?page=1&q=flat'),
      locale: 'ru',
    );
    final nextPage = CacheManager.buildPublicCacheKey(
      url: Uri.parse('https://api.example/listings/?page=2&q=flat'),
      locale: 'uz',
    );

    expect(listUz, startsWith('public-v$kPublicApiCacheSchemaVersion:uz:'));
    expect(listUz, isNot(listRu));
    expect(listUz, isNot(nextPage));
    expect(listUz, isNot(contains('api_cache')));
  });

  test('emits cache then forced fresh response', () async {
    var call = 0;
    final events = await PublicCacheCoordinator.staleWhileRevalidate<int>(
      cacheManager: cacheManager,
      request: (_) async =>
          call++ == 0 ? response(1) : response(2, network: true),
      decode: (response) => response.data as int,
    ).toList();

    expect(events.map((event) => event.data), [1, 2]);
    expect(events.map((event) => event.origin), [
      PublicDataOrigin.cache,
      PublicDataOrigin.fresh,
    ]);
    verify(
      () => cacheManager.publicCacheOptions(
        request: PublicCacheRequest.cacheFirst,
      ),
    ).called(1);
    verify(
      () => cacheManager.publicCacheOptions(
        request: PublicCacheRequest.forceRefresh,
      ),
    ).called(1);
  });

  test(
    'retains cached data with stale retry signal after refresh failure',
    () async {
      var call = 0;
      final events = await PublicCacheCoordinator.staleWhileRevalidate<int>(
        cacheManager: cacheManager,
        request: (_) async {
          if (call++ == 0) return response(1);
          throw StateError('offline');
        },
        decode: (response) => response.data as int,
      ).toList();

      expect(events, hasLength(2));
      expect(events.last.data, 1);
      expect(events.last.origin, PublicDataOrigin.cache);
      expect(events.last.isStale, isTrue);
      expect(events.last.refreshError, isA<StateError>());
    },
  );
}
