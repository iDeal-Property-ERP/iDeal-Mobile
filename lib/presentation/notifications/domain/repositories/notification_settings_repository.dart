import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class NotificationSettingsRepository {
  ResultFuture<NotificationSettings> getSettings();

  ResultFuture<NotificationSettings> updateSettings(
    NotificationSettingsUpdate update,
  );
}

class NotificationSettingsUpdate extends Equatable {
  const NotificationSettingsUpdate({
    this.pushEnabled,
    this.paymentsEnabled,
    this.bookingsEnabled,
    this.maintenanceEnabled,
    this.leasesEnabled,
    this.generalEnabled,
  });

  final bool? pushEnabled;
  final bool? paymentsEnabled;
  final bool? bookingsEnabled;
  final bool? maintenanceEnabled;
  final bool? leasesEnabled;
  final bool? generalEnabled;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (pushEnabled != null) json['push_enabled'] = pushEnabled;
    if (paymentsEnabled != null) {
      json['payments_enabled'] = paymentsEnabled;
    }
    if (bookingsEnabled != null) {
      json['bookings_enabled'] = bookingsEnabled;
    }
    if (maintenanceEnabled != null) {
      json['maintenance_enabled'] = maintenanceEnabled;
    }
    if (leasesEnabled != null) json['leases_enabled'] = leasesEnabled;
    if (generalEnabled != null) json['general_enabled'] = generalEnabled;
    return json;
  }

  @override
  List<Object?> get props => [
    pushEnabled,
    paymentsEnabled,
    bookingsEnabled,
    maintenanceEnabled,
    leasesEnabled,
    generalEnabled,
  ];
}
