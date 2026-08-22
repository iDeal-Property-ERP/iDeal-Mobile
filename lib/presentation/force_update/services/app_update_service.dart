import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/force_update/models/app_update_info.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  const AppUpdateService({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  static const String path = '/mobile/config/version/';
  static const Duration timeout = Duration(seconds: 3);
  static const Duration normalUpdateTtl = Duration(hours: 12);
  static final RegExp _semverRegex = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$',
  );

  static String? resolvePlatformName({TargetPlatform? platform}) {
    final target = platform ?? defaultTargetPlatform;
    switch (target) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return null;
    }
  }

  static String? extractCleanSemver(String rawVersion) {
    final clean = rawVersion.split('+').first.split('-').first.trim();
    if (_semverRegex.hasMatch(clean)) {
      return clean;
    }
    return null;
  }

  Future<AppUpdateInfo> checkUpdate({
    PackageInfo? packageInfo,
    TargetPlatform? platformOverride,
  }) async {
    final platform = resolvePlatformName(platform: platformOverride);
    if (platform == null) {
      return AppUpdateInfo.none();
    }

    String currentVersion = '';
    try {
      final info = packageInfo ?? await PackageInfo.fromPlatform();
      final cleanVer = extractCleanSemver(info.version);
      if (cleanVer == null) {
        return AppUpdateInfo.none(currentVersion: info.version);
      }
      currentVersion = cleanVer;
    } catch (e) {
      debugPrint('[AppUpdateService] Failed to read package info: $e');
      return AppUpdateInfo.none();
    }

    try {
      final dioClient = _dio ?? (sl.isRegistered<Dio>() ? sl<Dio>() : Dio());
      final response = await dioClient.get<dynamic>(
        path,
        options: Options(
          headers: {
            'X-App-Platform': platform,
            'X-App-Version': currentVersion,
          },
          sendTimeout: timeout,
          receiveTimeout: timeout,
          extra: {'skip_cache': true},
        ),
      );

      final data = response.data;
      if (response.statusCode != 200 || data is! Map) {
        return AppUpdateInfo.none(currentVersion: currentVersion);
      }

      final body = Map<String, dynamic>.from(data);
      if (body['success'] != true || body['data'] is! Map) {
        return AppUpdateInfo.none(currentVersion: currentVersion);
      }

      final payload = Map<String, dynamic>.from(body['data'] as Map);
      return AppUpdateInfo.fromJson(payload);
    } catch (error) {
      debugPrint(
        '[AppUpdateService] Version check failed (failing open): $error',
      );
      return AppUpdateInfo.none(currentVersion: currentVersion);
    }
  }

  Future<bool> shouldShowUpdateNotice(
    AppUpdateInfo info, {
    TargetPlatform? platformOverride,
    DateTime? now,
  }) async {
    if (!info.hasUpdate ||
        info.storeUrl == null ||
        info.latestVersion == null) {
      return false;
    }

    if (info.isCritical) {
      return true;
    }

    final platform = resolvePlatformName(platform: platformOverride);
    if (platform == null) return false;

    final lastPlatform = await Prefs.getString(
      PrefKeys.kLastNormalUpdateNoticePlatform,
    );
    final lastVersion = await Prefs.getString(
      PrefKeys.kLastNormalUpdateNoticeVersion,
    );
    final lastTimestampStr = await Prefs.getString(
      PrefKeys.kLastNormalUpdateNoticeTimestamp,
    );

    if (lastPlatform == platform &&
        lastVersion == info.latestVersion &&
        lastTimestampStr != null) {
      final lastTime = DateTime.tryParse(lastTimestampStr);
      if (lastTime != null) {
        final currentTime = now ?? DateTime.now();
        if (currentTime.difference(lastTime) < normalUpdateTtl) {
          return false;
        }
      }
    }

    return true;
  }

  Future<void> recordNormalNoticeShown(
    AppUpdateInfo info, {
    TargetPlatform? platformOverride,
    DateTime? now,
  }) async {
    final platform = resolvePlatformName(platform: platformOverride);
    if (platform == null || info.latestVersion == null) return;

    final currentTime = now ?? DateTime.now();
    await Prefs.setString(PrefKeys.kLastNormalUpdateNoticePlatform, platform);
    await Prefs.setString(
      PrefKeys.kLastNormalUpdateNoticeVersion,
      info.latestVersion!,
    );
    await Prefs.setString(
      PrefKeys.kLastNormalUpdateNoticeTimestamp,
      currentTime.toIso8601String(),
    );
  }
}
