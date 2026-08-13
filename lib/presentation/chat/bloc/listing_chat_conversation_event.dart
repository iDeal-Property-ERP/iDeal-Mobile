import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';

sealed class ListingChatConversationEvent extends Equatable {
  const ListingChatConversationEvent();

  @override
  List<Object?> get props => [];
}

class ChatConversationStarted extends ListingChatConversationEvent {
  const ChatConversationStarted();
}

class ChatConversationMetadataLoaded extends ListingChatConversationEvent {
  const ChatConversationMetadataLoaded(this.result);
  final Either<Failure, ChatConversation> result;
}

class ChatConversationInitialMessagesLoaded
    extends ListingChatConversationEvent {
  const ChatConversationInitialMessagesLoaded(this.result);
  final Either<Failure, ChatMessagesPage> result;
}

class ChatConversationStopped extends ListingChatConversationEvent {
  const ChatConversationStopped();
}

class ChatConversationPollTicked extends ListingChatConversationEvent {
  const ChatConversationPollTicked();
}

class ChatConversationRefreshRequested extends ListingChatConversationEvent {
  const ChatConversationRefreshRequested();
}

class ChatConversationLoadOlder extends ListingChatConversationEvent {
  const ChatConversationLoadOlder();
}

class ChatConversationLifecycleChanged extends ListingChatConversationEvent {
  const ChatConversationLifecycleChanged(this.lifecycleState);

  final AppLifecycleState lifecycleState;

  @override
  List<Object> get props => [lifecycleState];
}

class ChatConversationDraftChanged extends ListingChatConversationEvent {
  const ChatConversationDraftChanged(this.draft);

  final String draft;

  @override
  List<Object> get props => [draft];
}

class ChatConversationTextSent extends ListingChatConversationEvent {
  const ChatConversationTextSent([this.text]);

  final String? text;

  @override
  List<Object?> get props => [text];
}

class ChatConversationImageSent extends ListingChatConversationEvent {
  const ChatConversationImageSent(this.path);

  final String path;

  @override
  List<Object> get props => [path];
}

class ChatConversationRetrySent extends ListingChatConversationEvent {
  const ChatConversationRetrySent(this.clientId);

  final String clientId;

  @override
  List<Object> get props => [clientId];
}

class ChatConversationArchiveToggled extends ListingChatConversationEvent {
  const ChatConversationArchiveToggled({required this.archived});

  final bool archived;

  @override
  List<Object> get props => [archived];
}

class ChatConversationMuteToggled extends ListingChatConversationEvent {
  const ChatConversationMuteToggled({required this.muted});

  final bool muted;

  @override
  List<Object> get props => [muted];
}

class ChatConversationReportRequested extends ListingChatConversationEvent {
  const ChatConversationReportRequested({required this.reason, this.note});

  final String reason;
  final String? note;

  @override
  List<Object?> get props => [reason, note];
}
