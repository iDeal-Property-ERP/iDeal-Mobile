import 'package:equatable/equatable.dart';

class ListingCard extends Equatable {
  const ListingCard({
    required this.id,
    required this.propertyId,
    required this.title,
    required this.district,
    required this.address,
    required this.propertyType,
    required this.rooms,
    required this.areaSqm,
    required this.floor,
    required this.totalFloors,
    required this.furnishing,
    required this.price,
    required this.currency,
    required this.tariff,
    required this.isVerified,
    required this.isFeatured,
    required this.score,
    required this.reviewCount,
    required this.coverImageUrl,
    this.coverPreviewUrl,
    this.coverDisplayUrl,
    required this.mapLat,
    required this.mapLon,
  });

  final int id;
  final int propertyId;
  final String title;
  final String? district;
  final String address;
  final String propertyType;
  // Property.rooms and Property.area_sqm are nullable in the backend and real
  // rows do have NULLs, so both are optional here.
  final int? rooms;
  final int? areaSqm;
  final int? floor;
  final int? totalFloors;
  final String furnishing;
  final double? price;
  final String currency;
  final String tariff;
  final bool isVerified;
  final bool isFeatured;
  final double score;
  final int reviewCount;
  final String? coverImageUrl;

  /// Nullable responsive variants from the backend; [coverImageUrl] remains
  /// the legacy/original URL for old API responses.
  final String? coverPreviewUrl;
  final String? coverDisplayUrl;
  final double? mapLat;
  final double? mapLon;

  @override
  List<Object?> get props => [
    id,
    propertyId,
    title,
    district,
    address,
    propertyType,
    rooms,
    areaSqm,
    floor,
    totalFloors,
    furnishing,
    price,
    currency,
    tariff,
    isVerified,
    isFeatured,
    score,
    reviewCount,
    coverImageUrl,
    coverPreviewUrl,
    coverDisplayUrl,
    mapLat,
    mapLon,
  ];
}
