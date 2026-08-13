import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderSide,
    required super.isMine,
    required super.kind,
    required super.text,
    required super.imageUrl,
    super.imagePreviewUrl,
    super.imageDisplayUrl,
    required super.imageWidth,
    required super.imageHeight,
    required super.clientId,
    required super.isRead,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(DataMap json) {
    return ChatMessageModel(
      id: requiredInt(json, 'id'),
      conversationId: requiredInt(json, 'conversation_id'),
      senderId: requiredInt(json, 'sender_id'),
      senderSide: requiredString(json, 'sender_side'),
      isMine: boolValue(json, 'is_mine', fallback: false),
      kind: requiredString(json, 'kind'),
      text: nullableString(json['text']),
      imageUrl: nullableString(json['image_url']),
      imagePreviewUrl: nullableString(json['image_preview_url']),
      imageDisplayUrl: nullableString(json['image_display_url']),
      imageWidth: nullableInt(json['image_width']),
      imageHeight: nullableInt(json['image_height']),
      clientId: nullableString(json['client_id']),
      isRead: boolValue(json, 'is_read', fallback: false),
      createdAt: requiredDateTime(json, 'created_at'),
    );
  }

  DataMap toJson() {
    final result = <String, dynamic>{
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_side': senderSide,
      'is_mine': isMine,
      'kind': kind,
      'text': text,
      'image_url': imageUrl,
      'image_width': imageWidth,
      'image_height': imageHeight,
      'client_id': clientId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
    if (imagePreviewUrl != null) result['image_preview_url'] = imagePreviewUrl;
    if (imageDisplayUrl != null) result['image_display_url'] = imageDisplayUrl;
    return result;
  }
}
