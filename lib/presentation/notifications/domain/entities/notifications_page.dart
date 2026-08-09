import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';

class NotificationsPage extends Equatable {
  const NotificationsPage({
    required this.items,
    required this.count,
    required this.numPages,
    required this.perPage,
    required this.pageNumber,
  });

  final List<AppNotification> items;
  final int count;
  final int numPages;
  final int perPage;
  final int pageNumber;

  bool get hasMore => pageNumber < numPages;

  @override
  List<Object> get props => [items, count, numPages, perPage, pageNumber];
}
