import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late ProfileRemoteDataSourceImpl dataSource;

  Response<dynamic> response(int statusCode, dynamic data) => Response<dynamic>(
    requestOptions: RequestOptions(path: '/mobile/account/me/'),
    statusCode: statusCode,
    data: data,
  );

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    when(() => cacheManager.invalidateProfile()).thenAnswer((_) async {});
    dataSource = ProfileRemoteDataSourceImpl(dio, cacheManager);
  });

  test('parses the mobile me response', () async {
    when(() => dio.get('/mobile/account/me/')).thenAnswer(
      (_) async => response(200, {
        'success': true,
        'message': 'OK',
        'data': {
          'id': 3,
          'first_name': 'Aziz',
          'last_name': 'Karimov',
          'patronymic': null,
          'email': 'aziz@example.com',
          'phone': '+998901234567',
          'nationality': 'Uzbek',
          'avatar_url': null,
        },
      }),
    );

    final profile = await dataSource.getProfile();

    expect(profile.id, 3);
    expect(profile.displayName, 'Aziz Karimov');
    expect(profile.phone, '+998901234567');
    expect(profile.avatarUrl, isNull);
  });

  test('sends only editable profile fields for an update', () async {
    const profile = MobileUserProfile(
      id: 3,
      firstName: 'Aziz',
      lastName: null,
      patronymic: null,
      email: 'aziz@example.com',
      phone: '+998901234567',
      nationality: null,
      avatarUrl: null,
    );
    when(
      () => dio.put('/mobile/account/me/', data: profile.toUpdateJson()),
    ).thenAnswer(
      (_) async => response(200, {
        'success': true,
        'message': 'OK',
        'data': {
          'id': 3,
          'first_name': 'Aziz',
          'last_name': null,
          'patronymic': null,
          'email': 'aziz@example.com',
          'phone': '+998901234567',
          'nationality': null,
          'avatar_url': null,
        },
      }),
    );

    await dataSource.updateProfile(profile);

    verify(
      () => dio.put('/mobile/account/me/', data: profile.toUpdateJson()),
    ).called(1);
    verify(() => cacheManager.invalidateProfile()).called(1);
  });

  test('uses the API error message for failed responses', () async {
    when(() => dio.get('/mobile/account/me/')).thenAnswer(
      (_) async => response(409, {
        'success': false,
        'message': 'Data conflict',
        'error': 'This email is already in use',
      }),
    );

    expect(
      dataSource.getProfile,
      throwsA(
        isA<APIException>().having(
          (error) => error.message,
          'message',
          'Data conflict',
        ),
      ),
    );
  });

  test('uploads an avatar as multipart form data', () async {
    final image = File('${Directory.systemTemp.path}/profile-avatar-test.png')
      ..writeAsBytesSync([0]);
    addTearDown(() => image.deleteSync());
    when(
      () => dio.put('/mobile/account/me/avatar/', data: any(named: 'data')),
    ).thenAnswer(
      (_) async => response(200, {
        'success': true,
        'message': 'OK',
        'data': {
          'id': 3,
          'first_name': 'Aziz',
          'last_name': null,
          'patronymic': null,
          'email': 'aziz@example.com',
          'phone': '+998901234567',
          'nationality': null,
          'avatar_url':
              'https://api.example.com/media/users/avatars/avatar.png',
        },
      }),
    );

    final profile = await dataSource.updateAvatar(image);

    expect(profile.avatarUrl, contains('/users/avatars/avatar.png'));
    verify(
      () => dio.put('/mobile/account/me/avatar/', data: any(named: 'data')),
    ).called(1);
    verify(() => cacheManager.invalidateProfile()).called(1);
  });

  test('deletes the avatar and parses the refreshed profile', () async {
    when(() => dio.delete('/mobile/account/me/avatar/')).thenAnswer(
      (_) async => response(200, {
        'success': true,
        'message': 'OK',
        'data': {
          'id': 3,
          'first_name': 'Aziz',
          'last_name': null,
          'patronymic': null,
          'email': 'aziz@example.com',
          'phone': '+998901234567',
          'nationality': null,
          'avatar_url': null,
        },
      }),
    );

    final profile = await dataSource.removeAvatar();

    expect(profile.avatarUrl, isNull);
    verify(() => dio.delete('/mobile/account/me/avatar/')).called(1);
    verify(() => cacheManager.invalidateProfile()).called(1);
  });
}
