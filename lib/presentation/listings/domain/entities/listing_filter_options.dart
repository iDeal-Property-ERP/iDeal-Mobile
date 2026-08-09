import 'package:equatable/equatable.dart';

class ListingDistrict extends Equatable {
  const ListingDistrict({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object> get props => [id, name];
}

class ListingChoice extends Equatable {
  const ListingChoice({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object> get props => [value, label];
}

class ListingFilterOptions extends Equatable {
  const ListingFilterOptions({
    this.districts = const [],
    this.tariffs = const [],
    this.furnishings = const [],
    this.priceMin,
    this.priceMax,
    this.roomsMin,
    this.roomsMax,
  });

  const ListingFilterOptions.empty()
    : districts = const [],
      tariffs = const [],
      furnishings = const [],
      priceMin = null,
      priceMax = null,
      roomsMin = null,
      roomsMax = null;

  final List<ListingDistrict> districts;
  final List<ListingChoice> tariffs;
  final List<ListingChoice> furnishings;
  final double? priceMin;
  final double? priceMax;
  final int? roomsMin;
  final int? roomsMax;

  @override
  List<Object?> get props => [
    districts,
    tariffs,
    furnishings,
    priceMin,
    priceMax,
    roomsMin,
    roomsMax,
  ];
}
