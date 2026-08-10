import 'dart:io';

import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingChatRepository {
  ResultFuture<ChatConversation> openConversation({required int listingId});

  ResultFuture<ChatConversationsPage> getConversations({
    required bool archived,
    required int page,
    required int perPage,
  });

  ResultFuture<ChatSummary> getChatSummary({DateTime? since});

  ResultFuture<ChatConversation> getConversation({required int id});

  ResultFuture<ChatMessagesPage> getMessages({
    required int conversationId,
    int? afterId,
    int? beforeId,
    required int limit,
  });

  ResultFuture<ChatMessage> sendTextMessage({
    required int conversationId,
    required String text,
    required String clientId,
  });

  ResultFuture<ChatMessage> sendImageMessage({
    required int conversationId,
    required File image,
    required String clientId,
  });

  ResultFuture<ChatConversationState> markConversationRead({
    required int conversationId,
    int? upToMessageId,
  });

  ResultFuture<ChatConversationState> setConversationArchived({
    required int conversationId,
    required bool value,
  });

  ResultFuture<ChatConversationState> setConversationMuted({
    required int conversationId,
    required bool value,
  });

  ResultVoid reportConversation({
    required int conversationId,
    required String reason,
    String? note,
  });

  ResultVoid deleteConversation({required int conversationId});
}
