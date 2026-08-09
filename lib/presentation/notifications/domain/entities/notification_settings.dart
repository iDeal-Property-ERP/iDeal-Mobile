import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';

class NotificationSettings extends Equatable {
  const NotificationSettings({
    required this.pushEnabled,
    required this.paymentsEnabled,
    required this.bookingsEnabled,
    required this.maintenanceEnabled,
    required this.leasesEnabled,
    required this.generalEnabled,
  });

  final bool pushEnabled;
  final bool paymentsEnabled;
  final bool bookingsEnabled;
  final bool maintenanceEnabled;
  final bool leasesEnabled;
  final bool generalEnabled;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? paymentsEnabled,
    bool? bookingsEnabled,
    bool? maintenanceEnabled,
    bool? leasesEnabled,
    bool? generalEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      paymentsEnabled: paymentsEnabled ?? this.paymentsEnabled,
      bookingsEnabled: bookingsEnabled ?? this.bookingsEnabled,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      leasesEnabled: leasesEnabled ?? this.leasesEnabled,
      generalEnabled: generalEnabled ?? this.generalEnabled,
    );
  }

  bool categoryEnabled(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.payments:
        return paymentsEnabled;
      case NotificationCategory.bookings:
        return bookingsEnabled;
      case NotificationCategory.maintenance:
        return maintenanceEnabled;
      case NotificationCategory.leases:
        return leasesEnabled;
      case NotificationCategory.general:
        return generalEnabled;
    }
  }

  @override
  List<Object> get props => [
    pushEnabled,
    paymentsEnabled,
    bookingsEnabled,
    maintenanceEnabled,
    leasesEnabled,
    generalEnabled,
  ];
}
