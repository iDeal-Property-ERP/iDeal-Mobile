import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';

class ChatConversationsPage extends Equatable {
  const ChatConversationsPage({
    required this.items,
    required this.count,
    required this.numPages,
    required this.perPage,
    required this.pageNumber,
  });

  final List<ChatConversation> items;
  final int count;
  final int numPages;
  final int perPage;
  final int pageNumber;

  bool get hasMore => pageNumber < numPages;

  @override
  List<Object> get props => [items, count, numPages, perPage, pageNumber];
}
