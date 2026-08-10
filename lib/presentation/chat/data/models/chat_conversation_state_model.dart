import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatConversationStateModel extends ChatConversationState {
  const ChatConversationStateModel({
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
  });

  factory ChatConversationStateModel.fromJson(DataMap json) {
    return ChatConversationStateModel(
      id: requiredInt(json, 'id'),
      isReadOnly: boolValue(json, 'is_read_only', fallback: false),
      deletedByPeer: boolValue(json, 'deleted_by_peer', fallback: false),
      isBlocked: boolValue(json, 'is_blocked', fallback: false),
      isArchived: boolValue(json, 'is_archived', fallback: false),
      isMuted: boolValue(json, 'is_muted', fallback: false),
      unreadCount: nullableInt(json['unread_count']) ?? 0,
      lastMessageId: nullableInt(json['last_message_id']),
      peerLastReadMessageId: nullableInt(json['peer_last_read_message_id']),
      listingIsAvailable: boolValue(
        json,
        'listing_is_available',
        fallback: true,
      ),
    );
  }

  DataMap toJson() => {
    'id': id,
    'is_read_only': isReadOnly,
    'deleted_by_peer': deletedByPeer,
    'is_blocked': isBlocked,
    'is_archived': isArchived,
    'is_muted': isMuted,
    'unread_count': unreadCount,
    'last_message_id': lastMessageId,
    'peer_last_read_message_id': peerLastReadMessageId,
    'listing_is_available': listingIsAvailable,
  };
}
