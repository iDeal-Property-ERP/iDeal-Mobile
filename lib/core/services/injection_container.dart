import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/app_tour_service.dart';
import 'package:ideal_mobile/main.dart';
import 'package:ideal_mobile/presentation/booking/booking_injection.dart';
import 'package:ideal_mobile/presentation/chat/chat_injection.dart';
import 'package:ideal_mobile/presentation/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:ideal_mobile/presentation/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:ideal_mobile/presentation/feedback/domain/repositories/feedback_repository.dart';
import 'package:ideal_mobile/presentation/feedback/domain/usecases/submit_feedback.dart';
import 'package:ideal_mobile/presentation/listings/data/datasources/listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/data/repositories/listings_repository_impl.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listing_filter_options_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/get_listings_cached.dart';
import 'package:ideal_mobile/presentation/listing_detail/listing_detail_injection.dart';
import 'package:ideal_mobile/presentation/login/data/datasources/auth_remote_data_source.dart';
import 'package:ideal_mobile/presentation/login/data/repositories/auth_repository_impl.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/request_otp.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/verify_otp.dart';
import 'package:ideal_mobile/presentation/notifications/notifications_injection.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/repositories/profile_repository_impl.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/ai/gemini_service.dart';
import 'package:ideal_mobile/services/dynamic_icon_service.dart';
import 'package:ideal_mobile/services/favorites_service.dart';
import 'package:ideal_mobile/services/firebase_auth_services.dart';
import 'package:ideal_mobile/services/firestore_service.dart';
import 'package:ideal_mobile/services/in_app_review_service.dart';
import 'package:ideal_mobile/services/local_auth_services.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/services/remote_config_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/currency_converter/currency_converter_util.dart';
import 'package:ideal_mobile/utils/currency_converter/data/datasources/currency_converter_remote_data_source.dart';
import 'package:ideal_mobile/utils/currency_converter/data/repositories/currency_converter_repository_impl.dart';
import 'package:ideal_mobile/utils/currency_converter/domain/repositories/currency_converter_repository.dart';
import 'package:ideal_mobile/utils/currency_converter/domain/usecases/get_exchange_rate.dart';
import 'package:local_auth/local_auth.dart';

final sl = GetIt.instance;
bool _isForceLoggingOutUser = false;

Future<void> configureDependencies({
  FirebaseAuth? firebaseAuth,
  GoogleSignIn? googleSignIn,
  FirebaseAuthService? firebaseAuthService,
  Dio? dio,
}) async {
  sl.registerLazySingleton<FirebaseAuth>(
    () => firebaseAuth ?? FirebaseAuth.instance,
  );

  sl.registerLazySingleton<GoogleSignIn>(
    () => googleSignIn ?? GoogleSignIn.instance,
  );

  sl.registerLazySingleton<FirebaseAuthService>(
    () =>
        firebaseAuthService ??
        FirebaseAuthService(
          firebaseAuth: sl<FirebaseAuth>(),
          googleSignIn: sl<GoogleSignIn>(),
        ),
  );

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
    ..registerLazySingleton<RequestOtp>(() => RequestOtp(sl<AuthRepository>()))
    ..registerLazySingleton<VerifyOtp>(() => VerifyOtp(sl<AuthRepository>()))
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
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
    ..registerLazySingleton<FavoritesService>(FavoritesService.new)
    ..registerLazySingleton(() {
      final service = GeminiService();
      service.initialize();
      return service;
    }, dispose: (service) => service.dispose())
    ..registerLazySingleton<FirebasePerformance>(
      () => FirebasePerformance.instance,
    )
    ..registerLazySingleton(
      () =>
          PerformanceMonitoringService(performance: sl<FirebasePerformance>()),
    )
    ..registerLazySingleton(() => GetExchangeRate(sl()))
    ..registerLazySingleton<CurrencyConverterRepository>(
      () => CurrencyConverterRepositoryImpl(sl()),
    )
    ..registerLazySingleton<CurrencyConverterRemoteDatasource>(
      () => CurrencyConverterRemoteDataSrcImpl(sl()),
    )
    ..registerLazySingleton(() => CurrencyConverterUtil(sl()))
    ..registerLazySingleton<Dio>(() => pinnedDio)
    ..registerLazySingleton<LocalAuthService>(
      () => LocalAuthService(LocalAuthentication()),
    )
    ..registerLazySingleton<DynamicIconService>(
      () => DynamicIconService(remoteConfigService: RemoteConfigService()),
    )
    ..registerLazySingleton<InAppReviewService>(() => InAppReviewService())
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirestoreService>(
      () => FirestoreService(firestore: sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton(() => SubmitFeedback(sl()))
    ..registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepositoryImpl(sl()),
    )
    ..registerLazySingleton<FeedbackRemoteDatasource>(
      () => FeedbackRemoteDatasourceImpl(sl<FirestoreService>()),
    );

  registerNotificationsDependencies(sl);
  registerChatDependencies(sl);
  registerListingDetailDependencies(sl);
  registerBookingDependencies(sl);
}

void _registerDioInterceptor(Dio dio) {
  dio.interceptors.add(_authHeaderInterceptor());
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (message) => debugPrint('[Dio] $message'),
      ),
    );
  }

  if (AppConfig.appFlavor == AppFlavor.local ||
      AppConfig.appFlavor == AppFlavor.dev) {
    dio.interceptors.add(_authErrorInterceptor());
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
    _authErrorInterceptor(),
  ]);
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

        AppTourService.dismissTour();
        await rootNavigatorKey.currentContext!.router.replaceAll([
          const SslConnectionFailedRoute(),
        ]);
      }

      handler.next(dioError);
    },
  );
}

InterceptorsWrapper _authErrorInterceptor() => InterceptorsWrapper(
  onError: (DioException dioError, ErrorInterceptorHandler handler) async {
    final statusCode = dioError.response?.statusCode ?? 0;
    final failedAccessToken = _bearerAccessToken(dioError.requestOptions);

    debugPrint('[AuthErrorInterceptor] status: $statusCode');

    final isOtpEndpoint =
        dioError.requestOptions.uri.path.endsWith(
          '/mobile/auth/otp/request/',
        ) ||
        dioError.requestOptions.uri.path.endsWith('/mobile/auth/otp/verify/');
    final skipsForcedLogout =
        dioError.requestOptions.extra['skip_forced_logout'] == true;
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
        await sl<FirebaseAuthService>().signOut();

        final currentContext = rootNavigatorKey.currentContext;
        if (currentContext != null) {
          await currentContext.router.replaceAll([LoginWithPhoneNumberRoute()]);
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
