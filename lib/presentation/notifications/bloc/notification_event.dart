import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();

  @override
  List<Object> get props => [];
}

class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();

  @override
  List<Object> get props => [];
}

class LoadMoreNotificationsEvent extends NotificationEvent {
  const LoadMoreNotificationsEvent();

  @override
  List<Object> get props => [];
}

class MarkNotificationReadEvent extends NotificationEvent {
  const MarkNotificationReadEvent(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class MarkAllNotificationsReadEvent extends NotificationEvent {
  const MarkAllNotificationsReadEvent();

  @override
  List<Object> get props => [];
}
