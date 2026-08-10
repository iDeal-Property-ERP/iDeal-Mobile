import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_state_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatMessagesPageModel extends ChatMessagesPage {
  const ChatMessagesPageModel({
    required super.messages,
    required super.hasMore,
    required super.conversation,
  });

  factory ChatMessagesPageModel.fromJson(DataMap json) {
    final messages = requiredList(json, 'messages')
        .map((item) => ChatMessageModel.fromJson(_messageMap(item)))
        .toList(growable: false);
    return ChatMessagesPageModel(
      messages: messages,
      hasMore: boolValue(json, 'has_more', fallback: false),
      conversation: ChatConversationStateModel.fromJson(
        requiredMap(json, 'conversation'),
      ),
    );
  }

  DataMap toJson() => {
    'messages': messages
        .map(
          (message) => ChatMessageModel(
            id: message.id,
            conversationId: message.conversationId,
            senderId: message.senderId,
            senderSide: message.senderSide,
            isMine: message.isMine,
            kind: message.kind,
            text: message.text,
            imageUrl: message.imageUrl,
            imageWidth: message.imageWidth,
            imageHeight: message.imageHeight,
            clientId: message.clientId,
            isRead: message.isRead,
            createdAt: message.createdAt,
          ).toJson(),
        )
        .toList(growable: false),
    'has_more': hasMore,
    'conversation': ChatConversationStateModel(
      id: conversation.id,
      isReadOnly: conversation.isReadOnly,
      deletedByPeer: conversation.deletedByPeer,
      isBlocked: conversation.isBlocked,
      isArchived: conversation.isArchived,
      isMuted: conversation.isMuted,
      unreadCount: conversation.unreadCount,
      lastMessageId: conversation.lastMessageId,
      peerLastReadMessageId: conversation.peerLastReadMessageId,
      listingIsAvailable: conversation.listingIsAvailable,
    ).toJson(),
  };
}

DataMap _messageMap(dynamic value) {
  final result = mapValue(value);
  if (result == null) throw const FormatException('Invalid chat message.');
  return result;
}
