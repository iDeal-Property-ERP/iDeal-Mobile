import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/listings/data/datasources/listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late ListingsRemoteDataSourceImpl dataSource;
  late CacheOptions cacheOptions;

  Response<dynamic> response(String path, int statusCode, dynamic data) =>
      Response<dynamic>(
        requestOptions: RequestOptions(path: path),
        statusCode: statusCode,
        data: data,
      );

  final listing = <String, dynamic>{
    'id': 12,
    'property_id': 34,
    'title': 'Yunusobod 12-kvartal',
    'district': 'Yunusobod',
    'address': '12-kvartal',
    'property_type': 'apartment',
    'rooms': 2,
    'area_sqm': 68,
    'floor': 4,
    'total_floors': 9,
    'furnishing': 'furnished',
    'price': 520.0,
    'currency': 'USD',
    'tariff': 'comfort',
    'is_verified': true,
    'is_featured': false,
    'is_favorite': true,
    'score': 9.2,
    'review_count': 14,
    'cover_image_url': null,
    'map_lat': null,
    'map_lon': null,
  };

  setUpAll(() {
    registerFallbackValue(PublicCacheRequest.cacheFirst);
  });

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    cacheOptions = CacheOptions(store: MemCacheStore());
    when(() => cacheManager.noCacheOptions()).thenReturn(cacheOptions);
    when(
      () => cacheManager.publicCacheOptions(request: any(named: 'request')),
    ).thenReturn(cacheOptions);
    dataSource = ListingsRemoteDataSourceImpl(dio, cacheManager);
  });

  test('parses a successful listings response', () async {
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/home/listings/', 200, {
        'success': true,
        'message': 'OK',
        'data': {
          'count': 1,
          'num_pages': 1,
          'per_page': 20,
          'page': {
            'number': 1,
            'object_list': [listing],
          },
        },
      }),
    );

    final result = await dataSource.getListings(
      filters: const ListingFilters(query: 'Yunusobod'),
      page: 1,
    );

    expect(result.items.single.id, 12);
    expect(result.items.single.isFavorite, isTrue);
    verify(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: {'page': 1, 'per_page': 20, 'q': 'Yunusobod'},
        options: any(named: 'options'),
      ),
    ).called(1);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('omits null filter values from query parameters', () async {
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/home/listings/', 200, {
        'success': true,
        'message': 'OK',
        'data': {
          'count': 0,
          'num_pages': 0,
          'per_page': 10,
          'page': {'number': 1, 'object_list': []},
        },
      }),
    );

    await dataSource.getListings(
      filters: const ListingFilters(priceMin: 200, furnishing: 'furnished'),
      page: 1,
      perPage: 10,
    );

    final captured =
        verify(
              () => dio.get(
                '/mobile/home/listings/',
                queryParameters: captureAny(named: 'queryParameters'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured, {
      'page': 1,
      'per_page': 10,
      'price_min': 200.0,
      'furnishing': 'furnished',
    });
    expect(captured.values, isNot(contains(isNull)));
  });

  test('throws APIException for an unsuccessful envelope', () async {
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/home/listings/', 200, {
        'success': false,
        'message': 'Listings are unavailable.',
        'data': null,
      }),
    );

    await expectLater(
      dataSource.getListings(filters: const ListingFilters.empty(), page: 1),
      throwsA(
        isA<APIException>()
            .having(
              (error) => error.message,
              'message',
              'Listings are unavailable.',
            )
            .having((error) => error.statusCode, 'status code', 200),
      ),
    );
  });

  test('throws APIException for a non-200 response', () async {
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/home/listings/', 503, {
        'success': false,
        'message': 'Unavailable',
      }),
    );

    await expectLater(
      dataSource.getListings(filters: const ListingFilters.empty(), page: 1),
      throwsA(
        isA<APIException>().having((error) => error.statusCode, 'status', 503),
      ),
    );
  });

  test('converts a DioException to APIException', () async {
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/mobile/home/listings/'),
        message: 'No connection',
      ),
    );

    await expectLater(
      dataSource.getListings(filters: const ListingFilters.empty(), page: 1),
      throwsA(
        isA<APIException>()
            .having((error) => error.message, 'message', 'No connection')
            .having((error) => error.statusCode, 'status', 505),
      ),
    );
  });

  test('cached listing stream yields cache then forced fresh data', () async {
    var call = 0;
    when(
      () => dio.get(
        '/mobile/home/listings/',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async {
      final network = call++ == 1;
      return response('/mobile/home/listings/', 200, {
        'success': true,
        'data': {
          'count': 1,
          'num_pages': 1,
          'per_page': 20,
          'page': {
            'number': 1,
            'object_list': [
              {...listing, 'id': network ? 13 : 12},
            ],
          },
        },
      })..extra[extraFromNetworkKey] = network;
    });

    final results = await dataSource
        .getListingsCached(filters: const ListingFilters.empty(), page: 1)
        .toList();

    expect(results.map((event) => event.data.items.single.id), [12, 13]);
    expect(results.map((event) => event.origin), [
      PublicDataOrigin.cache,
      PublicDataOrigin.fresh,
    ]);
    verify(
      () => cacheManager.publicCacheOptions(
        request: PublicCacheRequest.cacheFirst,
      ),
    ).called(1);
    verify(
      () => cacheManager.publicCacheOptions(
        request: PublicCacheRequest.forceRefresh,
      ),
    ).called(1);
  });

  test('cached filter stream yields cache then forced fresh data', () async {
    var call = 0;
    when(
      () => dio.get('/mobile/home/filters/', options: any(named: 'options')),
    ).thenAnswer((_) async {
      final network = call++ == 1;
      return response('/mobile/home/filters/', 200, {
        'success': true,
        'data': {
          'districts': [],
          'tariffs': [
            {'value': network ? 'house' : 'apartment', 'label': 'Type'},
          ],
        },
      })..extra[extraFromNetworkKey] = network;
    });

    final results = await dataSource.getFilterOptionsCached().toList();

    expect(results.map((event) => event.origin), [
      PublicDataOrigin.cache,
      PublicDataOrigin.fresh,
    ]);
    expect(results.first.data.tariffs.single.value, 'apartment');
    expect(results.last.data.tariffs.single.value, 'house');
  });
}
