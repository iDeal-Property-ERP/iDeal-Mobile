import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/services/locale_service.dart';
import 'package:path_provider/path_provider.dart';

/// The public API response provenance that a screen may render.
///
/// [preview] is reserved for an in-memory screen snapshot. Disk responses are
/// [cache], and a completed server request is [fresh].
enum PublicDataOrigin { preview, cache, fresh }

/// One event emitted by an opt-in public stale-while-revalidate request.
class PublicCacheResult<T> {
  const PublicCacheResult({
    required this.data,
    required this.origin,
    this.isStale = false,
    this.refreshError,
  });

  final T data;
  final PublicDataOrigin origin;
  final bool isStale;
  final Object? refreshError;

  PublicCacheResult<R> mapData<R>(R Function(T value) transform) {
    return PublicCacheResult(
      data: transform(data),
      origin: origin,
      isStale: isStale,
      refreshError: refreshError,
    );
  }
}

enum PublicCacheRequest { cacheFirst, forceRefresh }

class CacheManager {
  CacheManager({CacheStore? store, String Function()? localeProvider})
    : _providedStore = store,
      _localeProvider = localeProvider ?? _defaultLocale;

  final CacheStore? _providedStore;
  final String Function() _localeProvider;

  late final CacheOptions _defaultCacheOptions;
  late final CacheOptions _publicCacheOptions;
  late final String _cacheDirectoryPath;

  Future<void> initialize() async {
    final directory = await getApplicationSupportDirectory();
    _cacheDirectoryPath = '${directory.path}/$kPublicApiCache';
    debugPrint('Cache directory: $_cacheDirectoryPath');

    final store = _providedStore ?? FileCacheStore(_cacheDirectoryPath);
    _defaultCacheOptions = CacheOptions(
      store: store,
      // The interceptor is attached to the shared Dio, so network-fresh must
      // be its default. Only explicitly supplied public options can cache.
      policy: CachePolicy.noCache,
    );
    _publicCacheOptions = CacheOptions(
      store: store,
      policy: CachePolicy.forceCache,
      maxStale: const Duration(hours: 24),
      keyBuilder: _publicCacheKey,
    );
  }

  void attachCacheInterceptor(Dio dio) {
    dio.interceptors.add(DioCacheInterceptor(options: _defaultCacheOptions));
  }

  /// Kept for existing callers. It is deliberately network-only.
  CacheOptions get defaultCacheOptions => _defaultCacheOptions;

  CacheOptions publicCacheOptions({required PublicCacheRequest request}) {
    return _publicCacheOptions.copyWith(
      policy: switch (request) {
        PublicCacheRequest.cacheFirst => CachePolicy.forceCache,
        PublicCacheRequest.forceRefresh => CachePolicy.refreshForceCache,
      },
    );
  }

  Future<void> invalidateProfile() async {
    try {
      await _defaultCacheOptions.store?.deleteFromPath(
        RegExp(r'/mobile/account/me/?$'),
      );
      debugPrint('Mobile profile cache invalidated.');
    } catch (e, stackTrace) {
      debugPrint('Error invalidating mobile profile cache: $e\n$stackTrace');
    }
  }

  CacheOptions noCacheOptions() {
    return _defaultCacheOptions;
  }

  CacheOptions customCacheOptions({
    CachePolicy? policy,
    CachePriority? priority,
    Duration? maxStale,
  }) {
    return _defaultCacheOptions.copyWith(
      policy: policy ?? _defaultCacheOptions.policy,
      priority: priority ?? _defaultCacheOptions.priority,
      maxStale: maxStale ?? _defaultCacheOptions.maxStale,
    );
  }

  Future<void> clearCachedApiResponse() async {
    try {
      await _defaultCacheOptions.store?.clean();
      debugPrint('Cache store cleaned successfully!');

      final cacheDirectory = Directory(_cacheDirectoryPath);
      if (await cacheDirectory.exists()) {
        await cacheDirectory.delete(recursive: true);
        debugPrint(
          'Cache directory at $_cacheDirectoryPath deleted successfully!',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error clearing cache: $e\n$stackTrace');
    }
  }

  String _publicCacheKey({
    required Uri url,
    Map<String, String>? headers,
    Object? body,
  }) {
    // Uri.toString() includes the full resolved URI and query string. The
    // locale and schema are deliberately part of the key, not a request
    // header, so a locale change can never read a previous language response.
    return buildPublicCacheKey(
      url: url,
      locale: _localeProvider(),
      headers: headers,
      body: body,
    );
  }

  static String buildPublicCacheKey({
    required Uri url,
    required String locale,
    Map<String, String>? headers,
    Object? body,
  }) =>
      'public-v$kPublicApiCacheSchemaVersion:$locale:'
      '${CacheOptions.defaultCacheKeyBuilder(url: url, headers: headers, body: body)}';

  static String _defaultLocale() =>
      LocaleService.locale.value?.languageCode ?? 'system';
}

/// Runs a public request as stale-while-revalidate without changing the
/// one-shot repository APIs. Consumers can opt into the stream when they are
/// ready to display cache provenance and a retry affordance.
class PublicCacheCoordinator {
  const PublicCacheCoordinator._();

  static Stream<PublicCacheResult<T>> staleWhileRevalidate<T>({
    required CacheManager cacheManager,
    required Future<Response<dynamic>> Function(CacheOptions options) request,
    required T Function(Response<dynamic> response) decode,
  }) async* {
    final firstResponse = await request(
      cacheManager.publicCacheOptions(request: PublicCacheRequest.cacheFirst),
    );
    final firstValue = decode(firstResponse);
    final isFromNetwork = firstResponse.extra[extraFromNetworkKey] == true;

    if (isFromNetwork) {
      yield PublicCacheResult(data: firstValue, origin: PublicDataOrigin.fresh);
      return;
    }

    yield PublicCacheResult(data: firstValue, origin: PublicDataOrigin.cache);
    try {
      final refreshResponse = await request(
        cacheManager.publicCacheOptions(
          request: PublicCacheRequest.forceRefresh,
        ),
      );
      yield PublicCacheResult(
        data: decode(refreshResponse),
        origin: PublicDataOrigin.fresh,
      );
    } catch (error) {
      // The cache was valid when it was surfaced. Keep it visible and let the
      // caller expose its normal retry control instead of replacing content
      // with an error state.
      yield PublicCacheResult(
        data: firstValue,
        origin: PublicDataOrigin.cache,
        isStale: true,
        refreshError: error,
      );
    }
  }
}
