import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notification_settings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late NotificationSettingsRemoteDataSourceImpl dataSource;
  late CacheOptions cacheOptions;

  Response<dynamic> response(String path, dynamic data) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );
  }

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    cacheOptions = CacheOptions(store: MemCacheStore());
    when(() => cacheManager.noCacheOptions()).thenReturn(cacheOptions);
    dataSource = NotificationSettingsRemoteDataSourceImpl(dio, cacheManager);
  });

  test('gets settings without using the global cache', () async {
    when(
      () => dio.get(
        '/mobile/notification-settings/',
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/notification-settings/', {
        'success': true,
        'message': 'OK',
        'data': _settingsJson(),
      }),
    );

    final result = await dataSource.getSettings();

    expect(result.pushEnabled, isTrue);
    expect(result.messagesEnabled, isTrue);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('patches only the provided settings', () async {
    const update = NotificationSettingsUpdate(pushEnabled: false);
    when(
      () => dio.patch(
        '/mobile/notification-settings/',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/notification-settings/', {
        'success': true,
        'message': 'OK',
        'data': {..._settingsJson(), 'push_enabled': false},
      }),
    );

    final result = await dataSource.updateSettings(update);

    expect(result.pushEnabled, isFalse);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });
}

Map<String, dynamic> _settingsJson() => {
  'push_enabled': true,
  'payments_enabled': true,
  'bookings_enabled': true,
  'maintenance_enabled': true,
  'leases_enabled': true,
  'messages_enabled': true,
  'general_enabled': true,
};
