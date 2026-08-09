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
        'general_enabled': false,
      },
    });

    expect(model.pushEnabled, isTrue);
    expect(model.paymentsEnabled, isFalse);
    expect(model.bookingsEnabled, isTrue);
    expect(model.maintenanceEnabled, isFalse);
    expect(model.leasesEnabled, isTrue);
    expect(model.generalEnabled, isFalse);
    expect(model.toJson(), {
      'push_enabled': true,
      'payments_enabled': false,
      'bookings_enabled': true,
      'maintenance_enabled': false,
      'leases_enabled': true,
      'general_enabled': false,
    });
  });
}
