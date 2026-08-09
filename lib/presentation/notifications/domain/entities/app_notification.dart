import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.body,
    required this.relatedObjectType,
    required this.relatedObjectId,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final NotificationKind kind;
  final NotificationCategory category;
  final String title;
  final String? body;
  final String? relatedObjectType;
  final int? relatedObjectId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    kind,
    category,
    title,
    body,
    relatedObjectType,
    relatedObjectId,
    isRead,
    readAt,
    createdAt,
  ];
}
