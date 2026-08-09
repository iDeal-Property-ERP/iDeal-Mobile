import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingFilters extends Equatable {
  const ListingFilters({
    this.query,
    this.districtId,
    this.priceMin,
    this.priceMax,
    this.roomsMin,
    this.roomsMax,
    this.verified,
    this.furnishing,
    this.tariff,
  });

  const ListingFilters.empty()
    : query = null,
      districtId = null,
      priceMin = null,
      priceMax = null,
      roomsMin = null,
      roomsMax = null,
      verified = null,
      furnishing = null,
      tariff = null;

  final String? query;
  final int? districtId;
  final double? priceMin;
  final double? priceMax;
  final int? roomsMin;
  final int? roomsMax;
  final bool? verified;
  final String? furnishing;
  final String? tariff;

  /// A nullable value keeps its current value unless its matching clear flag
  /// is true. Clear flags take precedence over a value passed in the same call.
  ListingFilters copyWith({
    String? query,
    int? districtId,
    double? priceMin,
    double? priceMax,
    int? roomsMin,
    int? roomsMax,
    bool? verified,
    String? furnishing,
    String? tariff,
    bool clearQuery = false,
    bool clearDistrictId = false,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    bool clearRoomsMin = false,
    bool clearRoomsMax = false,
    bool clearVerified = false,
    bool clearFurnishing = false,
    bool clearTariff = false,
  }) {
    return ListingFilters(
      query: clearQuery ? null : query ?? this.query,
      districtId: clearDistrictId ? null : districtId ?? this.districtId,
      priceMin: clearPriceMin ? null : priceMin ?? this.priceMin,
      priceMax: clearPriceMax ? null : priceMax ?? this.priceMax,
      roomsMin: clearRoomsMin ? null : roomsMin ?? this.roomsMin,
      roomsMax: clearRoomsMax ? null : roomsMax ?? this.roomsMax,
      verified: clearVerified ? null : verified ?? this.verified,
      furnishing: clearFurnishing ? null : furnishing ?? this.furnishing,
      tariff: clearTariff ? null : tariff ?? this.tariff,
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
    addParameter('price_min', priceMin);
    addParameter('price_max', priceMax);
    addParameter('rooms_min', roomsMin);
    addParameter('rooms_max', roomsMax);
    addParameter('verified', verified);
    addParameter('furnishing', furnishing);
    addParameter('tariff', tariff);

    return parameters;
  }

  bool get isEmpty => query?.isNotEmpty != true && activeCount == 0;

  int get activeCount {
    var count = 0;
    if (districtId != null) count++;
    if (priceMin != null) count++;
    if (priceMax != null) count++;
    if (roomsMin != null) count++;
    if (roomsMax != null) count++;
    if (verified != null) count++;
    if (furnishing?.isNotEmpty ?? false) count++;
    if (tariff?.isNotEmpty ?? false) count++;
    return count;
  }

  @override
  List<Object?> get props => [
    query,
    districtId,
    priceMin,
    priceMax,
    roomsMin,
    roomsMax,
    verified,
    furnishing,
    tariff,
  ];
}
