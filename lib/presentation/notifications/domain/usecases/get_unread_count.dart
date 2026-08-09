import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetUnreadCount with UseCaseWithoutParams<int> {
  const GetUnreadCount(this._repository);

  final NotificationsRepository _repository;

  @override
  ResultFuture<int> call() => _repository.getUnreadCount();
}
