import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/data/models/phone_change_otp_challenge.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

abstract class ProfileRemoteDataSource {
  Future<MobileUserProfile> getProfile();

  Future<MobileUserProfile> updateProfile(MobileUserProfile profile);

  Future<MobileUserProfile> updateAvatar(File image);

  Future<MobileUserProfile> removeAvatar();

  Future<List<String>> getPhoneChangeOtpMethods();

  Future<PhoneChangeOtpChallenge> requestPhoneChangeOtp({
    required String phone,
    required String channel,
  });

  Future<MobileUserProfile> confirmPhoneChange({
    required String phone,
    required String code,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._dio, this._cacheManager);

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<MobileUserProfile> getProfile() async {
    final response = await _request(() => _dio.get('/mobile/account/me/'));
    return _profileFromResponse(response);
  }

  @override
  Future<MobileUserProfile> updateProfile(MobileUserProfile profile) async {
    final response = await _request(
      () => _dio.put('/mobile/account/me/', data: profile.toUpdateJson()),
    );
    return _profileFromMutationResponse(response);
  }

  @override
  Future<MobileUserProfile> updateAvatar(File image) async {
    final response = await _request(
      () => _dio.put(
        '/mobile/account/me/avatar/',
        data: FormData.fromMap({
          'image': MultipartFile.fromFileSync(image.path),
        }),
      ),
    );
    return _profileFromMutationResponse(response);
  }

  @override
  Future<MobileUserProfile> removeAvatar() async {
    final response = await _request(
      () => _dio.delete('/mobile/account/me/avatar/'),
    );
    return _profileFromMutationResponse(response);
  }

  @override
  Future<List<String>> getPhoneChangeOtpMethods() async {
    final response = await _request(() => _dio.get('/mobile/auth/methods/'));
    final data = _dataFromSuccessfulResponse(response);
    final channels = data['channels'];
    return channels is List ? channels.whereType<String>().toList() : const [];
  }

  @override
  Future<PhoneChangeOtpChallenge> requestPhoneChangeOtp({
    required String phone,
    required String channel,
  }) async {
    final response = await _request(
      () => _dio.post(
        '/mobile/account/phone/otp/request/',
        data: {'phone': phone, 'channel': channel},
      ),
      preferErrorDetail: true,
    );
    try {
      return PhoneChangeOtpChallenge.fromJson(
        _dataFromSuccessfulResponse(response, preferErrorDetail: true),
      );
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  @override
  Future<MobileUserProfile> confirmPhoneChange({
    required String phone,
    required String code,
  }) async {
    final response = await _request(
      () => _dio.post(
        '/mobile/account/phone/confirm/',
        data: {'phone': phone, 'code': code},
      ),
      preferErrorDetail: true,
    );
    return _profileFromMutationResponse(response, preferErrorDetail: true);
  }

  Future<MobileUserProfile> _profileFromMutationResponse(
    Response<dynamic> response, {
    bool preferErrorDetail = false,
  }) async {
    final profile = _profileFromResponse(
      response,
      preferErrorDetail: preferErrorDetail,
    );
    await _cacheManager.invalidateProfile();
    return profile;
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request, {
    bool preferErrorDetail = false,
  }) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _errorMessageFromData(error.response?.data, preferErrorDetail) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  MobileUserProfile _profileFromResponse(
    Response<dynamic> response, {
    bool preferErrorDetail = false,
  }) {
    final data = _dataFromSuccessfulResponse(
      response,
      preferErrorDetail: preferErrorDetail,
    );
    try {
      return MobileUserProfile.fromJson(data);
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  Map<String, dynamic> _dataFromSuccessfulResponse(
    Response<dynamic> response, {
    bool preferErrorDetail = false,
  }) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    if (response.statusCode != 200 || body['success'] != true) {
      throw APIException(
        message:
            _errorMessageFromData(response.data, preferErrorDetail) ??
            'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }

    final data = body['data'];
    if (data is! Map) {
      throw APIException(
        message: 'Profile details were not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  String? _errorMessageFromData(dynamic data, bool preferErrorDetail) {
    if (data is! Map) return data?.toString();

    final error = data['error'];
    if (preferErrorDetail && error is String && error.trim().isNotEmpty) {
      return error;
    }
    final message = data['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
