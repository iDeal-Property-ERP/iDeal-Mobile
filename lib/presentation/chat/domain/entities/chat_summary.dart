import 'package:equatable/equatable.dart';

class ChatSummary extends Equatable {
  const ChatSummary({
    required this.totalUnread,
    required this.changedConversationIds,
    required this.serverTime,
  });

  final int totalUnread;
  final List<int> changedConversationIds;
  final DateTime serverTime;

  @override
  List<Object> get props => [totalUnread, changedConversationIds, serverTime];
}
