import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_state_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_listing_ref_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.isReadOnly,
    required super.deletedByPeer,
    required super.isBlocked,
    required super.isArchived,
    required super.isMuted,
    required super.unreadCount,
    required super.lastMessageId,
    required super.peerLastReadMessageId,
    required super.listingIsAvailable,
    required super.listing,
    required super.lastMessagePreview,
    required super.lastMessageKind,
    required super.lastMessageAt,
    required super.updatedAt,
  });

  factory ChatConversationModel.fromJson(DataMap json) {
    final state = ChatConversationStateModel.fromJson(json);
    return ChatConversationModel(
      id: state.id,
      isReadOnly: state.isReadOnly,
      deletedByPeer: state.deletedByPeer,
      isBlocked: state.isBlocked,
      isArchived: state.isArchived,
      isMuted: state.isMuted,
      unreadCount: state.unreadCount,
      lastMessageId: state.lastMessageId,
      peerLastReadMessageId: state.peerLastReadMessageId,
      listingIsAvailable: state.listingIsAvailable,
      listing: ChatListingRefModel.fromJson(requiredMap(json, 'listing')),
      lastMessagePreview: nullableString(json['last_message_preview']),
      lastMessageKind: nullableString(json['last_message_kind']),
      lastMessageAt: nullableDateTime(json['last_message_at']),
      updatedAt: requiredDateTime(json, 'updated_at'),
    );
  }

  DataMap toJson() => {
    ...ChatConversationStateModel(
      id: id,
      isReadOnly: isReadOnly,
      deletedByPeer: deletedByPeer,
      isBlocked: isBlocked,
      isArchived: isArchived,
      isMuted: isMuted,
      unreadCount: unreadCount,
      lastMessageId: lastMessageId,
      peerLastReadMessageId: peerLastReadMessageId,
      listingIsAvailable: listingIsAvailable,
    ).toJson(),
    'listing': ChatListingRefModel(
      id: listing.id,
      title: listing.title,
      coverImageUrl: listing.coverImageUrl,
      price: listing.price,
      currency: listing.currency,
      isAvailable: listing.isAvailable,
    ).toJson(),
    'last_message_preview': lastMessagePreview,
    'last_message_kind': lastMessageKind,
    'last_message_at': lastMessageAt?.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
