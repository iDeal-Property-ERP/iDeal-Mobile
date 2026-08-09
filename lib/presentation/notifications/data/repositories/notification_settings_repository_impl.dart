import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notification_settings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  const NotificationSettingsRepositoryImpl(this._remoteDataSource);

  final NotificationSettingsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<NotificationSettings> getSettings() async {
    try {
      return Right(await _remoteDataSource.getSettings());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<NotificationSettings> updateSettings(
    NotificationSettingsUpdate update,
  ) async {
    try {
      return Right(await _remoteDataSource.updateSettings(update));
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
