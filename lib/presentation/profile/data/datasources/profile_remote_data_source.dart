import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

abstract class ProfileRemoteDataSource {
  Future<MobileUserProfile> getProfile();

  Future<MobileUserProfile> updateProfile(MobileUserProfile profile);

  Future<MobileUserProfile> updateAvatar(File image);

  Future<MobileUserProfile> removeAvatar();
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

  Future<MobileUserProfile> _profileFromMutationResponse(
    Response<dynamic> response,
  ) async {
    final profile = _profileFromResponse(response);
    await _cacheManager.invalidateProfile();
    return profile;
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

  MobileUserProfile _profileFromResponse(Response<dynamic> response) {
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
        message: 'Profile details were not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }

    try {
      return MobileUserProfile.fromJson(Map<String, dynamic>.from(data));
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
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
