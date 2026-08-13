import 'package:ideal_mobile/presentation/booking/data/models/booking_models.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingDetailModel extends ListingDetail {
  const ListingDetailModel({
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
    required super.mapLat,
    required super.mapLon,
    required super.description,
    required super.depositAmount,
    required super.minimumStay,
    required super.priceIncludes,
    required super.responseTime,
    required super.createdAt,
    required super.photos,
    required super.amenities,
    required super.verificationIsVerified,
    required super.verificationChecklist,
    required super.canMessage,
    required super.contactPhone,
    required super.booking,
  });

  factory ListingDetailModel.fromJson(DataMap json) {
    final verification = _mapValue(json['verification']);
    final createdAt = json['created_at'] == null
        ? DateTime.now()
        : DateTime.parse(_requiredString(json, 'created_at'));

    return ListingDetailModel(
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
      mapLat: _nullableDouble(json['map_lat']),
      mapLon: _nullableDouble(json['map_lon']),
      description: _nullableString(json['description']),
      depositAmount: _nullableDouble(json['deposit_amount']),
      minimumStay: _nullableInt(json['minimum_stay']),
      priceIncludes: _stringList(json['price_includes'], 'price_includes'),
      responseTime: _requiredString(json, 'response_time'),
      createdAt: createdAt,
      photos: _photos(json['photos']),
      amenities: _amenities(json['amenities']),
      verificationIsVerified: verification == null
          ? false
          : _requiredBool(verification, 'is_verified'),
      verificationChecklist: _verificationChecklist(verification?['checklist']),
      canMessage: json['can_message'] == true,
      contactPhone: _contactPhone(json['contact_phone']),
      booking: _bookingEligibility(json['booking']),
    );
  }

  DataMap toJson() => {
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
    'map_lat': mapLat,
    'map_lon': mapLon,
    'description': description,
    'deposit_amount': depositAmount,
    'minimum_stay': minimumStay,
    'price_includes': priceIncludes,
    'response_time': responseTime,
    'created_at': createdAt.toIso8601String(),
    'photos': photos.map(_photoToJson).toList(growable: false),
    'amenities': amenities.map(_amenityToJson).toList(growable: false),
    'verification': {
      'is_verified': verificationIsVerified,
      'checklist': verificationChecklist
          .map(_verificationItemToJson)
          .toList(growable: false),
    },
    'can_message': canMessage,
    'contact_phone': contactPhone,
    'booking': _bookingToJson(booking),
  };
}

BookingEligibility _bookingEligibility(dynamic value) {
  final json = _mapValue(value);
  return json == null
      ? const BookingEligibility.ineligible()
      : BookingEligibilityModel.fromJson(json);
}

DataMap _bookingToJson(BookingEligibility booking) => {
  'eligible': booking.eligible,
  'reason': booking.reason,
  'minimum_stay_months': booking.minimumStayMonths,
  'earliest_start_date': _dateOrNull(booking.earliestStartDate),
  'latest_end_date': _dateOrNull(booking.latestEndDate),
  'blocked_ranges': booking.blockedRanges
      .map(
        (range) => {
          'start_date': _dateOrNull(range.startDate),
          'end_date': _dateOrNull(range.endDate),
        },
      )
      .toList(growable: false),
  'providers': booking.providers.map((provider) => provider.name).toList(),
};

String? _dateOrNull(DateTime? value) {
  if (value == null) return null;
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

List<ListingPhoto> _photos(dynamic value) {
  if (value is! List) return const <ListingPhoto>[];

  return value
      .map((item) {
        final json = _nestedMap(item, 'photo');
        return ListingPhoto(
          id: _requiredInt(json, 'id'),
          imageUrl: _requiredString(json, 'image_url'),
          previewUrl: _nullableString(json['preview_url']),
          displayUrl: _nullableString(json['display_url']),
          caption: _nullableString(json['caption']),
          isPrimary: _requiredBool(json, 'is_primary'),
          sortOrder: _requiredInt(json, 'sort_order'),
        );
      })
      .toList(growable: false);
}

List<ListingAmenity> _amenities(dynamic value) {
  if (value is! List) return const <ListingAmenity>[];

  return value
      .map((item) {
        final json = _nestedMap(item, 'amenity');
        return ListingAmenity(
          slug: _requiredString(json, 'slug'),
          name: _requiredString(json, 'name'),
          icon: _nullableString(json['icon']),
        );
      })
      .toList(growable: false);
}

List<VerificationItem> _verificationChecklist(dynamic value) {
  if (value is! List) return const <VerificationItem>[];

  return value
      .map((item) {
        final json = _nestedMap(item, 'verification item');
        return VerificationItem(
          key: _requiredString(json, 'key'),
          label: _requiredString(json, 'label'),
        );
      })
      .toList(growable: false);
}

List<String> _stringList(dynamic value, String key) {
  if (value is! List) return const <String>[];

  return value
      .map((item) {
        if (item is String) return item;
        throw FormatException('Invalid $key.');
      })
      .toList(growable: false);
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;

  try {
    return Map<String, dynamic>.from(value);
  } catch (_) {
    return null;
  }
}

DataMap _nestedMap(dynamic value, String name) {
  final json = _mapValue(value);
  if (json == null) throw FormatException('Invalid $name.');
  return json;
}

DataMap _photoToJson(ListingPhoto photo) => {
  'id': photo.id,
  'image_url': photo.imageUrl,
  'preview_url': photo.previewUrl,
  'display_url': photo.displayUrl,
  'caption': photo.caption,
  'is_primary': photo.isPrimary,
  'sort_order': photo.sortOrder,
};

DataMap _amenityToJson(ListingAmenity amenity) => {
  'slug': amenity.slug,
  'name': amenity.name,
  'icon': amenity.icon,
};

DataMap _verificationItemToJson(VerificationItem item) => {
  'key': item.key,
  'label': item.label,
};

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

String? _contactPhone(dynamic value) {
  if (value is! String) return null;
  final phone = value.trim();
  return phone.isEmpty ? null : phone;
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
  final value = json[key];
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
  throw FormatException('Invalid $key.');
}
