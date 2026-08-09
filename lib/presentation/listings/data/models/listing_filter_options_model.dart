import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingFilterOptionsModel extends ListingFilterOptions {
  const ListingFilterOptionsModel({
    super.districts,
    super.tariffs,
    super.furnishings,
    super.priceMin,
    super.priceMax,
    super.roomsMin,
    super.roomsMax,
  });

  factory ListingFilterOptionsModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    return ListingFilterOptionsModel(
      districts: _districts(data['districts']),
      tariffs: _choices(data['tariffs']),
      furnishings: _choices(data['furnishings']),
      priceMin: _nullableDouble(_mapValue(data['price'])?['min']),
      priceMax: _nullableDouble(_mapValue(data['price'])?['max']),
      roomsMin: _nullableInt(_mapValue(data['rooms'])?['min']),
      roomsMax: _nullableInt(_mapValue(data['rooms'])?['max']),
    );
  }
}

List<ListingDistrict> _districts(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final map = _mapValue(item);
    if (map == null) {
      throw const FormatException('Invalid district filter option.');
    }
    return ListingDistrict(
      id: _requiredInt(map, 'id'),
      name: _requiredString(map, 'name'),
    );
  }).toList();
}

List<ListingChoice> _choices(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) {
    final map = _mapValue(item);
    if (map == null) {
      throw const FormatException('Invalid listing filter option.');
    }
    return ListingChoice(
      value: _requiredString(map, 'value'),
      label: _requiredString(map, 'label'),
    );
  }).toList();
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

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  final parsed = _nullableInt(value);
  if (parsed == null) throw FormatException('Invalid $key.');
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

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
