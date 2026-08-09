import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/app_notification_model.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notifications_page_model.dart';
import 'package:ideal_mobile/presentation/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notifications_page.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

void main() {
  late MockNotificationsRemoteDataSource dataSource;
  late NotificationsRepositoryImpl repository;

  const page = NotificationsPageModel(
    items: [],
    count: 0,
    numPages: 0,
    perPage: 20,
    pageNumber: 1,
  );
  final notification = AppNotificationModel(
    id: 12,
    kind: NotificationKind.general,
    category: NotificationCategory.general,
    title: 'Notice',
    body: null,
    relatedObjectType: null,
    relatedObjectId: null,
    isRead: true,
    readAt: DateTime.utc(2026, 8, 9),
    createdAt: DateTime.utc(2026, 8, 8),
  );

  setUpAll(() {
    registerFallbackValue(NotificationCategory.general);
  });

  setUp(() {
    dataSource = MockNotificationsRemoteDataSource();
    repository = NotificationsRepositoryImpl(dataSource);
  });

  test('returns Right for a successful list request', () async {
    when(
      () => dataSource.getNotifications(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        isRead: any(named: 'isRead'),
        category: any(named: 'category'),
      ),
    ).thenAnswer((_) async => page);

    final result = await repository.getNotifications(page: 1);

    expect(result, const Right<Failure, NotificationsPage>(page));
  });

  test('returns Left APIFailure for a list request error', () async {
    when(
      () => dataSource.getNotifications(
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        isRead: any(named: 'isRead'),
        category: any(named: 'category'),
      ),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));

    final result = await repository.getNotifications(page: 1);

    expect(
      result,
      const Left<Failure, NotificationsPage>(
        APIFailure(message: 'Unavailable', statusCode: 503),
      ),
    );
  });

  test('maps unread count success and failure', () async {
    when(() => dataSource.getUnreadCount()).thenAnswer((_) async => 7);
    expect(await repository.getUnreadCount(), const Right<Failure, int>(7));

    when(
      () => dataSource.getUnreadCount(),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));
    expect(
      await repository.getUnreadCount(),
      const Left<Failure, int>(
        APIFailure(message: 'Unavailable', statusCode: 503),
      ),
    );
  });

  test('maps mark-read and mark-all success', () async {
    when(() => dataSource.markRead(12)).thenAnswer((_) async => notification);
    when(() => dataSource.markAllRead()).thenAnswer((_) async => 12);

    expect(
      await repository.markRead(12),
      Right<Failure, AppNotification>(notification),
    );
    expect(await repository.markAllRead(), const Right<Failure, int>(12));
  });
}
