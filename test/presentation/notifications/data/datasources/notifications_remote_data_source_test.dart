import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late NotificationsRemoteDataSourceImpl dataSource;
  late CacheOptions cacheOptions;

  Response<dynamic> response(String path, int statusCode, dynamic data) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: data,
    );
  }

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    cacheOptions = CacheOptions(store: MemCacheStore());
    when(() => cacheManager.noCacheOptions()).thenReturn(cacheOptions);
    dataSource = NotificationsRemoteDataSourceImpl(dio, cacheManager);
  });

  test('parses a filtered list and uses no-cache options', () async {
    when(
      () => dio.get(
        '/mobile/notifications/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/notifications/', 200, {
        'success': true,
        'message': 'OK',
        'data': {
          'count': 1,
          'num_pages': 1,
          'per_page': 20,
          'page': {
            'number': 1,
            'object_list': [_notification(12)],
          },
        },
      }),
    );

    final result = await dataSource.getNotifications(
      page: 1,
      isRead: false,
      category: NotificationCategory.payments,
    );

    expect(result.items.single.id, 12);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('parses the unread count', () async {
    when(
      () => dio.get(
        '/mobile/notifications/unread-count/',
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/notifications/unread-count/', 200, {
        'success': true,
        'message': 'OK',
        'data': {'unread_count': 7},
      }),
    );

    expect(await dataSource.getUnreadCount(), 7);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('marks one notification read', () async {
    when(() => dio.post('/mobile/notifications/12/read/')).thenAnswer(
      (_) async => response('/mobile/notifications/12/read/', 200, {
        'success': true,
        'message': 'OK',
        'data': _notification(12, isRead: true),
      }),
    );

    final result = await dataSource.markRead(12);

    expect(result.id, 12);
    expect(result.isRead, isTrue);
  });

  test('converts a DioException to APIException', () async {
    when(
      () => dio.get(
        '/mobile/notifications/unread-count/',
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(
          path: '/mobile/notifications/unread-count/',
        ),
        message: 'No connection',
      ),
    );

    await expectLater(
      dataSource.getUnreadCount(),
      throwsA(
        isA<APIException>()
            .having((error) => error.message, 'message', 'No connection')
            .having((error) => error.statusCode, 'status', 505),
      ),
    );
  });
}

Map<String, dynamic> _notification(int id, {bool isRead = false}) => {
  'id': id,
  'type': 'payment_due',
  'category': 'payments',
  'title': 'Payment due',
  'body': null,
  'related_object_type': null,
  'related_object_id': null,
  'is_read': isRead,
  'read_at': null,
  'created_at': '2026-08-09T10:00:00Z',
  'updated_at': '2026-08-09T10:00:00Z',
};
