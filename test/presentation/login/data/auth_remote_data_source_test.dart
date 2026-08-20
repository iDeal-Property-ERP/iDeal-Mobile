import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/login/data/datasources/auth_remote_data_source.dart';
import 'package:ideal_mobile/presentation/login/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockDio dio;
  late AuthRemoteDataSourceImpl dataSource;

  Response<dynamic> response(
    int statusCode,
    dynamic data, {
    String path = '/mobile/auth/methods/',
  }) => Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );

  setUp(() {
    dio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio);
  });

  group('AuthRemoteDataSourceImpl.getOtpMethods', () {
    test('returns channel list when request succeeds', () async {
      when(
        () => dio.get('/mobile/auth/methods/', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => response(200, {
          'success': true,
          'message': 'OK',
          'data': {
            'channels': ['telegram', 'sms'],
          },
        }),
      );

      final result = await dataSource.getOtpMethods();

      expect(result, ['telegram', 'sms']);
    });

    test('throws APIException when status is not successful', () async {
      when(
        () => dio.get('/mobile/auth/methods/', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => response(500, {
          'success': false,
          'message': 'Server error',
          'data': null,
        }),
      );

      expect(() => dataSource.getOtpMethods(), throwsA(isA<APIException>()));
    });
  });

  group('AuthRepositoryImpl.getOtpMethods', () {
    late MockAuthRemoteDataSource mockRemoteDataSource;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(mockRemoteDataSource);
    });

    test('returns Right(channels) on success', () async {
      when(
        () => mockRemoteDataSource.getOtpMethods(),
      ).thenAnswer((_) async => ['telegram']);

      final result = await repository.getOtpMethods();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), ['telegram']);
    });

    test('returns Left(APIFailure) on exception', () async {
      when(
        () => mockRemoteDataSource.getOtpMethods(),
      ).thenThrow(const APIException(message: 'Error', statusCode: 500));

      final result = await repository.getOtpMethods();

      expect(result.isLeft(), isTrue);
    });
  });
}
