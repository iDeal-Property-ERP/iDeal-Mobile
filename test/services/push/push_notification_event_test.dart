import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/services/push/push_notification_event.dart';

void main() {
  test('parses the string-valued backend payload', () {
    final event = PushNotificationEvent.fromData(
      {
        'notification_id': '12',
        'type': 'payment_due',
        'category': 'payments',
        'related_object_type': 'invoice',
        'related_object_id': '4',
        'deep_link': 'ideal://notifications/12',
      },
      title: 'Payment due',
      body: 'Your payment is due.',
    );

    expect(event.notificationId, 12);
    expect(event.type, 'payment_due');
    expect(event.category, 'payments');
    expect(event.relatedObjectType, 'invoice');
    expect(event.relatedObjectId, 4);
    expect(event.title, 'Payment due');
    expect(event.body, 'Your payment is due.');
  });

  test('handles missing and malformed optional values', () {
    final event = PushNotificationEvent.fromData({
      'notification_id': 'not-an-int',
      'related_object_id': 4.5,
      'type': '',
      'category': null,
    });

    expect(event.notificationId, isNull);
    expect(event.type, isNull);
    expect(event.category, isNull);
    expect(event.relatedObjectType, isNull);
    expect(event.relatedObjectId, isNull);
    expect(event.title, isNull);
    expect(event.body, isNull);
  });
}
