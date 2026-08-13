import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/models/listing_detail_model.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';

void main() {
  final json = <String, dynamic>{
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
    'description': 'A bright, recently renovated apartment.',
    'deposit_amount': 520.0,
    'minimum_stay': 6,
    'price_includes': ['wifi', 'cleaning'],
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
    'can_message': true,
    'contact_phone': '  +998 90 123 45 67  ',
  };

  test('parses a full listing detail fixture', () {
    final model = ListingDetailModel.fromJson(json);

    expect(model.id, 12);
    expect(model.propertyId, 34);
    expect(model.title, 'Yunusobod 12-kvartal');
    expect(model.price, 520.0);
    expect(model.coverImageUrl, 'https://example.com/photo.jpg');
    expect(
      model.photos.single,
      const ListingPhoto(
        id: 1,
        imageUrl: 'https://example.com/photo.jpg',
        caption: null,
        isPrimary: true,
        sortOrder: 0,
      ),
    );
    expect(model.amenities.single.name, 'High-speed Wi-Fi');
    expect(model.verificationIsVerified, isTrue);
    expect(model.verificationChecklist.single.key, 'ownership');
    expect(model.priceIncludes, ['wifi', 'cleaning']);
    expect(model.canMessage, isTrue);
    expect(model.contactPhone, '+998 90 123 45 67');
    expect(model.toJson()['response_time'], 'Usually responds within 1 hour');
    expect(model.toJson()['can_message'], isTrue);
    expect(model.toJson()['contact_phone'], '+998 90 123 45 67');
    expect(model.toJson()['photos'], isA<List<dynamic>>());
  });

  test('degrades nullable fields and missing nested lists safely', () {
    final missingOptionalData = {
      ...json,
      'district': null,
      'rooms': null,
      'area_sqm': null,
      'floor': null,
      'total_floors': null,
      'price': null,
      'map_lat': null,
      'map_lon': null,
      'description': null,
      'deposit_amount': null,
      'minimum_stay': null,
      'photos': null,
      'amenities': 'not-a-list',
      'price_includes': null,
      'verification': null,
    }..remove('created_at');

    final model = ListingDetailModel.fromJson(missingOptionalData);

    expect(model.district, isNull);
    expect(model.rooms, isNull);
    expect(model.areaSqm, isNull);
    expect(model.price, isNull);
    expect(model.photos, isEmpty);
    expect(model.amenities, isEmpty);
    expect(model.priceIncludes, isEmpty);
    expect(model.verificationIsVerified, isFalse);
    expect(model.verificationChecklist, isEmpty);
    expect(model.createdAt, isA<DateTime>());
    expect(model.canMessage, isTrue);
    expect(model.contactPhone, '+998 90 123 45 67');
  });

  test('parses nullable photo variants while retaining the original URL', () {
    final model = ListingDetailModel.fromJson({
      ...json,
      'photos': [
        {
          ...json['photos'][0] as Map<String, dynamic>,
          'preview_url': 'https://example.com/photo-preview.jpg',
          'display_url': 'https://example.com/photo-display.jpg',
        },
      ],
    });

    expect(model.photos.single.imageUrl, 'https://example.com/photo.jpg');
    expect(
      model.photos.single.previewUrl,
      'https://example.com/photo-preview.jpg',
    );
    expect(
      model.photos.single.displayUrl,
      'https://example.com/photo-display.jpg',
    );
  });

  test('missing chat fields use safe defaults', () {
    final missingChatFields = {...json}
      ..remove('can_message')
      ..remove('contact_phone');

    final model = ListingDetailModel.fromJson(missingChatFields);

    expect(model.canMessage, isFalse);
    expect(model.contactPhone, isNull);
  });

  test('empty and null contact phones become null', () {
    final emptyPhone = ListingDetailModel.fromJson({
      ...json,
      'contact_phone': '   ',
    });
    final nullPhone = ListingDetailModel.fromJson({
      ...json,
      'contact_phone': null,
    });

    expect(emptyPhone.contactPhone, isNull);
    expect(nullPhone.contactPhone, isNull);
  });

  test('throws FormatException for a malformed required field', () {
    expect(
      () => ListingDetailModel.fromJson({...json, 'id': 'not-an-id'}),
      throwsA(isA<FormatException>()),
    );
  });
}
