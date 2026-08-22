import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockCacheManager extends Mock implements CacheManager {}

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int statusCode, Map<String, dynamic> data) {
  final bytes = utf8.encode(jsonEncode(data));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late MockSecureStorageService mockStorage;
  late MockCacheManager mockCacheManager;

  setUp(() {
    mockStorage = MockSecureStorageService();
    mockCacheManager = MockCacheManager();

    if (GetIt.instance.isRegistered<SecureStorageService>()) {
      GetIt.instance.unregister<SecureStorageService>();
    }
    if (GetIt.instance.isRegistered<CacheManager>()) {
      GetIt.instance.unregister<CacheManager>();
    }

    GetIt.instance.registerSingleton<SecureStorageService>(mockStorage);
    GetIt.instance.registerSingleton<CacheManager>(mockCacheManager);

    when(
      () => mockCacheManager.clearCachedApiResponse(),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  test('401 error refreshes tokens and retries request on success', () async {
    when(
      () => mockStorage.getRefreshToken(),
    ).thenAnswer((_) async => 'valid-refresh-token');
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'new-access-token');
    when(
      () => mockStorage.writeAuthTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    final dio = Dio();
    int profileCalls = 0;

    dio.httpClientAdapter = MockHttpAdapter((options) async {
      if (options.path.endsWith('/auth/refresh/')) {
        return jsonResponse(200, {
          'success': true,
          'message': 'OK',
          'data': {
            'access_token': 'new-access-token',
            'refresh_token': 'new-refresh-token',
          },
        });
      }

      if (options.path.endsWith('/users/me/')) {
        profileCalls++;
        final authHeader = options.headers['Authorization'] as String?;
        if (authHeader == 'Bearer old-access-token') {
          return jsonResponse(401, {'detail': 'Token expired'});
        }
        if (authHeader == 'Bearer new-access-token') {
          return jsonResponse(200, {
            'success': true,
            'message': 'OK',
            'data': {'id': 1, 'username': 'test'},
          });
        }
      }

      return jsonResponse(404, {'detail': 'Not found'});
    });

    dio.interceptors.add(authErrorInterceptor(dio));

    final response = await dio.get<Map<String, dynamic>>(
      '/users/me/',
      options: Options(headers: {'Authorization': 'Bearer old-access-token'}),
    );

    expect(response.statusCode, 200);
    expect(response.data?['data']['username'], 'test');
    expect(profileCalls, 2);

    verify(
      () => mockStorage.writeAuthTokens(
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      ),
    ).called(1);
  });

  test(
    'concurrent 401 errors trigger only one refresh request and retry all',
    () async {
      when(
        () => mockStorage.getRefreshToken(),
      ).thenAnswer((_) async => 'valid-refresh-token');
      when(
        () => mockStorage.getAccessToken(),
      ).thenAnswer((_) async => 'new-access-token');
      when(
        () => mockStorage.writeAuthTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      final dio = Dio();
      int refreshCalls = 0;
      int profileCalls = 0;

      dio.httpClientAdapter = MockHttpAdapter((options) async {
        if (options.path.endsWith('/auth/refresh/')) {
          refreshCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return jsonResponse(200, {
            'success': true,
            'message': 'OK',
            'data': {
              'access_token': 'new-access-token',
              'refresh_token': 'new-refresh-token',
            },
          });
        }

        if (options.path.endsWith('/users/me/')) {
          profileCalls++;
          final authHeader = options.headers['Authorization'] as String?;
          if (authHeader == 'Bearer old-access-token') {
            return jsonResponse(401, {'detail': 'Token expired'});
          }
          if (authHeader == 'Bearer new-access-token') {
            return jsonResponse(200, {
              'success': true,
              'message': 'OK',
              'data': {'id': 1, 'username': 'test'},
            });
          }
        }

        return jsonResponse(404, {'detail': 'Not found'});
      });

      dio.interceptors.add(authErrorInterceptor(dio));

      final results = await Future.wait([
        dio.get<Map<String, dynamic>>(
          '/users/me/',
          options: Options(
            headers: {'Authorization': 'Bearer old-access-token'},
          ),
        ),
        dio.get<Map<String, dynamic>>(
          '/users/me/',
          options: Options(
            headers: {'Authorization': 'Bearer old-access-token'},
          ),
        ),
        dio.get<Map<String, dynamic>>(
          '/users/me/',
          options: Options(
            headers: {'Authorization': 'Bearer old-access-token'},
          ),
        ),
      ]);

      expect(results.length, 3);
      for (final res in results) {
        expect(res.statusCode, 200);
        expect(res.data?['data']['username'], 'test');
      }
      expect(refreshCalls, 1);
      expect(profileCalls, 6); // 3 initial failures + 3 retried successes
    },
  );

  test('401 error fails refresh when refresh token is invalid', () async {
    when(
      () => mockStorage.getRefreshToken(),
    ).thenAnswer((_) async => 'invalid-refresh');
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'old-access-token');
    when(() => mockStorage.clearAuthTokens()).thenAnswer((_) async {});

    final dio = Dio();

    dio.httpClientAdapter = MockHttpAdapter((options) async {
      if (options.path.endsWith('/auth/refresh/')) {
        return jsonResponse(401, {'detail': 'Invalid refresh token'});
      }
      if (options.path.endsWith('/users/me/')) {
        return jsonResponse(401, {'detail': 'Token expired'});
      }
      return jsonResponse(404, {'detail': 'Not found'});
    });

    dio.interceptors.add(authErrorInterceptor(dio));

    await expectLater(
      () => dio.get<Map<String, dynamic>>(
        '/users/me/',
        options: Options(headers: {'Authorization': 'Bearer old-access-token'}),
      ),
      throwsA(isA<DioException>()),
    );
  });
}
