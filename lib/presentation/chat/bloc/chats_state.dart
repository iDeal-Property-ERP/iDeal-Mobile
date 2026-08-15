import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';

enum ChatsTab {
  active,
  archived;

  bool get isArchived => this == ChatsTab.archived;
}

const Object _unsetFeedError = Object();
const Object _unsetChatsError = Object();

class ChatsFeedState extends Equatable {
  const ChatsFeedState({
    this.items = const <ChatConversation>[],
    this.page = 0,
    this.numPages = 0,
    this.count = 0,
    this.hasLoaded = false,
    this.hasReachedMax = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.failedPage,
  });

  final List<ChatConversation> items;
  final int page;
  final int numPages;
  final int count;
  final bool hasLoaded;
  final bool hasReachedMax;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int? failedPage;

  ChatsFeedState copyWith({
    List<ChatConversation>? items,
    int? page,
    int? numPages,
    int? count,
    bool? hasLoaded,
    bool? hasReachedMax,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unsetFeedError,
    int? failedPage,
    bool clearErrorMessage = false,
    bool clearFailedPage = false,
  }) {
    return ChatsFeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      numPages: numPages ?? this.numPages,
      count: count ?? this.count,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearErrorMessage
          ? null
          : identical(errorMessage, _unsetFeedError)
          ? this.errorMessage
          : errorMessage as String?,
      failedPage: clearFailedPage ? null : failedPage ?? this.failedPage,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    numPages,
    count,
    hasLoaded,
    hasReachedMax,
    isLoading,
    isLoadingMore,
    errorMessage,
    failedPage,
  ];
}

class ChatsState extends Equatable {
  const ChatsState({
    this.selectedTab = ChatsTab.active,
    this.activeFeed = const ChatsFeedState(),
    this.archivedFeed = const ChatsFeedState(),
    this.unreadTotal = 0,
    this.isPolling = false,
    this.errorMessage,
  });

  const ChatsState.initial() : this();

  @visibleForTesting
  const ChatsState.test({
    this.selectedTab = ChatsTab.active,
    this.activeFeed = const ChatsFeedState(hasLoaded: true),
    this.archivedFeed = const ChatsFeedState(),
    this.unreadTotal = 0,
    this.isPolling = false,
    this.errorMessage,
  });

  final ChatsTab selectedTab;
  final ChatsFeedState activeFeed;
  final ChatsFeedState archivedFeed;
  final int unreadTotal;
  final bool isPolling;
  final String? errorMessage;

  ChatsFeedState feedFor(ChatsTab tab) {
    return tab == ChatsTab.active ? activeFeed : archivedFeed;
  }

  ChatsState withFeed(ChatsTab tab, ChatsFeedState feed) {
    return tab == ChatsTab.active
        ? copyWith(activeFeed: feed)
        : copyWith(archivedFeed: feed);
  }

  ChatsState copyWith({
    ChatsTab? selectedTab,
    ChatsFeedState? activeFeed,
    ChatsFeedState? archivedFeed,
    int? unreadTotal,
    bool? isPolling,
    Object? errorMessage = _unsetChatsError,
    bool clearErrorMessage = false,
  }) {
    return ChatsState(
      selectedTab: selectedTab ?? this.selectedTab,
      activeFeed: activeFeed ?? this.activeFeed,
      archivedFeed: archivedFeed ?? this.archivedFeed,
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
    selectedTab,
    activeFeed,
    archivedFeed,
    unreadTotal,
    isPolling,
    errorMessage,
  ];
}
