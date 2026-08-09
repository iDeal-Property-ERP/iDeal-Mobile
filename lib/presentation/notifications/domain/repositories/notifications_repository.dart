import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class NotificationsRepository {
  ResultFuture<NotificationsPage> getNotifications({
    required int page,
    int perPage = 20,
    bool? isRead,
    NotificationCategory? category,
  });

  ResultFuture<int> getUnreadCount();

  ResultFuture<AppNotification> markRead(int id);

  ResultFuture<int> markAllRead();
}
