import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/login/data/datasources/auth_remote_data_source.dart';
import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  ResultVoid requestOtp({
    required String phone,
    required String channel,
  }) async {
    try {
      await _remoteDataSource.requestOtp(phone: phone, channel: channel);
      return const Right(null);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<AuthTokens> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final tokens = await _remoteDataSource.verifyOtp(
        phone: phone,
        code: code,
      );
      return Right(tokens);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
