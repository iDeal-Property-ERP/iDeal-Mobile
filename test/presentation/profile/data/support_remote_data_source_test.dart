import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/support_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/models/support_links_model.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late SupportRemoteDataSourceImpl dataSource;

  Response<dynamic> response(int statusCode, dynamic data) => Response<dynamic>(
    requestOptions: RequestOptions(path: '/mobile/support/links/'),
    statusCode: statusCode,
    data: data,
  );

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    when(
      () => cacheManager.customCacheOptions(
        policy: any(named: 'policy'),
        maxStale: any(named: 'maxStale'),
      ),
    ).thenReturn(
      CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.forceCache,
        maxStale: const Duration(days: 7),
      ),
    );
    dataSource = SupportRemoteDataSourceImpl(dio, cacheManager);
  });

  group('SupportLinksModel', () {
    test('parses json correctly', () {
      final model = SupportLinksModel.fromJson(const {
        'telegram_url': 'https://t.me/ideal_support',
        'whatsapp_url': 'https://wa.me/998901234567',
      });
      expect(model.telegramUrl, 'https://t.me/ideal_support');
      expect(model.whatsappUrl, 'https://wa.me/998901234567');
      expect(model.hasTelegram, isTrue);
      expect(model.hasWhatsApp, isTrue);
    });

    test('handles empty or whitespace strings as null', () {
      final model = SupportLinksModel.fromJson(const {
        'telegram_url': '   ',
        'whatsapp_url': null,
      });
      expect(model.telegramUrl, isNull);
      expect(model.whatsappUrl, isNull);
      expect(model.hasTelegram, isFalse);
      expect(model.hasWhatsApp, isFalse);
    });

    test('converts to json correctly', () {
      const model = SupportLinksModel(
        telegramUrl: 'https://t.me/ideal_support',
      );
      expect(model.toJson(), {
        'telegram_url': 'https://t.me/ideal_support',
        'whatsapp_url': null,
      });
    });
  });

  group('SupportRemoteDataSource', () {
    test('fetches and parses support links with aggressive caching', () async {
      when(
        () => dio.get('/mobile/support/links/', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => response(200, {
          'success': true,
          'message': 'OK',
          'data': {
            'telegram_url': 'https://t.me/ideal_support',
            'whatsapp_url': 'https://wa.me/998901234567',
          },
        }),
      );

      final result = await dataSource.getSupportLinks();

      expect(
        result,
        const SupportLinksModel(
          telegramUrl: 'https://t.me/ideal_support',
          whatsappUrl: 'https://wa.me/998901234567',
        ),
      );
      verify(
        () => cacheManager.customCacheOptions(
          policy: CachePolicy.forceCache,
          maxStale: const Duration(days: 7),
        ),
      ).called(1);
    });

    test('returns empty SupportLinksModel on API failure', () async {
      when(
        () => dio.get('/mobile/support/links/', options: any(named: 'options')),
      ).thenAnswer(
        (_) async => response(500, {'success': false, 'message': 'Error'}),
      );

      final result = await dataSource.getSupportLinks();
      expect(result, const SupportLinksModel());
    });

    test('returns empty SupportLinksModel on DioException', () async {
      when(
        () => dio.get('/mobile/support/links/', options: any(named: 'options')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/mobile/support/links/'),
        ),
      );

      final result = await dataSource.getSupportLinks();
      expect(result, const SupportLinksModel());
    });
  });
}
