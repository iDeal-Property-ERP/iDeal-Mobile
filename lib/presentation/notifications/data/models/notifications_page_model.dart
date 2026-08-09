import 'package:ideal_mobile/presentation/notifications/data/models/app_notification_model.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class NotificationsPageModel extends NotificationsPage {
  const NotificationsPageModel({
    required super.items,
    required super.count,
    required super.numPages,
    required super.perPage,
    required super.pageNumber,
  });

  factory NotificationsPageModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    final page = _mapValue(data['page']);
    if (page == null) {
      throw const FormatException('Notifications page was not returned.');
    }

    final objectList = page['object_list'];
    final items = <AppNotificationModel>[];
    if (objectList is List) {
      items.addAll(objectList.map(_notificationFromJson));
    }

    return NotificationsPageModel(
      items: items,
      count: _requiredInt(data, 'count'),
      numPages: _requiredInt(data, 'num_pages'),
      perPage: _requiredInt(data, 'per_page'),
      pageNumber: _requiredInt(page, 'number'),
    );
  }
}

AppNotificationModel _notificationFromJson(dynamic value) {
  final item = _mapValue(value);
  if (item == null) {
    throw const FormatException('A notification was not returned.');
  }
  return AppNotificationModel.fromJson(item);
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid $key.');
}
