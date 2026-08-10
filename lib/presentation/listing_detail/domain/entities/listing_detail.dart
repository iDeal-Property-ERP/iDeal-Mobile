import 'package:equatable/equatable.dart';

class ListingPhoto extends Equatable {
  const ListingPhoto({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.isPrimary,
    required this.sortOrder,
  });

  final int id;
  final String imageUrl;
  final String? caption;
  final bool isPrimary;
  final int sortOrder;

  @override
  List<Object?> get props => [id, imageUrl, caption, isPrimary, sortOrder];
}

class ListingAmenity extends Equatable {
  const ListingAmenity({
    required this.slug,
    required this.name,
    required this.icon,
  });

  final String slug;
  final String name;
  final String? icon;

  @override
  List<Object?> get props => [slug, name, icon];
}

class VerificationItem extends Equatable {
  const VerificationItem({required this.key, required this.label});

  final String key;
  final String label;

  @override
  List<Object?> get props => [key, label];
}

class ListingDetail extends Equatable {
  const ListingDetail({
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
    required this.mapLat,
    required this.mapLon,
    required this.description,
    required this.depositAmount,
    required this.minimumStay,
    required this.priceIncludes,
    required this.responseTime,
    required this.createdAt,
    required this.photos,
    required this.amenities,
    required this.verificationIsVerified,
    required this.verificationChecklist,
    required this.canMessage,
    required this.contactPhone,
  });

  final int id;
  final int propertyId;
  final String title;
  final String? district;
  final String address;
  final String propertyType;
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
  final double? mapLat;
  final double? mapLon;
  final String? description;
  final double? depositAmount;
  final int? minimumStay;
  final List<String> priceIncludes;
  final String responseTime;
  final DateTime createdAt;
  final List<ListingPhoto> photos;
  final List<ListingAmenity> amenities;
  final bool verificationIsVerified;
  final List<VerificationItem> verificationChecklist;
  final bool canMessage;
  final String? contactPhone;

  String? get coverImageUrl => photos.isEmpty ? null : photos.first.imageUrl;

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
    mapLat,
    mapLon,
    description,
    depositAmount,
    minimumStay,
    priceIncludes,
    responseTime,
    createdAt,
    photos,
    amenities,
    verificationIsVerified,
    verificationChecklist,
    canMessage,
    contactPhone,
  ];
}
