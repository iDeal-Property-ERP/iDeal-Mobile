import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetNotificationSettings with UseCaseWithoutParams<NotificationSettings> {
  const GetNotificationSettings(this._repository);

  final NotificationSettingsRepository _repository;

  @override
  ResultFuture<NotificationSettings> call() => _repository.getSettings();
}
