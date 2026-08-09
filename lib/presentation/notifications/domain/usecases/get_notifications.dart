import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetNotifications
    with UseCaseWithParams<NotificationsPage, GetNotificationsParams> {
  const GetNotifications(this._repository);

  final NotificationsRepository _repository;

  @override
  ResultFuture<NotificationsPage> call(GetNotificationsParams params) {
    return _repository.getNotifications(
      page: params.page,
      perPage: params.perPage,
      isRead: params.isRead,
      category: params.category,
    );
  }
}

class GetNotificationsParams extends Equatable {
  const GetNotificationsParams({
    required this.page,
    this.perPage = 20,
    this.isRead,
    this.category,
  });

  final int page;
  final int perPage;
  final bool? isRead;
  final NotificationCategory? category;

  @override
  List<Object?> get props => [page, perPage, isRead, category];
}
