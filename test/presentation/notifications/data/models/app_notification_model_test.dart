import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/app_notification_model.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';

void main() {
  test('parses a complete notification payload', () {
    final model = AppNotificationModel.fromJson(_notificationJson());

    expect(model.id, 12);
    expect(model.kind, NotificationKind.paymentDue);
    expect(model.category, NotificationCategory.payments);
    expect(model.title, 'Payment due');
    expect(model.body, 'Your rent is due soon.');
    expect(model.relatedObjectType, 'invoice');
    expect(model.relatedObjectId, 4);
    expect(model.isRead, isFalse);
    expect(model.createdAt, DateTime.parse('2026-08-09T10:00:00Z').toLocal());
    expect(model.readAt, DateTime.parse('2026-08-08T10:00:00Z').toLocal());
    expect(model.toJson()['type'], 'payment_due');
    expect(model.toJson()['category'], 'payments');
  });

  test('accepts null for every nullable field', () {
    final model = AppNotificationModel.fromJson({
      ..._notificationJson(),
      'body': null,
      'related_object_type': null,
      'related_object_id': null,
      'read_at': null,
    });

    expect(model.body, isNull);
    expect(model.relatedObjectType, isNull);
    expect(model.relatedObjectId, isNull);
    expect(model.readAt, isNull);
  });

  test('unknown API types become unknown notification kinds', () {
    final model = AppNotificationModel.fromJson({
      ..._notificationJson(),
      'type': 'some_new_type',
    });

    expect(model.kind, NotificationKind.unknown);
  });
}

Map<String, dynamic> _notificationJson() => {
  'id': 12,
  'type': 'payment_due',
  'category': 'payments',
  'title': 'Payment due',
  'body': 'Your rent is due soon.',
  'related_object_type': 'invoice',
  'related_object_id': 4,
  'is_read': false,
  'read_at': '2026-08-08T10:00:00Z',
  'created_at': '2026-08-09T10:00:00Z',
  'updated_at': '2026-08-09T10:00:00Z',
};
