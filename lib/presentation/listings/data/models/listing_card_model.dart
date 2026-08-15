import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingCardModel extends ListingCard {
  const ListingCardModel({
    required super.id,
    required super.propertyId,
    required super.title,
    required super.district,
    required super.address,
    required super.propertyType,
    required super.rooms,
    required super.areaSqm,
    required super.floor,
    required super.totalFloors,
    required super.furnishing,
    required super.price,
    required super.currency,
    required super.tariff,
    required super.isVerified,
    required super.isFeatured,
    required super.score,
    required super.reviewCount,
    required super.coverImageUrl,
    super.coverPreviewUrl,
    super.coverDisplayUrl,
    required super.mapLat,
    required super.mapLon,
    super.contactPhone,
    super.isFavorite,
  });

  factory ListingCardModel.fromJson(DataMap json) {
    return ListingCardModel(
      id: _requiredInt(json, 'id'),
      propertyId: _requiredInt(json, 'property_id'),
      title: _requiredString(json, 'title'),
      district: _nullableString(json['district']),
      address: _requiredString(json, 'address'),
      propertyType: _requiredString(json, 'property_type'),
      rooms: _nullableInt(json['rooms']),
      areaSqm: _nullableInt(json['area_sqm']),
      floor: _nullableInt(json['floor']),
      totalFloors: _nullableInt(json['total_floors']),
      furnishing: _requiredString(json, 'furnishing'),
      price: _nullableDouble(json['price']),
      currency: _requiredString(json, 'currency'),
      tariff: _requiredString(json, 'tariff'),
      isVerified: _requiredBool(json, 'is_verified'),
      isFeatured: _requiredBool(json, 'is_featured'),
      score: _requiredDouble(json, 'score'),
      reviewCount: _requiredInt(json, 'review_count'),
      coverImageUrl: _nullableString(json['cover_image_url']),
      coverPreviewUrl: _nullableString(json['cover_preview_url']),
      coverDisplayUrl: _nullableString(json['cover_display_url']),
      mapLat: _nullableDouble(json['map_lat']),
      mapLon: _nullableDouble(json['map_lon']),
      contactPhone: _nullableString(json['contact_phone']),
      isFavorite: _nullableBool(json['is_favorite']) ?? false,
    );
  }

  DataMap toJson() {
    final result = <String, dynamic>{
      'id': id,
      'property_id': propertyId,
      'title': title,
      'district': district,
      'address': address,
      'property_type': propertyType,
      'rooms': rooms,
      'area_sqm': areaSqm,
      'floor': floor,
      'total_floors': totalFloors,
      'furnishing': furnishing,
      'price': price,
      'currency': currency,
      'tariff': tariff,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'score': score,
      'review_count': reviewCount,
      'cover_image_url': coverImageUrl,
      'map_lat': mapLat,
      'map_lon': mapLon,
    };
    if (coverPreviewUrl != null) result['cover_preview_url'] = coverPreviewUrl;
    if (coverDisplayUrl != null) result['cover_display_url'] = coverDisplayUrl;
    if (contactPhone != null) result['contact_phone'] = contactPhone;
    result['is_favorite'] = isFavorite;
    return result;
  }
}

String _requiredString(DataMap json, String key) {
  final value = json[key];
  if (value == null) {
    throw FormatException('Missing $key.');
  }
  return value is String ? value : value.toString();
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  return value is String ? value : value.toString();
}

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  final parsed = _nullableInt(value);
  if (parsed == null) {
    throw FormatException('Invalid $key.');
  }
  return parsed;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double _requiredDouble(DataMap json, String key) {
  final parsed = _nullableDouble(json[key]);
  if (parsed == null) {
    throw FormatException('Invalid $key.');
  }
  return parsed;
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _requiredBool(DataMap json, String key) {
  final parsed = _nullableBool(json[key]);
  if (parsed != null) return parsed;
  throw FormatException('Invalid $key.');
}

bool? _nullableBool(dynamic value) {
  if (value is bool) return value;
  if (value is num && (value == 0 || value == 1)) return value == 1;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
    }
  }
  return null;
}
