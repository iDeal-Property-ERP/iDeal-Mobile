import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class ChatsStarted extends ChatsEvent {
  const ChatsStarted();
}

class ChatsStopped extends ChatsEvent {
  const ChatsStopped();
}

class ChatsTabSelected extends ChatsEvent {
  const ChatsTabSelected(this.tab);

  final ChatsTab tab;

  @override
  List<Object> get props => [tab];
}

class ChatsRefreshRequested extends ChatsEvent {
  const ChatsRefreshRequested({this.tab});

  final ChatsTab? tab;

  @override
  List<Object?> get props => [tab];
}

class ChatsLoadMoreRequested extends ChatsEvent {
  const ChatsLoadMoreRequested(this.tab);

  final ChatsTab tab;

  @override
  List<Object> get props => [tab];
}

class ChatsPollTicked extends ChatsEvent {
  const ChatsPollTicked();
}

class ChatsLifecycleChanged extends ChatsEvent {
  const ChatsLifecycleChanged(this.lifecycleState);

  final AppLifecycleState lifecycleState;

  @override
  List<Object> get props => [lifecycleState];
}

class ChatsArchiveToggled extends ChatsEvent {
  const ChatsArchiveToggled({
    required this.conversationId,
    required this.archived,
  });

  final int conversationId;
  final bool archived;

  @override
  List<Object> get props => [conversationId, archived];
}

class ChatsMuteToggled extends ChatsEvent {
  const ChatsMuteToggled({required this.conversationId, required this.muted});

  final int conversationId;
  final bool muted;

  @override
  List<Object> get props => [conversationId, muted];
}

class ChatsConversationReported extends ChatsEvent {
  const ChatsConversationReported({
    required this.conversationId,
    required this.reason,
    this.note,
  });

  final int conversationId;
  final String reason;
  final String? note;

  @override
  List<Object?> get props => [conversationId, reason, note];
}

class ChatsConversationDeleted extends ChatsEvent {
  const ChatsConversationDeleted(this.conversationId);

  final int conversationId;

  @override
  List<Object> get props => [conversationId];
}
