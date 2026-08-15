import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listing_filter_options_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

void main() {
  test('property type participates in query, copy, count, and equality', () {
    const filters = ListingFilters(propertyType: 'apartment');

    expect(filters.toQueryParameters(), {'property_type': 'apartment'});
    expect(filters.activeCount, 1);
    expect(filters, const ListingFilters(propertyType: 'apartment'));
    expect(filters.copyWith(clearPropertyType: true).propertyType, isNull);
  });

  test('parses localized property type filter choices', () {
    final options = ListingFilterOptionsModel.fromJson({
      'data': {
        'property_types': [
          {'value': 'apartment', 'label': 'Apartment'},
        ],
      },
    });

    expect(options.propertyTypes.single.value, 'apartment');
    expect(options.propertyTypes.single.label, 'Apartment');
  });
}
