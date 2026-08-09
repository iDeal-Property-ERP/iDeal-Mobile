import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.kind,
    required super.category,
    required super.title,
    required super.body,
    required super.relatedObjectType,
    required super.relatedObjectId,
    required super.isRead,
    required super.readAt,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(DataMap json) {
    return AppNotificationModel(
      id: _requiredInt(json, 'id'),
      kind: NotificationKind.fromApi(_requiredString(json, 'type')),
      category: NotificationCategory.fromApi(_requiredString(json, 'category')),
      title: _requiredString(json, 'title'),
      body: _nullableString(json['body']),
      relatedObjectType: _nullableString(json['related_object_type']),
      relatedObjectId: _nullableInt(json['related_object_id']),
      isRead: _requiredBool(json, 'is_read'),
      readAt: _nullableDateTime(json['read_at']),
      createdAt: _requiredDateTime(json, 'created_at'),
    );
  }

  DataMap toJson() => {
    'id': id,
    'type': kind.apiValue,
    'category': category.apiValue,
    'title': title,
    'body': body,
    'related_object_type': relatedObjectType,
    'related_object_id': relatedObjectId,
    'is_read': isRead,
    'read_at': readAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}

String _requiredString(DataMap json, String key) {
  final value = json[key];
  if (value == null) {
    throw FormatException('Missing $key.');
  }
  return value is String ? value : value.toString();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  return value is String ? value : value.toString();
}

int _requiredInt(DataMap json, String key) {
  final parsed = _nullableInt(json[key]);
  if (parsed == null) {
    throw FormatException('Invalid $key.');
  }
  return parsed;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
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

DateTime _requiredDateTime(DataMap json, String key) {
  final rawValue = json[key];
  if (rawValue == null) {
    throw FormatException('Missing $key.');
  }

  try {
    final value = _nullableDateTime(rawValue);
    if (value == null) {
      throw FormatException('Missing $key.');
    }
    return value;
  } on FormatException {
    throw FormatException('Invalid $key.');
  }
}

DateTime? _nullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();
  if (value is! String) {
    throw const FormatException('Invalid date time.');
  }

  try {
    return DateTime.parse(value).toLocal();
  } on FormatException {
    throw const FormatException('Invalid date time.');
  }
}
