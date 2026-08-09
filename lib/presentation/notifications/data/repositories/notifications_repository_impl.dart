import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<NotificationsPage> getNotifications({
    required int page,
    int perPage = 20,
    bool? isRead,
    NotificationCategory? category,
  }) async {
    try {
      return Right(
        await _remoteDataSource.getNotifications(
          page: page,
          perPage: perPage,
          isRead: isRead,
          category: category,
        ),
      );
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<int> getUnreadCount() async {
    try {
      return Right(await _remoteDataSource.getUnreadCount());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<AppNotification> markRead(int id) async {
    try {
      return Right(await _remoteDataSource.markRead(id));
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<int> markAllRead() async {
    try {
      return Right(await _remoteDataSource.markAllRead());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
