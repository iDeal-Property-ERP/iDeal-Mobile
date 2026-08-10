import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notification_settings_model.dart';

void main() {
  test('parses and serializes notification settings', () {
    final model = NotificationSettingsModel.fromJson({
      'data': {
        'push_enabled': true,
        'payments_enabled': false,
        'bookings_enabled': true,
        'maintenance_enabled': false,
        'leases_enabled': true,
        'messages_enabled': true,
        'general_enabled': false,
      },
    });

    expect(model.pushEnabled, isTrue);
    expect(model.paymentsEnabled, isFalse);
    expect(model.bookingsEnabled, isTrue);
    expect(model.maintenanceEnabled, isFalse);
    expect(model.leasesEnabled, isTrue);
    expect(model.messagesEnabled, isTrue);
    expect(model.generalEnabled, isFalse);
    expect(model.toJson(), {
      'push_enabled': true,
      'payments_enabled': false,
      'bookings_enabled': true,
      'maintenance_enabled': false,
      'leases_enabled': true,
      'messages_enabled': true,
      'general_enabled': false,
    });
  });

  test('defaults messages to enabled when the backend omits the key', () {
    final model = NotificationSettingsModel.fromJson({
      'push_enabled': true,
      'payments_enabled': true,
      'bookings_enabled': true,
      'maintenance_enabled': true,
      'leases_enabled': true,
      'general_enabled': true,
    });

    expect(model.messagesEnabled, isTrue);
  });
}
