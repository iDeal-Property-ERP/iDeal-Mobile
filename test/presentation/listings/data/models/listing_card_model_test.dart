import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listing_card_model.dart';

void main() {
  final json = <String, dynamic>{
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
    'score': 9.2,
    'review_count': 14,
    'cover_image_url': 'https://example.com/photo.jpg',
    'map_lat': 41.36,
    'map_lon': 69.28,
  };

  test('parses a listing card from JSON', () {
    final model = ListingCardModel.fromJson(json);

    expect(model.id, 12);
    expect(model.propertyId, 34);
    expect(model.title, 'Yunusobod 12-kvartal');
    expect(model.rooms, 2);
    expect(model.areaSqm, 68);
    expect(model.price, 520.0);
    expect(model.score, 9.2);
    expect(model.isVerified, isTrue);
    expect(model.toJson(), json);
  });

  test('accepts nullable listing fields', () {
    final model = ListingCardModel.fromJson({
      ...json,
      'district': null,
      'rooms': null,
      'area_sqm': null,
      'floor': null,
      'total_floors': null,
      'price': null,
      'cover_image_url': null,
      'map_lat': null,
      'map_lon': null,
    });

    expect(model.district, isNull);
    // Property.rooms / Property.area_sqm are null=True on the backend.
    expect(model.rooms, isNull);
    expect(model.areaSqm, isNull);
    expect(model.floor, isNull);
    expect(model.totalFloors, isNull);
    expect(model.price, isNull);
    expect(model.coverImageUrl, isNull);
    expect(model.mapLat, isNull);
    expect(model.mapLon, isNull);
  });

  test('coerces string numeric values defensively', () {
    final model = ListingCardModel.fromJson({
      ...json,
      'price': '520.0',
      'score': '9.2',
    });

    expect(model.price, 520.0);
    expect(model.score, 9.2);
  });
}
