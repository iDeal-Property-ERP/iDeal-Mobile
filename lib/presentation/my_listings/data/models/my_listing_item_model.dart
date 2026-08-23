import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listing_item.dart';

class MyListingItemModel extends MyListingItem {
  const MyListingItemModel({
    super.id,
    required super.propertyId,
    required super.title,
    super.address,
    super.district,
    super.price,
    super.currency = 'USD',
    required super.status,
    required super.statusDisplay,
    super.coverImageUrl,
    super.coverPreviewUrl,
    super.coverDisplayUrl,
    super.viewsCount = 0,
    super.rooms,
    super.areaSqm,
    super.rejectionReason,
    super.createdAt,
  });

  factory MyListingItemModel.fromJson(Map<String, dynamic> json) {
    final propertyId = json['property_id'];
    final title = json['title'];
    final status = json['status'];

    if (propertyId is! int || title is! String || status is! String) {
      throw const FormatException('Invalid my listing item data.');
    }

    return MyListingItemModel(
      id: json['id'] as int?,
      propertyId: propertyId,
      title: title,
      address: json['address'] as String?,
      district: json['district'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: (json['currency'] as String?) ?? 'USD',
      status: status,
      statusDisplay: (json['status_display'] as String?) ?? status,
      coverImageUrl: json['cover_image_url'] as String?,
      coverPreviewUrl: json['cover_preview_url'] as String?,
      coverDisplayUrl: json['cover_display_url'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      rooms: (json['rooms'] as num?)?.toInt(),
      areaSqm: (json['area_sqm'] as num?)?.toInt(),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
