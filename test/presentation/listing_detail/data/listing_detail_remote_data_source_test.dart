import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/datasources/listing_detail_remote_data_source.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

Response<dynamic> _response(String path, int statusCode, dynamic data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

Map<String, dynamic> _detailJson() => {
  'id': 12,
  'property_id': 34,
  'title': 'Yunusobod 12-kvartal',
  'district': 'Yunusobod District',
  'address': '12-kvartal',
  'property_type': 'apartment',
  'rooms': 2,
  'area_sqm': 65,
  'floor': 4,
  'total_floors': 9,
  'furnishing': 'furnished',
  'price': 520.0,
  'currency': 'USD',
  'tariff': 'comfort',
  'is_verified': true,
  'is_featured': false,
  'score': 9.2,
  'review_count': 48,
  'map_lat': 41.36,
  'map_lon': 69.28,
  'description': 'A bright apartment.',
  'deposit_amount': 520.0,
  'minimum_stay': 6,
  'price_includes': ['wifi'],
  'response_time': 'Usually responds within 1 hour',
  'created_at': '2026-07-01T10:00:00+00:00',
  'photos': [
    {
      'id': 1,
      'image_url': 'https://example.com/photo.jpg',
      'caption': null,
      'is_primary': true,
      'sort_order': 0,
    },
  ],
  'amenities': [
    {'slug': 'wifi', 'name': 'High-speed Wi-Fi', 'icon': 'wifi'},
  ],
  'verification': {
    'is_verified': true,
    'checklist': [
      {'key': 'ownership', 'label': 'Official ownership check'},
    ],
  },
};

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late ListingDetailRemoteDataSourceImpl dataSource;

  const path = '/mobile/home/listings/12/';

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    when(
      () => cacheManager.noCacheOptions(),
    ).thenReturn(CacheOptions(store: MemCacheStore()));
    dataSource = ListingDetailRemoteDataSourceImpl(dio, cacheManager);
  });

  test('returns the model for a successful response', () async {
    when(() => dio.get(path, options: any(named: 'options'))).thenAnswer(
      (_) async => _response(path, 200, {
        'success': true,
        'message': 'OK',
        'data': _detailJson(),
      }),
    );

    final result = await dataSource.getListingDetail(id: 12);

    expect(result.id, 12);
    expect(result.title, 'Yunusobod 12-kvartal');
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('throws APIException for a non-200 response', () async {
    when(() => dio.get(path, options: any(named: 'options'))).thenAnswer(
      (_) async =>
          _response(path, 503, {'success': false, 'message': 'Unavailable'}),
    );

    await expectLater(
      dataSource.getListingDetail(id: 12),
      throwsA(
        isA<APIException>().having(
          (error) => error.statusCode,
          'status code',
          503,
        ),
      ),
    );
  });

  test('throws APIException for an unsuccessful envelope', () async {
    when(() => dio.get(path, options: any(named: 'options'))).thenAnswer(
      (_) async => _response(path, 200, {
        'success': false,
        'message': 'Listing is unavailable.',
        'data': null,
      }),
    );

    await expectLater(
      dataSource.getListingDetail(id: 12),
      throwsA(
        isA<APIException>()
            .having(
              (error) => error.message,
              'message',
              'Listing is unavailable.',
            )
            .having((error) => error.statusCode, 'status code', 200),
      ),
    );
  });

  test('converts a DioException to APIException', () async {
    when(() => dio.get(path, options: any(named: 'options'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: path),
        message: 'No connection',
      ),
    );

    await expectLater(
      dataSource.getListingDetail(id: 12),
      throwsA(
        isA<APIException>()
            .having((error) => error.message, 'message', 'No connection')
            .having((error) => error.statusCode, 'status code', 505),
      ),
    );
  });
}
