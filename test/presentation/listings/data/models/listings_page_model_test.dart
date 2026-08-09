import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listings_page_model.dart';

void main() {
  Map<String, dynamic> listing(int id) => {
    'id': id,
    'property_id': id + 100,
    'title': 'Listing $id',
    'district': 'Yunusobod',
    'address': 'Address $id',
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
    'score': 9.2,
    'review_count': 14,
    'cover_image_url': null,
    'map_lat': null,
    'map_lon': null,
  };

  test('parses the paginated data envelope', () {
    final page = ListingsPageModel.fromJson({
      'success': true,
      'message': 'OK',
      'data': {
        'count': 3,
        'num_pages': 2,
        'per_page': 2,
        'page': {
          'number': 1,
          'object_list': [listing(1), listing(2)],
        },
      },
    });

    expect(page.count, 3);
    expect(page.numPages, 2);
    expect(page.perPage, 2);
    expect(page.pageNumber, 1);
    expect(page.items.map((item) => item.id), [1, 2]);
    expect(page.hasMore, isTrue);
  });

  test('reports no more pages on the final page', () {
    final page = ListingsPageModel.fromJson({
      'data': {
        'count': 1,
        'num_pages': 1,
        'per_page': 20,
        'page': {
          'number': 1,
          'object_list': [listing(1)],
        },
      },
    });

    expect(page.hasMore, isFalse);
  });
}
