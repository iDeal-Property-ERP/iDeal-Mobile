import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_state.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notifications.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_notification_read.dart';
import 'package:mocktail/mocktail.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockMarkNotificationRead extends Mock implements MarkNotificationRead {}

class MockMarkAllNotificationsRead extends Mock
    implements MarkAllNotificationsRead {}

void main() {
  late MockGetNotifications getNotifications;
  late MockMarkNotificationRead markRead;
  late MockMarkAllNotificationsRead markAllRead;

  setUpAll(() {
    registerFallbackValue(const GetNotificationsParams(page: 1));
  });

  setUp(() {
    getNotifications = MockGetNotifications();
    markRead = MockMarkNotificationRead();
    markAllRead = MockMarkAllNotificationsRead();
  });

  NotificationBloc buildBloc() => NotificationBloc(
    getNotifications: getNotifications,
    markNotificationRead: markRead,
    markAllNotificationsRead: markAllRead,
  );

  blocTest<NotificationBloc, NotificationState>(
    'loads the first page and records pagination state',
    build: () {
      when(() => getNotifications(any())).thenAnswer(
        (_) async => Right(
          NotificationsPage(
            items: [_notification(1)],
            count: 2,
            numPages: 2,
            perPage: 20,
            pageNumber: 1,
          ),
        ),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const LoadNotificationsEvent()),
    expect: () => [
      isA<NotificationState>().having(
        (state) => state.isLoading,
        'loading',
        true,
      ),
      isA<NotificationState>()
          .having((state) => state.items.length, 'items', 1)
          .having((state) => state.hasReachedMax, 'has more pages', false),
    ],
  );
}

AppNotification _notification(int id) => AppNotification(
  id: id,
  kind: NotificationKind.general,
  category: NotificationCategory.general,
  title: 'Notice',
  body: null,
  relatedObjectType: null,
  relatedObjectId: null,
  isRead: false,
  readAt: null,
  createdAt: DateTime(2026),
);
