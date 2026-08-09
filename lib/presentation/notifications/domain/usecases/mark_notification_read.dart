import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class MarkNotificationRead
    with UseCaseWithParams<AppNotification, MarkNotificationReadParams> {
  const MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  @override
  ResultFuture<AppNotification> call(MarkNotificationReadParams params) {
    return _repository.markRead(params.id);
  }
}

class MarkNotificationReadParams extends Equatable {
  const MarkNotificationReadParams({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}
