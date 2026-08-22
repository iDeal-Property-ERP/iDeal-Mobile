import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/force_update/models/app_update_info.dart';
import 'package:ideal_mobile/presentation/force_update/services/app_update_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AppUpdateService service;

  setUp(() {
    mockDio = MockDio();
    service = AppUpdateService(dio: mockDio);

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    Prefs.init();
  });

  group('AppUpdateService helpers', () {
    test('resolvePlatformName maps TargetPlatform correctly', () {
      expect(
        AppUpdateService.resolvePlatformName(platform: TargetPlatform.android),
        'android',
      );
      expect(
        AppUpdateService.resolvePlatformName(platform: TargetPlatform.iOS),
        'ios',
      );
      expect(
        AppUpdateService.resolvePlatformName(platform: TargetPlatform.linux),
        isNull,
      );
      expect(
        AppUpdateService.resolvePlatformName(platform: TargetPlatform.macOS),
        isNull,
      );
      expect(
        AppUpdateService.resolvePlatformName(platform: TargetPlatform.windows),
        isNull,
      );
    });

    test('extractCleanSemver extracts valid MAJOR.MINOR.PATCH', () {
      expect(AppUpdateService.extractCleanSemver('1.2.3'), '1.2.3');
      expect(AppUpdateService.extractCleanSemver('0.1.0+4'), '0.1.0');
      expect(AppUpdateService.extractCleanSemver('2.0.0-beta.1+12'), '2.0.0');
      expect(AppUpdateService.extractCleanSemver('1.0'), isNull);
      expect(AppUpdateService.extractCleanSemver('v1.0.0'), isNull);
      expect(AppUpdateService.extractCleanSemver('invalid'), isNull);
    });
  });

  group('AppUpdateService checkUpdate', () {
    test('returns parsed AppUpdateInfo on successful response', () async {
      when(
        () => mockDio.get<dynamic>(
          AppUpdateService.path,
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: AppUpdateService.path),
          statusCode: 200,
          data: {
            'success': true,
            'message': 'OK',
            'data': {
              'update_type': 'normal',
              'current_version': '0.1.0',
              'latest_version': '1.0.0',
              'store_url': 'https://store.url',
            },
          },
        ),
      );

      final packageInfo = PackageInfo(
        appName: 'iDeal',
        packageName: 'com.ideal.mobile',
        version: '0.1.0',
        buildNumber: '1',
      );

      final result = await service.checkUpdate(
        packageInfo: packageInfo,
        platformOverride: TargetPlatform.android,
      );

      expect(result.updateType, AppUpdateType.normal);
      expect(result.latestVersion, '1.0.0');
      expect(result.storeUrl, 'https://store.url');

      final capturedOptions =
          verify(
                () => mockDio.get<dynamic>(
                  AppUpdateService.path,
                  options: captureAny(named: 'options'),
                ),
              ).captured.single
              as Options;

      expect(capturedOptions.headers?['X-App-Platform'], 'android');
      expect(capturedOptions.headers?['X-App-Version'], '0.1.0');
      expect(capturedOptions.sendTimeout, AppUpdateService.timeout);
      expect(capturedOptions.receiveTimeout, AppUpdateService.timeout);
    });

    test(
      'fails open on unsupported platform without making network call',
      () async {
        final result = await service.checkUpdate(
          platformOverride: TargetPlatform.linux,
        );

        expect(result.updateType, AppUpdateType.none);
        verifyNever(
          () => mockDio.get<dynamic>(any(), options: any(named: 'options')),
        );
      },
    );

    test('fails open on DioException (network error, timeout)', () async {
      when(
        () => mockDio.get<dynamic>(
          AppUpdateService.path,
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: AppUpdateService.path),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final packageInfo = PackageInfo(
        appName: 'iDeal',
        packageName: 'com.ideal.mobile',
        version: '0.1.0',
        buildNumber: '1',
      );

      final result = await service.checkUpdate(
        packageInfo: packageInfo,
        platformOverride: TargetPlatform.iOS,
      );

      expect(result.updateType, AppUpdateType.none);
    });

    test('fails open on non-200 status code', () async {
      when(
        () => mockDio.get<dynamic>(
          AppUpdateService.path,
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: AppUpdateService.path),
          statusCode: 500,
          data: {'success': false, 'message': 'Internal Error'},
        ),
      );

      final packageInfo = PackageInfo(
        appName: 'iDeal',
        packageName: 'com.ideal.mobile',
        version: '0.1.0',
        buildNumber: '1',
      );

      final result = await service.checkUpdate(
        packageInfo: packageInfo,
        platformOverride: TargetPlatform.android,
      );

      expect(result.updateType, AppUpdateType.none);
    });

    test('fails open on malformed response body', () async {
      when(
        () => mockDio.get<dynamic>(
          AppUpdateService.path,
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: AppUpdateService.path),
          statusCode: 200,
          data: 'invalid string payload',
        ),
      );

      final packageInfo = PackageInfo(
        appName: 'iDeal',
        packageName: 'com.ideal.mobile',
        version: '0.1.0',
        buildNumber: '1',
      );

      final result = await service.checkUpdate(
        packageInfo: packageInfo,
        platformOverride: TargetPlatform.android,
      );

      expect(result.updateType, AppUpdateType.none);
    });
  });

  group('AppUpdateService TTL suppression', () {
    const normalInfo = AppUpdateInfo(
      updateType: AppUpdateType.normal,
      currentVersion: '0.1.0',
      latestVersion: '1.0.0',
      storeUrl: 'https://store.url',
    );

    const criticalInfo = AppUpdateInfo(
      updateType: AppUpdateType.critical,
      currentVersion: '0.1.0',
      latestVersion: '1.0.0',
      storeUrl: 'https://store.url',
    );

    test('critical updates are always shown regardless of TTL', () async {
      final now = DateTime(2026, 1, 1, 12);
      await service.recordNormalNoticeShown(
        normalInfo,
        platformOverride: TargetPlatform.android,
        now: now,
      );

      final shouldShow = await service.shouldShowUpdateNotice(
        criticalInfo,
        platformOverride: TargetPlatform.android,
        now: now.add(const Duration(minutes: 5)),
      );

      expect(shouldShow, isTrue);
    });

    test(
      'normal update shown first time, suppressed for 12 hours, shown after',
      () async {
        final initialTime = DateTime(2026, 1, 1, 10);

        // First time: no prefs record
        final firstCheck = await service.shouldShowUpdateNotice(
          normalInfo,
          platformOverride: TargetPlatform.android,
          now: initialTime,
        );
        expect(firstCheck, isTrue);

        // Record display
        await service.recordNormalNoticeShown(
          normalInfo,
          platformOverride: TargetPlatform.android,
          now: initialTime,
        );

        // Check after 6 hours -> suppressed (< 12h)
        final withinTtl = await service.shouldShowUpdateNotice(
          normalInfo,
          platformOverride: TargetPlatform.android,
          now: initialTime.add(const Duration(hours: 6)),
        );
        expect(withinTtl, isFalse);

        // Check after 11 hours 59 mins -> suppressed
        final almostExpired = await service.shouldShowUpdateNotice(
          normalInfo,
          platformOverride: TargetPlatform.android,
          now: initialTime.add(const Duration(hours: 11, minutes: 59)),
        );
        expect(almostExpired, isFalse);

        // Check after 12 hours 1 min -> shown (>= 12h)
        final afterTtl = await service.shouldShowUpdateNotice(
          normalInfo,
          platformOverride: TargetPlatform.android,
          now: initialTime.add(const Duration(hours: 12, minutes: 1)),
        );
        expect(afterTtl, isTrue);
      },
    );

    test('newer target version bypasses TTL immediately', () async {
      final initialTime = DateTime(2026, 1, 1, 10);

      await service.recordNormalNoticeShown(
        normalInfo, // latestVersion: 1.0.0
        platformOverride: TargetPlatform.android,
        now: initialTime,
      );

      const newerInfo = AppUpdateInfo(
        updateType: AppUpdateType.normal,
        currentVersion: '0.1.0',
        latestVersion: '1.1.0', // New target version
        storeUrl: 'https://store.url',
      );

      // Check 10 minutes later with newer version -> bypasses TTL!
      final checkNewer = await service.shouldShowUpdateNotice(
        newerInfo,
        platformOverride: TargetPlatform.android,
        now: initialTime.add(const Duration(minutes: 10)),
      );
      expect(checkNewer, isTrue);
    });
  });
}
