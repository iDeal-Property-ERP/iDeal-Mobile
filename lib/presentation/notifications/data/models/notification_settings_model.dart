import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.pushEnabled,
    required super.paymentsEnabled,
    required super.bookingsEnabled,
    required super.maintenanceEnabled,
    required super.leasesEnabled,
    required super.messagesEnabled,
    required super.generalEnabled,
  });

  factory NotificationSettingsModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    return NotificationSettingsModel(
      pushEnabled: _requiredBool(data, 'push_enabled'),
      paymentsEnabled: _requiredBool(data, 'payments_enabled'),
      bookingsEnabled: _requiredBool(data, 'bookings_enabled'),
      maintenanceEnabled: _requiredBool(data, 'maintenance_enabled'),
      leasesEnabled: _requiredBool(data, 'leases_enabled'),
      messagesEnabled: _optionalBool(data, 'messages_enabled', fallback: true),
      generalEnabled: _requiredBool(data, 'general_enabled'),
    );
  }

  DataMap toJson() => {
    'push_enabled': pushEnabled,
    'payments_enabled': paymentsEnabled,
    'bookings_enabled': bookingsEnabled,
    'maintenance_enabled': maintenanceEnabled,
    'leases_enabled': leasesEnabled,
    'messages_enabled': messagesEnabled,
    'general_enabled': generalEnabled,
  };
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

bool _requiredBool(DataMap json, String key) {
  final value = json[key];
  if (value is bool) return value;
  if (value is num && (value == 0 || value == 1)) return value == 1;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
  }
  throw FormatException('Invalid $key.');
}

bool _optionalBool(DataMap json, String key, {required bool fallback}) {
  if (!json.containsKey(key)) return fallback;
  return _requiredBool(json, key);
}
