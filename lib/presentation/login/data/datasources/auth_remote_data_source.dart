import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/utils/typedef.dart';

mixin AuthRemoteDataSource {
  Future<void> requestOtp({required String phone, required String channel});

  Future<AuthTokens> verifyOtp({required String phone, required String code});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> requestOtp({
    required String phone,
    required String channel,
  }) async {
    final response = await _post(
      '/mobile/auth/otp/request/',
      data: {'phone': phone, 'channel': channel},
    );
    _ensureSuccessfulResponse(response);
  }

  @override
  Future<AuthTokens> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _post(
      '/mobile/auth/otp/verify/',
      data: {'phone': phone, 'code': code},
    );
    final body = _ensureSuccessfulResponse(response);
    final data = body['data'];
    if (data is! Map) {
      throw APIException(
        message: 'Authentication tokens were not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }

    try {
      return AuthTokens.fromJson(Map<String, dynamic>.from(data));
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  Future<Response<dynamic>> _post(String path, {required DataMap data}) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: Options(validateStatus: (_) => true),
      );
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

  DataMap _ensureSuccessfulResponse(Response<dynamic> response) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    if (response.statusCode != 200 || body['success'] != true) {
      throw APIException(
        message: _messageFromData(response.data) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }

    return body;
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return data?.toString();

    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    return null;
  }
}
