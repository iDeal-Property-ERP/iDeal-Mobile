import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class MarkAllNotificationsRead with UseCaseWithoutParams<int> {
  const MarkAllNotificationsRead(this._repository);

  final NotificationsRepository _repository;

  @override
  ResultFuture<int> call() => _repository.markAllRead();
}
