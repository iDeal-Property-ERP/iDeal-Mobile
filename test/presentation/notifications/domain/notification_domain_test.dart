import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';

void main() {
  test('unknown notification kinds are safe', () {
    expect(NotificationKind.fromApi('some_new_type'), NotificationKind.unknown);
    expect(NotificationKind.paymentDue.apiValue, 'payment_due');
  });

  test('unknown categories fall back to general', () {
    expect(
      NotificationCategory.fromApi('some_new_category'),
      NotificationCategory.general,
    );
    expect(NotificationCategory.maintenance.apiValue, 'maintenance');
  });

  test('notification settings map categories and copy values', () {
    const settings = NotificationSettings(
      pushEnabled: true,
      paymentsEnabled: false,
      bookingsEnabled: true,
      maintenanceEnabled: false,
      leasesEnabled: true,
      generalEnabled: false,
    );

    expect(settings.categoryEnabled(NotificationCategory.payments), isFalse);
    expect(settings.categoryEnabled(NotificationCategory.bookings), isTrue);
    expect(settings.copyWith(generalEnabled: true).generalEnabled, isTrue);
  });

  test('settings update omits unchanged values', () {
    const update = NotificationSettingsUpdate(
      pushEnabled: false,
      leasesEnabled: true,
    );

    expect(update.toJson(), {'push_enabled': false, 'leases_enabled': true});
  });
}
