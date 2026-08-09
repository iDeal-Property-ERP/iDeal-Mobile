import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/app_notification_model.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notifications_page_model.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsPageModel> getNotifications({
    required int page,
    int perPage = 20,
    bool? isRead,
    NotificationCategory? category,
  });

  Future<int> getUnreadCount();

  Future<AppNotificationModel> markRead(int id);

  Future<int> markAllRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _notificationsPath = '/mobile/notifications/';
  static const _unreadCountPath = '/mobile/notifications/unread-count/';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<NotificationsPageModel> getNotifications({
    required int page,
    int perPage = 20,
    bool? isRead,
    NotificationCategory? category,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (isRead != null) queryParameters['is_read'] = isRead;
    if (category != null) queryParameters['category'] = category.apiValue;

    final response = await _request(
      () => _dio.get(
        _notificationsPath,
        queryParameters: queryParameters,
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Notifications were not returned.',
    );

    return _parseData(response, data, NotificationsPageModel.fromJson);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _request(
      () => _dio.get(
        _unreadCountPath,
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Unread notification count was not returned.',
    );

    return _parseData(
      response,
      data,
      (json) => _requiredInt(json, 'unread_count'),
    );
  }

  @override
  Future<AppNotificationModel> markRead(int id) async {
    final response = await _request(
      () => _dio.post('/mobile/notifications/$id/read/'),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'The notification was not returned.',
    );

    return _parseData(response, data, AppNotificationModel.fromJson);
  }

  @override
  Future<int> markAllRead() async {
    final response = await _request(
      () => _dio.post('/mobile/notifications/read-all/'),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Updated notification count was not returned.',
    );

    return _parseData(response, data, (json) => _requiredInt(json, 'updated'));
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

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid $key.');
}
