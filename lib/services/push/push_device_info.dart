import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:ideal_mobile/services/locale_service.dart';
import 'package:ideal_mobile/services/push/device_registration_api.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PushDeviceInfo {
  const PushDeviceInfo();

  Future<DeviceRegistrationPayload> buildPayload({
    required String token,
  }) async {
    final platform = _platform;
    final deviceId = await _deviceId();
    final appVersion = await _appVersion();
    final locale = _locale();

    return DeviceRegistrationPayload(
      token: token,
      platform: platform,
      deviceId: deviceId,
      appVersion: appVersion,
      locale: locale,
    );
  }

  String get _platform {
    try {
      return Platform.isIOS ? 'ios' : 'android';
    } catch (error) {
      debugPrint('[Push] Platform lookup failed: $error');
      return 'android';
    }
  }

  Future<String?> _deviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      }
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (error) {
      debugPrint('[Push] Device ID lookup failed: $error');
    }
    return null;
  }

  Future<String?> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (error) {
      debugPrint('[Push] App version lookup failed: $error');
      return null;
    }
  }

  String? _locale() {
    try {
      final appLocale = LocaleService.locale.value?.languageCode;
      if (appLocale != null && appLocale.isNotEmpty) return appLocale;
    } catch (error) {
      debugPrint('[Push] App locale lookup failed: $error');
    }

    try {
      final platformLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      return platformLocale.isEmpty ? null : platformLocale;
    } catch (error) {
      debugPrint('[Push] Platform locale lookup failed: $error');
      return null;
    }
  }
}
