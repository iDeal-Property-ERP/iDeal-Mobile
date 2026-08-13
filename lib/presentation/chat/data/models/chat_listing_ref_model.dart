import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatListingRefModel extends ChatListingRef {
  const ChatListingRefModel({
    required super.id,
    required super.title,
    required super.coverImageUrl,
    super.coverPreviewUrl,
    super.coverDisplayUrl,
    required super.price,
    required super.currency,
    required super.isAvailable,
  });

  factory ChatListingRefModel.fromJson(DataMap json) {
    return ChatListingRefModel(
      id: requiredInt(json, 'id'),
      title: requiredString(json, 'title'),
      coverImageUrl: nullableString(json['cover_image_url']),
      coverPreviewUrl: nullableString(json['cover_preview_url']),
      coverDisplayUrl: nullableString(json['cover_display_url']),
      price: nullableDouble(json['price']),
      currency: nullableString(json['currency']) ?? '',
      isAvailable: boolValue(json, 'is_available', fallback: true),
    );
  }

  DataMap toJson() {
    final result = <String, dynamic>{
      'id': id,
      'title': title,
      'cover_image_url': coverImageUrl,
      'price': price,
      'currency': currency,
      'is_available': isAvailable,
    };
    if (coverPreviewUrl != null) result['cover_preview_url'] = coverPreviewUrl;
    if (coverDisplayUrl != null) result['cover_display_url'] = coverDisplayUrl;
    return result;
  }
}
