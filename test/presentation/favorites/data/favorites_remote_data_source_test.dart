import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late FavoritesRemoteDataSourceImpl dataSource;

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
    'cover_image_url': 'https://cdn.example/12.jpg',
    'map_lat': 41.3,
    'map_lon': 69.2,
  };

  setUp(() {
    dio = MockDio();
    dataSource = FavoritesRemoteDataSourceImpl(dio);
  });

  test(
    'GET requests page/per_page and parses the response envelope/card',
    () async {
      when(
        () => dio.get(
          '/mobile/favorites/',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => response('/mobile/favorites/', 200, {
          'success': true,
          'data': {
            'count': 1,
            'num_pages': 3,
            'per_page': 7,
            'page': {
              'number': 2,
              'object_list': [listing],
            },
          },
        }),
      );

      final result = await dataSource.getFavorites(page: 2, perPage: 7);

      expect(result.pageNumber, 2);
      expect(result.perPage, 7);
      expect(result.items.single.id, 12);
      expect(result.items.single.isFavorite, isTrue);
      verify(
        () => dio.get(
          '/mobile/favorites/',
          queryParameters: {'page': 2, 'per_page': 7},
        ),
      ).called(1);
    },
  );

  test('GET forwards filters and sort as query parameters', () async {
    when(
      () => dio.get(
        '/mobile/favorites/',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/favorites/', 200, {
        'success': true,
        'data': {
          'count': 0,
          'num_pages': 1,
          'per_page': 20,
          'page': {'number': 1, 'object_list': <dynamic>[]},
        },
      }),
    );

    await dataSource.getFavorites(
      page: 1,
      filters: const ListingFilters(
        query: 'loft',
        districtId: 3,
        priceMin: 300,
        priceMax: 800,
        verified: true,
      ),
      sort: SelectedSort.priceAsc,
    );

    verify(
      () => dio.get(
        '/mobile/favorites/',
        queryParameters: {
          'page': 1,
          'per_page': 20,
          'q': 'loft',
          'district_id': 3,
          'price_min': 300.0,
          'price_max': 800.0,
          'verified': true,
          'sort': 'price_asc',
        },
      ),
    ).called(1);
  });

  test(
    'PUT selects the listing favorite path and maps a successful envelope',
    () async {
      when(() => dio.put('/mobile/favorites/12/')).thenAnswer(
        (_) async => response('/mobile/favorites/12/', 200, {'success': true}),
      );

      await dataSource.setFavorite(listingId: 12, isFavorite: true);

      verify(() => dio.put('/mobile/favorites/12/')).called(1);
      verifyNever(() => dio.delete(any()));
    },
  );

  test(
    'DELETE selects the listing favorite path and maps a successful envelope',
    () async {
      when(() => dio.delete('/mobile/favorites/12/')).thenAnswer(
        (_) async => response('/mobile/favorites/12/', 200, {'success': true}),
      );

      await dataSource.setFavorite(listingId: 12, isFavorite: false);

      verify(() => dio.delete('/mobile/favorites/12/')).called(1);
      verifyNever(() => dio.put(any()));
    },
  );

  test('maps an unsuccessful API envelope to APIException', () async {
    when(
      () => dio.get(
        '/mobile/favorites/',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/favorites/', 200, {
        'success': false,
        'message': 'Favorites are unavailable.',
      }),
    );

    await expectLater(
      dataSource.getFavorites(page: 1),
      throwsA(
        isA<APIException>()
            .having(
              (error) => error.message,
              'message',
              'Favorites are unavailable.',
            )
            .having((error) => error.statusCode, 'status', 200),
      ),
    );
  });

  test('maps a malformed page/card payload to APIException', () async {
    when(
      () => dio.get(
        '/mobile/favorites/',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => response('/mobile/favorites/', 200, {
        'success': true,
        'data': {
          'count': 1,
          'num_pages': 1,
          'per_page': 20,
          'page': {
            'number': 1,
            'object_list': [
              {'title': 'missing id'},
            ],
          },
        },
      }),
    );

    await expectLater(
      dataSource.getFavorites(page: 1),
      throwsA(
        isA<APIException>().having(
          (error) => error.message,
          'message',
          'Invalid id.',
        ),
      ),
    );
  });

  test('maps Dio failures to APIException', () async {
    when(() => dio.delete('/mobile/favorites/12/')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/mobile/favorites/12/'),
        message: 'No connection',
      ),
    );

    await expectLater(
      dataSource.setFavorite(listingId: 12, isFavorite: false),
      throwsA(
        isA<APIException>()
            .having((error) => error.message, 'message', 'No connection')
            .having((error) => error.statusCode, 'status', 500),
      ),
    );
  });
}
