import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_state.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notifications.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_notification_read.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    GetNotifications? getNotifications,
    MarkNotificationRead? markNotificationRead,
    MarkAllNotificationsRead? markAllNotificationsRead,
  }) : _getNotifications = getNotifications ?? sl<GetNotifications>(),
       _markNotificationRead =
           markNotificationRead ?? sl<MarkNotificationRead>(),
       _markAllNotificationsRead =
           markAllNotificationsRead ?? sl<MarkAllNotificationsRead>(),
       super(const NotificationState()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<RefreshNotificationsEvent>(_onRefresh);
    on<LoadMoreNotificationsEvent>(_onLoadMore);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  final GetNotifications _getNotifications;
  final MarkNotificationRead _markNotificationRead;
  final MarkAllNotificationsRead _markAllNotificationsRead;

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) => _load(page: 1, replace: true, emit: emit);

  Future<void> _onRefresh(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) => _load(page: 1, replace: true, emit: emit);

  Future<void> _onLoadMore(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) {
      return Future.value();
    }
    return _load(page: state.page + 1, replace: false, emit: emit);
  }

  Future<void> _load({
    required int page,
    required bool replace,
    required Emitter<NotificationState> emit,
  }) async {
    emit(
      state.copyWith(
        page: replace ? 1 : state.page,
        isLoading: replace,
        isLoadingMore: !replace,
        hasReachedMax: replace ? false : state.hasReachedMax,
        clearErrorMessage: true,
      ),
    );
    final result = await _getNotifications(GetNotificationsParams(page: page));
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (response) {
        final items = replace
            ? response.items
            : [...state.items, ...response.items];
        emit(
          state.copyWith(
            items: items,
            page: response.pageNumber,
            numPages: response.numPages,
            hasReachedMax: !response.hasMore,
            isLoading: false,
            isLoadingMore: false,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final originalItems = state.items;
    final item = originalItems
        .where((value) => value.id == event.id)
        .firstOrNull;
    if (item == null || item.isRead) {
      return;
    }
    emit(
      state.copyWith(
        items: originalItems.map(_markReadLocally(event.id)).toList(),
      ),
    );
    final result = await _markNotificationRead(
      MarkNotificationReadParams(id: event.id),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          items: originalItems,
          errorMessage: failure.errorMessage,
        ),
      ),
      (updated) => emit(
        state.copyWith(
          items: state.items
              .map((value) => value.id == updated.id ? updated : value)
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final originalItems = state.items;
    if (originalItems.every((item) => item.isRead)) return;
    emit(
      state.copyWith(items: originalItems.map(_markReadLocally(null)).toList()),
    );
    final result = await _markAllNotificationsRead();
    result.fold(
      (failure) => emit(
        state.copyWith(
          items: originalItems,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {},
    );
  }
}

AppNotification Function(AppNotification) _markReadLocally(int? id) {
  return (notification) {
    if (id != null && notification.id != id || notification.isRead) {
      return notification;
    }
    return AppNotification(
      id: notification.id,
      kind: notification.kind,
      category: notification.category,
      title: notification.title,
      body: notification.body,
      relatedObjectType: notification.relatedObjectType,
      relatedObjectId: notification.relatedObjectId,
      isRead: true,
      readAt: DateTime.now(),
      createdAt: notification.createdAt,
    );
  };
}
