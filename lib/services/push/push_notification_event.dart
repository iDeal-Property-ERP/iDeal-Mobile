class PushNotificationEvent {
  const PushNotificationEvent({
    this.notificationId,
    this.type,
    this.category,
    this.relatedObjectType,
    this.relatedObjectId,
    this.title,
    this.body,
  });

  final int? notificationId;
  final String? type;
  final String? category;
  final String? relatedObjectType;
  final int? relatedObjectId;
  final String? title;
  final String? body;

  factory PushNotificationEvent.fromData(
    Map<String, dynamic> data, {
    String? title,
    String? body,
  }) {
    return PushNotificationEvent(
      notificationId: _parseInt(data['notification_id']),
      type: _parseString(data['type']),
      category: _parseString(data['category']),
      relatedObjectType: _parseString(data['related_object_type']),
      relatedObjectId: _parseInt(data['related_object_id']),
      title: title,
      body: body,
    );
  }
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _parseString(dynamic value) {
  if (value is! String) return null;
  final result = value.trim();
  return result.isEmpty ? null : result;
}
