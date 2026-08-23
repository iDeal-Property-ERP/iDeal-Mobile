import 'package:equatable/equatable.dart';

class MyListingItem extends Equatable {
  const MyListingItem({
    this.id,
    required this.propertyId,
    required this.title,
    this.address,
    this.district,
    this.price,
    this.currency = 'USD',
    required this.status,
    required this.statusDisplay,
    this.coverImageUrl,
    this.coverPreviewUrl,
    this.coverDisplayUrl,
    this.viewsCount = 0,
    this.rooms,
    this.areaSqm,
    this.rejectionReason,
    this.createdAt,
  });

  final int? id;
  final int propertyId;
  final String title;
  final String? address;
  final String? district;
  final double? price;
  final String currency;
  final String status;
  final String statusDisplay;
  final String? coverImageUrl;
  final String? coverPreviewUrl;
  final String? coverDisplayUrl;
  final int viewsCount;
  final int? rooms;
  final int? areaSqm;
  final String? rejectionReason;
  final String? createdAt;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRented => status == 'rented';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    id,
    propertyId,
    title,
    address,
    district,
    price,
    currency,
    status,
    statusDisplay,
    coverImageUrl,
    coverPreviewUrl,
    coverDisplayUrl,
    viewsCount,
    rooms,
    areaSqm,
    rejectionReason,
    createdAt,
  ];
}
