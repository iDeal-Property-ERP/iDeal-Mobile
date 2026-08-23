import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class PropertyUploadConfigModel extends PropertyUploadConfig {
  const PropertyUploadConfigModel({
    required super.propertyTypes,
    required super.districts,
    required super.furnishings,
    required super.amenities,
    required super.minimumStays,
    required super.priceIncludes,
    required super.currencies,
    required super.publicOffer,
    super.userProfile,
  });

  factory PropertyUploadConfigModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    return PropertyUploadConfigModel(
      propertyTypes: _choices(data['property_types']),
      districts: _districts(data['districts']),
      furnishings: _choices(data['furnishings']),
      amenities: _amenities(data['amenities']),
      minimumStays: _ints(data['minimum_stays']),
      priceIncludes: _choices(data['price_includes']),
      currencies: _strings(data['currencies']),
      publicOffer: _publicOffer(data['public_offer']),
      userProfile: _userProfile(data['user_profile']),
    );
  }
}

class PropertyUploadResultModel extends PropertyUploadResult {
  const PropertyUploadResultModel({
    required super.id,
    required super.propertyId,
    required super.status,
    required super.message,
  });

  factory PropertyUploadResultModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    return PropertyUploadResultModel(
      id: _requiredInt(data, 'id'),
      propertyId: _requiredInt(data, 'property_id'),
      status: _requiredString(data, 'status'),
      message: _optionalString(data, 'message') ?? 'Submitted',
    );
  }
}

List<ChoiceOption> _choices(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final map = _mapValue(item);
    if (map == null) {
      throw const FormatException('Invalid choice option.');
    }
    return ChoiceOption(
      value: _requiredString(map, 'value'),
      label: _requiredString(map, 'label'),
    );
  }).toList();
}

List<DistrictOption> _districts(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final map = _mapValue(item);
    if (map == null) {
      throw const FormatException('Invalid district option.');
    }
    return DistrictOption(
      id: _requiredInt(map, 'id'),
      name: _requiredString(map, 'name'),
      city: _optionalString(map, 'city') ?? 'Toshkent',
    );
  }).toList();
}

List<AmenityOption> _amenities(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final map = _mapValue(item);
    if (map == null) {
      throw const FormatException('Invalid amenity option.');
    }
    return AmenityOption(
      slug: _requiredString(map, 'slug'),
      name: _requiredString(map, 'name'),
      icon: _optionalString(map, 'icon') ?? '',
    );
  }).toList();
}

List<int> _ints(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    if (item is int) return item;
    return int.tryParse(item.toString()) ?? 0;
  }).toList();
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

PublicOfferDetail _publicOffer(dynamic value) {
  final map = _mapValue(value);
  if (map == null) return const PublicOfferDetail();
  return PublicOfferDetail(
    id: _nullableInt(map['id']),
    version: _optionalString(map, 'version'),
    body: _optionalString(map, 'body'),
  );
}

UserContactProfile? _userProfile(dynamic value) {
  final map = _mapValue(value);
  if (map == null) return null;
  return UserContactProfile(
    firstName: _optionalString(map, 'first_name'),
    lastName: _optionalString(map, 'last_name'),
    email: _optionalString(map, 'email'),
    phone: _optionalString(map, 'phone'),
  );
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String _requiredString(DataMap json, String key) {
  final value = json[key];
  if (value == null) throw FormatException('Missing $key.');
  return value is String ? value : value.toString();
}

String? _optionalString(DataMap json, String key) {
  final value = json[key];
  if (value == null) return null;
  return value is String ? value : value.toString();
}

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid integer for $key: $value');
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
