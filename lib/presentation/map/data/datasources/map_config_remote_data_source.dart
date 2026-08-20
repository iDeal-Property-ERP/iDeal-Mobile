// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/map/data/models/map_config_response_model.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract interface class MapConfigRemoteDataSource {
  Future<MapConfigResponseModel> getMapConfig({CancelToken? cancelToken});
}

class MapConfigRemoteDataSourceImpl implements MapConfigRemoteDataSource {
  const MapConfigRemoteDataSourceImpl(this._dio);

  static const path = '/mobile/config/map/';

  final Dio _dio;

  @override
  Future<MapConfigResponseModel> getMapConfig({
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, cancelToken: cancelToken);
      final body = _mapValue(response.data);
      if (response.statusCode != 200 || body?['success'] != true) {
        throw APIException(
          message: _message(response.data) ?? 'Map config request failed.',
          statusCode: response.statusCode ?? 500,
        );
      }
      try {
        return MapConfigResponseModel.fromJson(body!);
      } on FormatException catch (error) {
        throw APIException(
          message: error.message,
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw APIException(
        message:
            _message(error.response?.data) ??
            error.message ??
            'Map config request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    }
  }
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String? _message(dynamic value) {
  final map = _mapValue(value);
  final message = map?['message'];
  return message is String && message.trim().isNotEmpty ? message : null;
}
