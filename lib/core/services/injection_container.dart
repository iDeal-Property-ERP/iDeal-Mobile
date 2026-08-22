import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/main.dart';
import 'package:ideal_mobile/presentation/booking/booking_injection.dart';
import 'package:ideal_mobile/presentation/chat/chat_injection.dart';
import 'package:ideal_mobile/presentation/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:ideal_mobile/presentation/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:ideal_mobile/presentation/favorites/domain/repositories/favorites_repository.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/get_favorites.dart';
import 'package:ideal_mobile/presentation/favorites/domain/usecases/set_listing_favorite.dart';
import 'package:ideal_mobile/presentation/listing_detail/listing_detail_injection.dart';
import 'package:ideal_mobile/presentation/listing_map/data/datasources/listing_map_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listing_map/data/repositories/listing_map_repository_impl.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/listings/data/datasources/listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/data/repositories/listings_repository_impl.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_recommended_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/record_search_activity.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/record_view_activity.dart';
import 'package:ideal_mobile/presentation/login/data/datasources/auth_remote_data_source.dart';
import 'package:ideal_mobile/presentation/login/data/repositories/auth_repository_impl.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/get_otp_methods.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/request_otp.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/verify_otp.dart';
import 'package:ideal_mobile/presentation/map/data/datasources/map_config_remote_data_source.dart';
import 'package:ideal_mobile/presentation/map/data/repositories/map_config_repository_impl.dart';
import 'package:ideal_mobile/presentation/map/domain/repositories/map_config_repository.dart';
import 'package:ideal_mobile/presentation/notifications/notifications_injection.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/support_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/repositories/profile_repository_impl.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/favorites_sync_service.dart';
import 'package:ideal_mobile/services/legacy_favorites_cleanup_service.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/services/recent_searches_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

final sl = GetIt.instance;
bool _isForceLoggingOutUser = false;

Future<void> configureDependencies({Dio? dio}) async {
  final cacheManager = CacheManager();
  await cacheManager.initialize();
  sl.registerSingleton<CacheManager>(cacheManager);
  sl.registerLazySingleton<SecureStorageService>(SecureStorageService.new);

  final pinnedDio =
      dio ??
      Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  _registerDioInterceptor(pinnedDio);
  sl<CacheManager>().attachCacheInterceptor(pinnedDio);

  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<GetOtpMethods>(
      () => GetOtpMethods(sl<AuthRepository>()),
    )
    ..registerLazySingleton<RequestOtp>(() => RequestOtp(sl<AuthRepository>()))
    ..registerLazySingleton<VerifyOtp>(() => VerifyOtp(sl<AuthRepository>()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton<SupportRemoteDataSource>(
      () => SupportRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton(() => GetProfile(sl<ProfileRepository>()))
    ..registerLazySingleton(() => UpdateProfile(sl<ProfileRepository>()))
    ..registerLazySingleton(() => UpdateProfileAvatar(sl<ProfileRepository>()))
    ..registerLazySingleton(() => RemoveProfileAvatar(sl<ProfileRepository>()))
    ..registerLazySingleton<ListingsRepository>(
      () => ListingsRepositoryImpl(sl<ListingsRemoteDataSource>()),
    )
    ..registerLazySingleton<ListingsRemoteDataSource>(
      () => ListingsRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton(() => GetListings(sl<ListingsRepository>()))
    ..registerLazySingleton(() => GetListingsCached(sl<ListingsRepository>()))
    ..registerLazySingleton(
      () => GetListingFilterOptions(sl<ListingsRepository>()),
    )
    ..registerLazySingleton(
      () => GetListingFilterOptionsCached(sl<ListingsRepository>()),
    )
    ..registerLazySingleton(
      () => GetRecommendedListings(sl<ListingsRepository>()),
    )
    ..registerLazySingleton(
      () => RecordSearchActivity(sl<ListingsRepository>()),
    )
    ..registerLazySingleton(() => RecordViewActivity(sl<ListingsRepository>()))
    ..registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
    )
    ..registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton(() => GetFavorites(sl<FavoritesRepository>()))
    ..registerLazySingleton(() => SetListingFavorite(sl<FavoritesRepository>()))
    ..registerLazySingleton<ListingMapRemoteDataSource>(
      () => ListingMapRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<ListingMapRepository>(
      () => ListingMapRepositoryImpl(sl<ListingMapRemoteDataSource>()),
    )
    ..registerLazySingleton<MapConfigRemoteDataSource>(
      () => MapConfigRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<MapConfigRepository>(
      () => MapConfigRepositoryImpl(
        remoteDataSource: sl<MapConfigRemoteDataSource>(),
        storageService: sl<SecureStorageService>(),
      ),
    )
    ..registerLazySingleton(FavoritesSyncService.new)
    ..registerLazySingleton(LegacyFavoritesCleanupService.new)
    ..registerLazySingleton(PerformanceMonitoringService.new)
    ..registerLazySingleton(RecentSearchesService.new)
    ..registerLazySingleton<Dio>(() => pinnedDio);

  registerNotificationsDependencies(sl);
  registerChatDependencies(sl);
  registerListingDetailDependencies(sl);
  registerBookingDependencies(sl);
}

void _registerDioInterceptor(Dio dio) {
  dio.interceptors.add(_authHeaderInterceptor());
  if (kDebugMode) {
    dio.interceptors.add(_approvedDioLogInterceptor());
  }

  if (AppConfig.appFlavor == AppFlavor.local ||
      AppConfig.appFlavor == AppFlavor.dev) {
    dio.interceptors.add(authErrorInterceptor(dio));
    debugPrint(
      '[HTTP] ${AppConfig.appFlavor.name} API mode: '
      'certificate pinning disabled',
    );
    return;
  }

  final certHash = _getCertHash();
  dio.interceptors.addAll([
    CertificatePinningInterceptor(
      allowedSHAFingerprints: [certHash],
      callFollowingErrorInterceptor: true,
    ),
    _sslPinningErrorInterceptor,
    authErrorInterceptor(dio),
  ]);
}

/// Logs only safe request metadata in debug builds.
///
/// Bodies, headers, query parameters, and Dio error messages are deliberately
/// excluded because they may contain credentials or user data.
InterceptorsWrapper _approvedDioLogInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      debugPrint('[Dio] -> ${options.method} ${options.uri.path}');
      handler.next(options);
    },
    onResponse: (response, handler) {
      final request = response.requestOptions;
      debugPrint(
        '[Dio] <- ${response.statusCode ?? 0} '
        '${request.method} ${request.uri.path}',
      );
      handler.next(response);
    },
    onError: (error, handler) {
      final request = error.requestOptions;
      final status = error.response?.statusCode;
      debugPrint(
        '[Dio] !! ${status ?? 'error'} '
        '${request.method} ${request.uri.path} (${error.type.name})',
      );
      handler.next(error);
    },
  );
}

InterceptorsWrapper _authHeaderInterceptor() {
  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      if (!_isTokenFreeEndpoint(options.uri.path)) {
        final accessToken = await sl<SecureStorageService>().getAccessToken();
        if (accessToken != null && accessToken.trim().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }

      handler.next(options);
    },
  );
}

bool _isTokenFreeEndpoint(String path) {
  const tokenFreeEndpoints = [
    '/mobile/auth/methods/',
    '/mobile/auth/otp/request/',
    '/mobile/auth/otp/verify/',
    '/auth/refresh/',
  ];
  return tokenFreeEndpoints.any(path.endsWith);
}

InterceptorsWrapper get _sslPinningErrorInterceptor {
  return InterceptorsWrapper(
    onError: (DioException dioError, ErrorInterceptorHandler handler) async {
      if (dioError.error.toString().contains(kConnectionIsNotSecureError)) {
        debugPrint('[SSL Pinning] Connection is not secure!');

        await rootNavigatorKey.currentContext!.router.replaceAll([
          const SslConnectionFailedRoute(),
        ]);
      }

      handler.next(dioError);
    },
  );
}

Future<bool>? _refreshTokensFuture;

Future<bool> _refreshTokens(Dio dio) {
  if (_refreshTokensFuture != null) {
    return _refreshTokensFuture!;
  }

  final completer = Completer<bool>();
  _refreshTokensFuture = completer.future;

  () async {
    try {
      final result = await _executeTokenRefresh(dio);
      completer.complete(result);
    } catch (_) {
      completer.complete(false);
    } finally {
      _refreshTokensFuture = null;
    }
  }();

  return completer.future;
}

Future<bool> _executeTokenRefresh(Dio dio) async {
  if (!sl.isRegistered<SecureStorageService>()) {
    return false;
  }
  final storage = sl<SecureStorageService>();
  final refreshToken = await storage.getRefreshToken();
  if (refreshToken == null || refreshToken.trim().isEmpty) {
    return false;
  }

  try {
    final response = await dio.post<dynamic>(
      '/auth/refresh/',
      data: {'refresh_token': refreshToken},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'skip_forced_logout': true},
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final body = response.data is Map ? response.data as Map : null;
      if (body != null) {
        final data = body['data'];
        if (data is Map) {
          final newAccess = data['access_token'] as String?;
          final newRefresh = data['refresh_token'] as String?;
          if (newAccess != null &&
              newAccess.trim().isNotEmpty &&
              newRefresh != null &&
              newRefresh.trim().isNotEmpty) {
            await storage.writeAuthTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );
            return true;
          }
        }
      }
    }
  } catch (e) {
    debugPrint('[AuthErrorInterceptor] Token refresh request failed: $e');
  }

  return false;
}

@visibleForTesting
InterceptorsWrapper authErrorInterceptor(Dio dio) => InterceptorsWrapper(
  onError: (DioException dioError, ErrorInterceptorHandler handler) async {
    final statusCode = dioError.response?.statusCode ?? 0;
    final failedAccessToken = _bearerAccessToken(dioError.requestOptions);

    final isOtpEndpoint =
        dioError.requestOptions.uri.path.endsWith('/mobile/auth/methods/') ||
        dioError.requestOptions.uri.path.endsWith(
          '/mobile/auth/otp/request/',
        ) ||
        dioError.requestOptions.uri.path.endsWith('/mobile/auth/otp/verify/');
    final isRefreshEndpoint = dioError.requestOptions.uri.path.endsWith(
      '/auth/refresh/',
    );
    final skipsForcedLogout =
        dioError.requestOptions.extra['skip_forced_logout'] == true;
    final isRetry = dioError.requestOptions.extra['is_auth_retry'] == true;

    debugPrint(
      '[AuthErrorInterceptor] status: $statusCode '
      'failedToken: $failedAccessToken',
    );

    if (statusCode == 401 &&
        !isOtpEndpoint &&
        !isRefreshEndpoint &&
        !skipsForcedLogout &&
        !isRetry &&
        failedAccessToken != null) {
      final refreshed = await _refreshTokens(dio);
      if (refreshed) {
        try {
          final newAccessToken = await sl<SecureStorageService>()
              .getAccessToken();
          final requestOptions = dioError.requestOptions;
          final headers = Map<String, dynamic>.from(requestOptions.headers);
          if (newAccessToken != null && newAccessToken.trim().isNotEmpty) {
            headers['Authorization'] = 'Bearer $newAccessToken';
          }
          final extra = Map<String, dynamic>.from(requestOptions.extra);
          extra['is_auth_retry'] = true;

          final response = await dio.fetch<dynamic>(
            requestOptions.copyWith(headers: headers, extra: extra),
          );
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return handler.next(e);
          }
          return handler.next(
            DioException(requestOptions: dioError.requestOptions, error: e),
          );
        }
      }
    }

    final shouldLogout =
        !_isForceLoggingOutUser &&
        !isOtpEndpoint &&
        !skipsForcedLogout &&
        failedAccessToken != null &&
        (statusCode == 401 || statusCode == 403);

    if (shouldLogout) {
      final accessToken = failedAccessToken;
      _isForceLoggingOutUser = true;
      try {
        if (!await _isCurrentBackendSession(accessToken)) return;

        await NotificationService.instance.unregisterDevice();

        // A fresh OTP login may finish while the cleanup request above is in
        // flight. Never clear credentials that replaced the failed token.
        if (!await _isCurrentBackendSession(accessToken)) return;

        await Prefs.clear();
        if (sl.isRegistered<SecureStorageService>()) {
          await sl<SecureStorageService>().clearAuthTokens();
        }
        await sl<CacheManager>().clearCachedApiResponse();
        final currentContext = rootNavigatorKey.currentContext;
        if (currentContext != null) {
          await currentContext.router.replaceAll([
            const LoginWithPhoneNumberRoute(),
          ]);
        } else {
          debugPrint('[AuthErrorInterceptor] No navigator context available');
        }
      } catch (e) {
        debugPrint('[AuthErrorInterceptor] Logout failed: $e');
      } finally {
        _isForceLoggingOutUser = false;
      }
    }

    handler.next(dioError);
  },
);

String? _bearerAccessToken(RequestOptions requestOptions) {
  for (final entry in requestOptions.headers.entries) {
    if (entry.key.toLowerCase() != 'authorization' || entry.value is! String) {
      continue;
    }

    final match = RegExp(
      r'^Bearer\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(entry.value.trim());
    final token = match?.group(1)?.trim();
    return token == null || token.isEmpty ? null : token;
  }
  return null;
}

Future<bool> _isCurrentBackendSession(String accessToken) async {
  if (!sl.isRegistered<SecureStorageService>()) return false;
  return await sl<SecureStorageService>().getAccessToken() == accessToken;
}

String _getCertHash() {
  final certificateHash = AppConfig.getDioCertHash();
  if (certificateHash.isEmpty) {
    throw Exception(
      '[SSL Pinning] Missing certificate hash for: '
      '${AppConfig.appFlavor.name}',
    );
  }

  if (certificateHash.length != 64) {
    throw Exception(
      '[SSL Pinning] Certificate hash length is not 64 characters. '
      'Current length: ${certificateHash.length}',
    );
  }

  debugPrint('[SSL Pinning] Using SHA-256 certHash: "$certificateHash"');
  return certificateHash;
}
