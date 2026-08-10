import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';

class ChatMessagesPage extends Equatable {
  const ChatMessagesPage({
    required this.messages,
    required this.hasMore,
    required this.conversation,
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final ChatConversationState conversation;

  @override
  List<Object> get props => [messages, hasMore, conversation];
}
