import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';

class DeviceRegistrationPayload {
  const DeviceRegistrationPayload({
    required this.token,
    required this.platform,
    this.deviceId,
    this.appVersion,
    this.locale,
  });

  final String token;
  final String platform;
  final String? deviceId;
  final String? appVersion;
  final String? locale;

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'token': token, 'platform': platform};

    if (deviceId != null) result['device_id'] = deviceId;
    if (appVersion != null) result['app_version'] = appVersion;
    if (locale != null) result['locale'] = locale;
    return result;
  }
}

class DeviceRegistrationApi {
  DeviceRegistrationApi({Dio? dio}) : _dio = dio;

  static const _registerPath = '/mobile/devices/';
  static const _unregisterPath = '/mobile/devices/unregister/';
  static const _skipForcedLogoutExtraKey = 'skip_forced_logout';

  final Dio? _dio;

  Future<void> register(DeviceRegistrationPayload payload) async {
    await _post(_registerPath, payload.toJson());
  }

  Future<void> unregister(String token) async {
    if (token.trim().isEmpty) {
      debugPrint('[Push] Cannot unregister an empty device token.');
      return;
    }

    await _post(_unregisterPath, {'token': token});
  }

  Future<void> _post(String path, Map<String, dynamic> data) async {
    try {
      final client = _dio ?? sl<Dio>();
      final response = await client.post(
        path,
        data: data,
        options: Options(extra: {_skipForcedLogoutExtraKey: true}),
      );
      _ensureSuccessful(response);
    } catch (error) {
      debugPrint('[Push] Device API request failed: $error');
    }
  }

  void _ensureSuccessful(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final body = response.data;
    final isSuccessful =
        statusCode >= 200 &&
        statusCode < 300 &&
        body is Map &&
        body['success'] == true;

    if (isSuccessful) return;

    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : 'The device API returned an unsuccessful response.';
    throw StateError('$statusCode: $message');
  }
}
