import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/typedef.dart';

/// Default flexibility (in days) applied when a date range is selected but the
/// user has not overridden it. Mirrors the backend's availability default.
const int kDefaultFlexibilityDays = 3;

/// Upper bound for the mobile availability flexibility control.
const int kMaxFlexibilityDays = 30;

class ListingFilters extends Equatable {
  const ListingFilters({
    this.query,
    this.districtId,
    this.propertyType,
    this.priceMin,
    this.priceMax,
    this.currency,
    this.roomsMin,
    this.roomsMax,
    this.verified,
    this.furnishing,
    this.tariff,
    this.sort,
    this.startDate,
    this.endDate,
    this.flexibilityDays,
  });

  const ListingFilters.empty()
    : query = null,
      districtId = null,
      propertyType = null,
      priceMin = null,
      priceMax = null,
      currency = null,
      roomsMin = null,
      roomsMax = null,
      verified = null,
      furnishing = null,
      tariff = null,
      sort = null,
      startDate = null,
      endDate = null,
      flexibilityDays = null;

  final String? query;
  final int? districtId;
  final String? propertyType;
  final double? priceMin;
  final double? priceMax;
  final String? currency;
  final int? roomsMin;
  final int? roomsMax;
  final bool? verified;
  final String? furnishing;
  final String? tariff;
  final String? sort;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? flexibilityDays;

  /// True when both ends of the availability window are set.
  bool get hasDateRange => startDate != null && endDate != null;

  /// A nullable value keeps its current value unless its matching clear flag
  /// is true. Clear flags take precedence over a value passed in the same call.
  ListingFilters copyWith({
    String? query,
    int? districtId,
    String? propertyType,
    double? priceMin,
    double? priceMax,
    String? currency,
    int? roomsMin,
    int? roomsMax,
    bool? verified,
    String? furnishing,
    String? tariff,
    String? sort,
    DateTime? startDate,
    DateTime? endDate,
    int? flexibilityDays,
    bool clearQuery = false,
    bool clearDistrictId = false,
    bool clearPropertyType = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    bool clearCurrency = false,
    bool clearRoomsMin = false,
    bool clearRoomsMax = false,
    bool clearVerified = false,
    bool clearFurnishing = false,
    bool clearTariff = false,
    bool clearSort = false,
    bool clearDates = false,
    bool clearFlexibility = false,
  }) {
    return ListingFilters(
      query: clearQuery ? null : query ?? this.query,
      districtId: clearDistrictId ? null : districtId ?? this.districtId,
      propertyType: clearPropertyType
          ? null
          : propertyType ?? this.propertyType,
      priceMin: clearPriceMin ? null : priceMin ?? this.priceMin,
      priceMax: clearPriceMax ? null : priceMax ?? this.priceMax,
      currency: clearCurrency ? null : currency ?? this.currency,
      roomsMin: clearRoomsMin ? null : roomsMin ?? this.roomsMin,
      roomsMax: clearRoomsMax ? null : roomsMax ?? this.roomsMax,
      verified: clearVerified ? null : verified ?? this.verified,
      furnishing: clearFurnishing ? null : furnishing ?? this.furnishing,
      tariff: clearTariff ? null : tariff ?? this.tariff,
      sort: clearSort ? null : sort ?? this.sort,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
      flexibilityDays: clearDates || clearFlexibility
          ? null
          : flexibilityDays ?? this.flexibilityDays,
    );
  }

  DataMap toQueryParameters() {
    final parameters = <String, dynamic>{};

    void addParameter(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      parameters[key] = value;
    }

    addParameter('q', query);
    addParameter('district_id', districtId);
    addParameter('property_type', propertyType);
    addParameter('price_min', priceMin);
    addParameter('price_max', priceMax);
    addParameter('currency', currency);
    addParameter('rooms_min', roomsMin);
    addParameter('rooms_max', roomsMax);
    addParameter('verified', verified);
    addParameter('furnishing', furnishing);
    addParameter('tariff', tariff);
    addParameter('sort', sort);
    addParameter('start_date', startDate?.format(pattern: 'yyyy-MM-dd'));
    addParameter('end_date', endDate?.format(pattern: 'yyyy-MM-dd'));
    // Flexibility is only meaningful together with a complete date range.
    if (hasDateRange) {
      addParameter(
        'flexibility_days',
        flexibilityDays ?? kDefaultFlexibilityDays,
      );
    }

    return parameters;
  }

  bool get isEmpty => query?.isNotEmpty != true && activeCount == 0;

  int get activeCount {
    var count = 0;
    if (districtId != null) count++;
    if (propertyType?.isNotEmpty ?? false) count++;
    if (priceMin != null) count++;
    if (priceMax != null) count++;
    if (roomsMin != null) count++;
    if (roomsMax != null) count++;
    if (verified != null) count++;
    if (furnishing?.isNotEmpty ?? false) count++;
    if (tariff?.isNotEmpty ?? false) count++;
    // A complete date range counts as a single active filter.
    if (hasDateRange) count++;
    return count;
  }

  @override
  List<Object?> get props => [
    query,
    districtId,
    propertyType,
    priceMin,
    priceMax,
    currency,
    roomsMin,
    roomsMax,
    verified,
    furnishing,
    tariff,
    sort,
    startDate,
    endDate,
    flexibilityDays,
  ];
}
