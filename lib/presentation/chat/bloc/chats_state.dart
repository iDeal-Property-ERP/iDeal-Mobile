import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';

enum ChatsStatus { initial, loading, loaded, failure }

const Object _unsetChatsError = Object();

class ChatsState extends Equatable {
  const ChatsState({
    this.status = ChatsStatus.initial,
    this.activeItems = const <ChatConversation>[],
    this.archivedItems = const <ChatConversation>[],
    this.archivedExpanded = false,
    this.archivedLoaded = false,
    this.isLoadingArchived = false,
    this.unreadTotal = 0,
    this.isPolling = false,
    this.errorMessage,
  });

  const ChatsState.initial()
    : status = ChatsStatus.initial,
      activeItems = const <ChatConversation>[],
      archivedItems = const <ChatConversation>[],
      archivedExpanded = false,
      archivedLoaded = false,
      isLoadingArchived = false,
      unreadTotal = 0,
      isPolling = false,
      errorMessage = null;

  @visibleForTesting
  const ChatsState.test({
    this.status = ChatsStatus.loaded,
    this.activeItems = const <ChatConversation>[],
    this.archivedItems = const <ChatConversation>[],
    this.archivedExpanded = false,
    this.archivedLoaded = false,
    this.isLoadingArchived = false,
    this.unreadTotal = 0,
    this.isPolling = false,
    this.errorMessage,
  });

  final ChatsStatus status;
  final List<ChatConversation> activeItems;
  final List<ChatConversation> archivedItems;
  final bool archivedExpanded;
  final bool archivedLoaded;
  final bool isLoadingArchived;
  final int unreadTotal;
  final bool isPolling;
  final String? errorMessage;

  bool get isLoading => status == ChatsStatus.loading;

  ChatsState copyWith({
    ChatsStatus? status,
    List<ChatConversation>? activeItems,
    List<ChatConversation>? archivedItems,
    bool? archivedExpanded,
    bool? archivedLoaded,
    bool? isLoadingArchived,
    int? unreadTotal,
    bool? isPolling,
    Object? errorMessage = _unsetChatsError,
    bool clearErrorMessage = false,
  }) {
    return ChatsState(
      status: status ?? this.status,
      activeItems: activeItems ?? this.activeItems,
      archivedItems: archivedItems ?? this.archivedItems,
      archivedExpanded: archivedExpanded ?? this.archivedExpanded,
      archivedLoaded: archivedLoaded ?? this.archivedLoaded,
      isLoadingArchived: isLoadingArchived ?? this.isLoadingArchived,
      unreadTotal: unreadTotal ?? this.unreadTotal,
      isPolling: isPolling ?? this.isPolling,
      errorMessage: clearErrorMessage
          ? null
          : identical(errorMessage, _unsetChatsError)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    activeItems,
    archivedItems,
    archivedExpanded,
    archivedLoaded,
    isLoadingArchived,
    unreadTotal,
    isPolling,
    errorMessage,
  ];
}
