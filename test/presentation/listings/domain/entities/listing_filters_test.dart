import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

void main() {
  final start = DateTime(2026, 9);
  final end = DateTime(2026, 9, 10);

  group('ListingFilters availability', () {
    test('hasDateRange is true only when both dates are present', () {
      expect(const ListingFilters().hasDateRange, isFalse);
      expect(ListingFilters(startDate: start).hasDateRange, isFalse);
      expect(
        ListingFilters(startDate: start, endDate: end).hasDateRange,
        isTrue,
      );
    });

    test('toQueryParameters serializes dates and default flexibility', () {
      final filters = ListingFilters(startDate: start, endDate: end);

      expect(filters.toQueryParameters(), {
        'start_date': '2026-09-01',
        'end_date': '2026-09-10',
        'flexibility_days': kDefaultFlexibilityDays,
      });
    });

    test('toQueryParameters emits explicit flexibility', () {
      final filters = ListingFilters(
        startDate: start,
        endDate: end,
        flexibilityDays: 7,
      );

      expect(filters.toQueryParameters()['flexibility_days'], equals(7));
    });

    test('toQueryParameters omits availability keys without a range', () {
      const filters = ListingFilters();

      expect(filters.toQueryParameters(), isEmpty);
      expect(filters.toQueryParameters().containsKey('start_date'), isFalse);
      expect(
        filters.toQueryParameters().containsKey('flexibility_days'),
        isFalse,
      );
    });

    test('activeCount counts a complete date range as a single filter', () {
      const withoutDates = ListingFilters(propertyType: 'apartment');
      final withDates = ListingFilters(
        propertyType: 'apartment',
        startDate: start,
        endDate: end,
      );

      expect(withoutDates.activeCount, 1);
      expect(withDates.activeCount, 2);
    });

    test('copyWith updates dates without affecting other fields', () {
      const base = ListingFilters(propertyType: 'apartment');
      final updated = base.copyWith(startDate: start, endDate: end);

      expect(updated.propertyType, 'apartment');
      expect(updated.hasDateRange, isTrue);
      expect(updated.flexibilityDays, isNull);
    });

    test('clearDates also clears flexibility', () {
      final filters = ListingFilters(
        startDate: start,
        endDate: end,
        flexibilityDays: 5,
      );
      final cleared = filters.copyWith(clearDates: true);

      expect(cleared.hasDateRange, isFalse);
      expect(cleared.flexibilityDays, isNull);
    });

    test('clearFlexibility resets only flexibility', () {
      final filters = ListingFilters(
        startDate: start,
        endDate: end,
        flexibilityDays: 5,
      );
      final cleared = filters.copyWith(clearFlexibility: true);

      expect(cleared.hasDateRange, isTrue);
      expect(cleared.flexibilityDays, isNull);
    });

    test('equality includes date fields', () {
      expect(
        ListingFilters(startDate: start, endDate: end),
        ListingFilters(startDate: start, endDate: end),
      );
      expect(
        ListingFilters(startDate: start, endDate: end),
        isNot(ListingFilters(startDate: start, endDate: start)),
      );
    });

    test('exposes flexibility bounds', () {
      expect(kDefaultFlexibilityDays, 3);
      expect(kMaxFlexibilityDays, 30);
    });
  });
}
