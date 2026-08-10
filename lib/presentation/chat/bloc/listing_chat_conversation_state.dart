import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';

enum ListingChatConversationStatus { initial, loading, loaded, failure }

const ChatListingRef _emptyChatListing = ChatListingRef(
  id: 0,
  title: '',
  coverImageUrl: null,
  price: null,
  currency: '',
  isAvailable: true,
);

const Object _unsetConversationError = Object();

class ListingChatConversationState extends Equatable {
  const ListingChatConversationState({
    this.status = ListingChatConversationStatus.initial,
    this.conversationId = 0,
    this.listing = _emptyChatListing,
    this.messages = const <ChatMessage>[],
    this.pending = const <PendingChatMessage>[],
    this.hasMoreOlder = false,
    this.isLoadingOlder = false,
    this.isReadOnly = false,
    this.isBlocked = false,
    this.isArchived = false,
    this.isMuted = false,
    this.listingIsAvailable = true,
    this.lastKnownMessageId,
    this.peerLastReadMessageId,
    this.draft = '',
    this.isSending = false,
    this.errorMessage,
  });

  const ListingChatConversationState.initial()
    : status = ListingChatConversationStatus.initial,
      conversationId = 0,
      listing = _emptyChatListing,
      messages = const <ChatMessage>[],
      pending = const <PendingChatMessage>[],
      hasMoreOlder = false,
      isLoadingOlder = false,
      isReadOnly = false,
      isBlocked = false,
      isArchived = false,
      isMuted = false,
      listingIsAvailable = true,
      lastKnownMessageId = null,
      peerLastReadMessageId = null,
      draft = '',
      isSending = false,
      errorMessage = null;

  @visibleForTesting
  const ListingChatConversationState.test({
    this.status = ListingChatConversationStatus.loaded,
    this.conversationId = 0,
    this.listing = _emptyChatListing,
    this.messages = const <ChatMessage>[],
    this.pending = const <PendingChatMessage>[],
    this.hasMoreOlder = false,
    this.isLoadingOlder = false,
    this.isReadOnly = false,
    this.isBlocked = false,
    this.isArchived = false,
    this.isMuted = false,
    this.listingIsAvailable = true,
    this.lastKnownMessageId,
    this.peerLastReadMessageId,
    this.draft = '',
    this.isSending = false,
    this.errorMessage,
  });

  final ListingChatConversationStatus status;
  final int conversationId;
  final ChatListingRef listing;
  final List<ChatMessage> messages;
  final List<PendingChatMessage> pending;
  final bool hasMoreOlder;
  final bool isLoadingOlder;
  final bool isReadOnly;
  final bool isBlocked;
  final bool isArchived;
  final bool isMuted;
  final bool listingIsAvailable;
  final int? lastKnownMessageId;
  final int? peerLastReadMessageId;
  final String draft;
  final bool isSending;
  final String? errorMessage;

  bool get canSend => !isReadOnly && draft.trim().isNotEmpty && !isSending;

  ChatMessageStatus statusFor(ChatMessage message) {
    if (!message.isMine) return ChatMessageStatus.sent;
    final peerRead = peerLastReadMessageId;
    if (peerRead != null && message.id <= peerRead) {
      return ChatMessageStatus.read;
    }
    return ChatMessageStatus.sent;
  }

  ListingChatConversationState copyWith({
    ListingChatConversationStatus? status,
    int? conversationId,
    ChatListingRef? listing,
    List<ChatMessage>? messages,
    List<PendingChatMessage>? pending,
    bool? hasMoreOlder,
    bool? isLoadingOlder,
    bool? isReadOnly,
    bool? isBlocked,
    bool? isArchived,
    bool? isMuted,
    bool? listingIsAvailable,
    int? lastKnownMessageId,
    int? peerLastReadMessageId,
    String? draft,
    bool? isSending,
    Object? errorMessage = _unsetConversationError,
    bool clearErrorMessage = false,
  }) {
    return ListingChatConversationState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      listing: listing ?? this.listing,
      messages: messages ?? this.messages,
      pending: pending ?? this.pending,
      hasMoreOlder: hasMoreOlder ?? this.hasMoreOlder,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isBlocked: isBlocked ?? this.isBlocked,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      listingIsAvailable: listingIsAvailable ?? this.listingIsAvailable,
      lastKnownMessageId: lastKnownMessageId ?? this.lastKnownMessageId,
      peerLastReadMessageId:
          peerLastReadMessageId ?? this.peerLastReadMessageId,
      draft: draft ?? this.draft,
      isSending: isSending ?? this.isSending,
      errorMessage: clearErrorMessage
          ? null
          : identical(errorMessage, _unsetConversationError)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  ListingChatConversationState withConversationState(
    ChatConversationState source,
  ) {
    return copyWith(
      isReadOnly: source.isReadOnly,
      isBlocked: source.isBlocked,
      isArchived: source.isArchived,
      isMuted: source.isMuted,
      listingIsAvailable: source.listingIsAvailable,
      lastKnownMessageId: source.lastMessageId,
      peerLastReadMessageId: source.peerLastReadMessageId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversationId,
    listing,
    messages,
    pending,
    hasMoreOlder,
    isLoadingOlder,
    isReadOnly,
    isBlocked,
    isArchived,
    isMuted,
    listingIsAvailable,
    lastKnownMessageId,
    peerLastReadMessageId,
    draft,
    isSending,
    errorMessage,
  ];
}
