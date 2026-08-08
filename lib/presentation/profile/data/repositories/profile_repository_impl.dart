import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<MobileUserProfile> getProfile() async {
    try {
      return Right(await _remoteDataSource.getProfile());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<MobileUserProfile> updateProfile(
    MobileUserProfile profile,
  ) async {
    try {
      return Right(await _remoteDataSource.updateProfile(profile));
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<MobileUserProfile> updateAvatar(File image) async {
    try {
      return Right(await _remoteDataSource.updateAvatar(image));
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<MobileUserProfile> removeAvatar() async {
    try {
      return Right(await _remoteDataSource.removeAvatar());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
