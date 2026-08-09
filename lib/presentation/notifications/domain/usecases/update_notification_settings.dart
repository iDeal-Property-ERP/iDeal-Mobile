import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class UpdateNotificationSettings
    with
        UseCaseWithParams<
          NotificationSettings,
          UpdateNotificationSettingsParams
        > {
  const UpdateNotificationSettings(this._repository);

  final NotificationSettingsRepository _repository;

  @override
  ResultFuture<NotificationSettings> call(
    UpdateNotificationSettingsParams params,
  ) {
    return _repository.updateSettings(params.update);
  }
}

class UpdateNotificationSettingsParams extends Equatable {
  const UpdateNotificationSettingsParams({required this.update});

  final NotificationSettingsUpdate update;

  @override
  List<Object> get props => [update];
}
