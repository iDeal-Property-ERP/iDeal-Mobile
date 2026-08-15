import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_map/data/datasources/listing_map_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ListingMapRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = ListingMapRemoteDataSourceImpl(dio);
  });

  test('uses lon-lat bbox order and parses the DMR map envelope', () async {
    when(
      () => dio.get<dynamic>(
        ListingMapRemoteDataSourceImpl.path,
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(
          path: ListingMapRemoteDataSourceImpl.path,
        ),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'items': [_listingJson],
            'count': 501,
            'truncated': true,
          },
        },
      ),
    );

    final result = await dataSource.getListings(
      bounds: _bounds,
      filters: const ListingFilters(
        query: 'yunusobod',
        propertyType: 'apartment',
      ),
    );

    expect(result.items.single.contactPhone, '+998712000000');
    expect(result.truncated, isTrue);
    final query =
        verify(
              () => dio.get<dynamic>(
                ListingMapRemoteDataSourceImpl.path,
                queryParameters: captureAny(named: 'queryParameters'),
                cancelToken: any(named: 'cancelToken'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(query, {
      'bbox': '69.1,41.2,69.4,41.5',
      'q': 'yunusobod',
      'property_type': 'apartment',
    });
  });

  test('rejects a map item without coordinates', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: 'map'),
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'items': [
              {..._listingJson, 'map_lat': null},
            ],
            'count': 1,
            'truncated': false,
          },
        },
      ),
    );

    expect(
      dataSource.getListings(
        bounds: _bounds,
        filters: const ListingFilters.empty(),
      ),
      throwsA(isA<Exception>()),
    );
  });
}

final _bounds = PropertyMapBounds(
  southWest: const PropertyMapCoordinate(latitude: 41.2, longitude: 69.1),
  northEast: const PropertyMapCoordinate(latitude: 41.5, longitude: 69.4),
);

final _listingJson = <String, dynamic>{
  'id': 1,
  'property_id': 2,
  'title': 'Apartment',
  'district': 'Yunusobod',
  'address': 'Tashkent',
  'property_type': 'apartment',
  'rooms': 2,
  'area_sqm': 60,
  'floor': 3,
  'total_floors': 9,
  'furnishing': 'furnished',
  'price': 500,
  'currency': 'USD',
  'tariff': 'comfort',
  'is_verified': true,
  'is_featured': false,
  'score': 9,
  'review_count': 2,
  'cover_image_url': null,
  'cover_preview_url': null,
  'cover_display_url': null,
  'map_lat': 41.31,
  'map_lon': 69.28,
  'contact_phone': '+998712000000',
};
