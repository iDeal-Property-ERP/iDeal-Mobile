import 'package:ideal_mobile/presentation/listings/data/models/listing_card_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingsPageModel extends ListingsPage {
  const ListingsPageModel({
    required super.items,
    required super.count,
    required super.numPages,
    required super.perPage,
    required super.pageNumber,
  });

  factory ListingsPageModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    final page = _mapValue(data['page']);
    if (page == null) {
      throw const FormatException('Listings page was not returned.');
    }

    final objectList = page['object_list'];
    if (objectList is! List) {
      throw const FormatException('Listings were not returned.');
    }

    final items = objectList.map((item) {
      final itemMap = _mapValue(item);
      if (itemMap == null) {
        throw const FormatException('A listing was not returned.');
      }
      return ListingCardModel.fromJson(itemMap);
    }).toList();

    return ListingsPageModel(
      items: items,
      count: _requiredInt(data, 'count'),
      numPages: _requiredInt(data, 'num_pages'),
      perPage: _requiredInt(data, 'per_page'),
      pageNumber: _requiredInt(page, 'number'),
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
  if (value is String) {
    final parsed = int.tryParse(value) ?? double.tryParse(value)?.toInt();
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid $key.');
}
