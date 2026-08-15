import 'package:bloc_test/bloc_test.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:mocktail/mocktail.dart';

import 'data/chat_model_test_fixtures.dart';

class MockChatsBloc extends MockBloc<ChatsEvent, ChatsState>
    implements ChatsBloc {}

class MockListingChatConversationBloc
    extends MockBloc<ListingChatConversationEvent, ListingChatConversationState>
    implements ListingChatConversationBloc {}

ChatConversationModel buildChatConversation({
  int id = 42,
  bool isArchived = false,
  bool isMuted = false,
  bool isReadOnly = false,
  int unreadCount = 2,
  bool listingIsAvailable = true,
  String? coverImageUrl = 'https://example.com/listing.jpg',
}) {
  return ChatConversationModel.fromJson({
    ...conversationJson(),
    'id': id,
    'listing': {
      ...listingJson(),
      'id': id + 1000,
      'cover_image_url': coverImageUrl,
    },
    'is_archived': isArchived,
    'is_muted': isMuted,
    'is_read_only': isReadOnly,
    'is_blocked': isReadOnly,
    'unread_count': unreadCount,
    'listing_is_available': listingIsAvailable,
  });
}

ChatMessage buildChatImageMessage() {
  return ChatMessageModel.fromJson(
    messageJson(kind: 'image', imageUrl: 'https://example.com/chat-image.jpg'),
  );
}

MockChatsBloc mockChatsBloc(ChatsState state) {
  final bloc = MockChatsBloc();
  when(() => bloc.state).thenReturn(state);
  return bloc;
}

MockListingChatConversationBloc mockConversationBloc(
  ListingChatConversationState state,
) {
  final bloc = MockListingChatConversationBloc();
  when(() => bloc.state).thenReturn(state);
  return bloc;
}
