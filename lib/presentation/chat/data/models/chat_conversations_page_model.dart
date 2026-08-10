import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatConversationsPageModel extends ChatConversationsPage {
  const ChatConversationsPageModel({
    required super.items,
    required super.count,
    required super.numPages,
    required super.perPage,
    required super.pageNumber,
  });

  factory ChatConversationsPageModel.fromJson(DataMap json) {
    final page = requiredMap(json, 'page');
    final items = requiredList(page, 'object_list')
        .map((item) => ChatConversationModel.fromJson(_conversationMap(item)))
        .toList(growable: false);
    return ChatConversationsPageModel(
      items: items,
      count: requiredInt(json, 'count'),
      numPages: requiredInt(json, 'num_pages'),
      perPage: requiredInt(json, 'per_page'),
      pageNumber: requiredInt(page, 'number'),
    );
  }

  DataMap toJson() => {
    'count': count,
    'num_pages': numPages,
    'per_page': perPage,
    'page': {
      'number': pageNumber,
      'object_list': items
          .map(
            (item) => ChatConversationModel(
              id: item.id,
              isReadOnly: item.isReadOnly,
              deletedByPeer: item.deletedByPeer,
              isBlocked: item.isBlocked,
              isArchived: item.isArchived,
              isMuted: item.isMuted,
              unreadCount: item.unreadCount,
              lastMessageId: item.lastMessageId,
              peerLastReadMessageId: item.peerLastReadMessageId,
              listingIsAvailable: item.listingIsAvailable,
              listing: item.listing,
              lastMessagePreview: item.lastMessagePreview,
              lastMessageKind: item.lastMessageKind,
              lastMessageAt: item.lastMessageAt,
              updatedAt: item.updatedAt,
            ).toJson(),
          )
          .toList(growable: false),
    },
  };
}

DataMap _conversationMap(dynamic value) {
  final result = mapValue(value);
  if (result == null) {
    throw const FormatException('Invalid conversation.');
  }
  return result;
}
