import 'package:ideal_mobile/presentation/listing_map/domain/entities/listing_map_result.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listing_card_model.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingMapResultModel extends ListingMapResult {
  const ListingMapResultModel({
    required super.items,
    required super.count,
    required super.truncated,
  });

  factory ListingMapResultModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    final rawItems = data['items'];
    if (rawItems is! List) {
      throw const FormatException('Invalid map listing items.');
    }

    final items = rawItems
        .map((value) {
          final map = _mapValue(value);
          if (map == null) {
            throw const FormatException('Invalid map listing item.');
          }
          final item = ListingCardModel.fromJson(map);
          if (item.mapLat == null || item.mapLon == null) {
            throw const FormatException(
              'Map listing coordinates are required.',
            );
          }
          return item;
        })
        .toList(growable: false);

    return ListingMapResultModel(
      items: items,
      count: _requiredInt(data, 'count'),
      truncated: _requiredBool(data, 'truncated'),
    );
  }
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

int _requiredInt(DataMap json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value?.toString() ?? '');
  if (parsed == null) throw FormatException('Invalid $key.');
  return parsed;
}

bool _requiredBool(DataMap json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Invalid $key.');
}
