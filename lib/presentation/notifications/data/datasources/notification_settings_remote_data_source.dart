import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notification_settings_model.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class NotificationSettingsRemoteDataSource {
  Future<NotificationSettingsModel> getSettings();

  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsUpdate update,
  );
}

class NotificationSettingsRemoteDataSourceImpl
    implements NotificationSettingsRemoteDataSource {
  const NotificationSettingsRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _settingsPath = '/mobile/notification-settings/';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<NotificationSettingsModel> getSettings() async {
    final response = await _request(
      () => _dio.get(
        _settingsPath,
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Notification settings were not returned.',
    );

    return _parseData(response, data, NotificationSettingsModel.fromJson);
  }

  @override
  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsUpdate update,
  ) async {
    final response = await _request(
      () => _dio.patch(
        _settingsPath,
        data: update.toJson(),
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Updated notification settings were not returned.',
    );

    return _parseData(response, data, NotificationSettingsModel.fromJson);
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _messageFromData(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  DataMap _dataFromResponse(
    Response<dynamic> response, {
    required String missingDataMessage,
  }) {
    try {
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      if (response.statusCode != 200 || body['success'] != true) {
        throw APIException(
          message: _messageFromData(response.data) ?? 'Request failed.',
          statusCode: response.statusCode ?? 500,
        );
      }

      final data = body['data'];
      if (data is! Map) {
        throw APIException(
          message: missingDataMessage,
          statusCode: response.statusCode ?? 500,
        );
      }

      return Map<String, dynamic>.from(data);
    } on APIException {
      rethrow;
    } catch (error) {
      throw APIException(
        message: error.toString(),
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  T _parseData<T>(
    Response<dynamic> response,
    DataMap data,
    T Function(DataMap) parser,
  ) {
    try {
      return parser(data);
    } on APIException {
      rethrow;
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    } catch (error) {
      throw APIException(
        message: error.toString(),
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return data?.toString();

    final message = data['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
