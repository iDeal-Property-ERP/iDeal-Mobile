import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/list_property/data/models/property_upload_config_model.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class PropertyUploadRemoteDataSource {
  Future<PropertyUploadConfigModel> getConfig();

  Future<PropertyUploadResultModel> submitProperty(
    PropertyUploadPayload payload,
  );
}

class PropertyUploadRemoteDataSourceImpl
    implements PropertyUploadRemoteDataSource {
  const PropertyUploadRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _basePath = '/mobile/property-upload';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<PropertyUploadConfigModel> getConfig() async {
    final response = await _request(
      () => _dio.get(
        '$_basePath/config/',
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(response);
    return PropertyUploadConfigModel.fromJson(data);
  }

  @override
  Future<PropertyUploadResultModel> submitProperty(
    PropertyUploadPayload payload,
  ) async {
    final multipartFiles = <MultipartFile>[];
    for (final path in payload.imagePaths) {
      if (File(path).existsSync()) {
        multipartFiles.add(MultipartFile.fromFileSync(path));
      }
    }

    final formData = FormData();
    formData.fields.add(MapEntry('payload', jsonEncode(payload.toJson())));
    for (final file in multipartFiles) {
      formData.files.add(MapEntry('images', file));
    }

    final response = await _request(
      () => _dio.post(
        '$_basePath/submit/',
        data: formData,
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(response, accepted: {200, 201});
    return PropertyUploadResultModel.fromJson(data);
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
    } on APIException {
      rethrow;
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  DataMap _dataFromResponse(
    Response<dynamic> response, {
    Set<int> accepted = const {200},
  }) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    if (!accepted.contains(response.statusCode) || body['success'] != true) {
      throw APIException(
        message: _messageFromData(response.data) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }
    final data = body['data'];
    if (data is! Map) {
      throw APIException(
        message: 'Invalid response payload.',
        statusCode: response.statusCode ?? 500,
      );
    }
    return Map<String, dynamic>.from(data);
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return null;
    final message = data['message'];
    final error = data['error'];
    if (error != null) {
      if (error is List) {
        return error.join('\n');
      }
      return error.toString();
    }
    if (message != null) return message.toString();
    return null;
  }
}
