import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/delete_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversations.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc({
    GetConversations? getConversations,
    GetChatSummary? getChatSummary,
    SetConversationArchived? setConversationArchived,
    SetConversationMuted? setConversationMuted,
    ReportConversation? reportConversation,
    DeleteConversation? deleteConversation,
  }) : _getConversations = getConversations ?? sl<GetConversations>(),
       _getChatSummary = getChatSummary ?? sl<GetChatSummary>(),
       _setConversationArchived =
           setConversationArchived ?? sl<SetConversationArchived>(),
       _setConversationMuted =
           setConversationMuted ?? sl<SetConversationMuted>(),
       _reportConversation = reportConversation ?? sl<ReportConversation>(),
       _deleteConversation = deleteConversation ?? sl<DeleteConversation>(),
       super(const ChatsState.initial()) {
    on<ChatsStarted>(_onStarted);
    on<ChatsStopped>(_onStopped);
    on<ChatsTabSelected>(_onTabSelected);
    on<ChatsRefreshRequested>(_onRefreshRequested);
    on<ChatsLoadMoreRequested>(_onLoadMoreRequested);
    on<ChatsPollTicked>(_onPollTicked);
    on<ChatsLifecycleChanged>(_onLifecycleChanged);
    on<ChatsArchiveToggled>(_onArchiveToggled);
    on<ChatsMuteToggled>(_onMuteToggled);
    on<ChatsConversationReported>(_onReported);
    on<ChatsConversationDeleted>(_onDeleted);
  }

  final GetConversations _getConversations;
  final GetChatSummary _getChatSummary;
  final SetConversationArchived _setConversationArchived;
  final SetConversationMuted _setConversationMuted;
  final ReportConversation _reportConversation;
  final DeleteConversation _deleteConversation;

  final Map<ChatsTab, int> _requestGenerations = {
    ChatsTab.active: 0,
    ChatsTab.archived: 0,
  };
  Timer? _pollTimer;
  bool _pollInFlight = false;
  bool _started = false;
  bool _foreground = true;
  int _consecutiveFailures = 0;
  DateTime? _summarySince;

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }

  Future<void> _onStarted(ChatsStarted event, Emitter<ChatsState> emit) async {
    if (_started) return;
    _started = true;
    _foreground = true;
    _consecutiveFailures = 0;
    if (!state.activeFeed.hasLoaded) {
      await _loadFirstPage(ChatsTab.active, emit);
    }
    if (_started && _foreground) _startPolling();
  }

  void _onStopped(ChatsStopped event, Emitter<ChatsState> emit) {
    _started = false;
    _stopPolling();
    emit(state.copyWith(isPolling: false));
  }

  Future<void> _onTabSelected(
    ChatsTabSelected event,
    Emitter<ChatsState> emit,
  ) async {
    if (state.selectedTab != event.tab) {
      emit(state.copyWith(selectedTab: event.tab));
    }
    if (!state.feedFor(event.tab).hasLoaded) {
      await _loadFirstPage(event.tab, emit);
    }
  }

  Future<void> _onRefreshRequested(
    ChatsRefreshRequested event,
    Emitter<ChatsState> emit,
  ) async {
    _consecutiveFailures = 0;
    await _loadFirstPage(event.tab ?? state.selectedTab, emit);
    if (_started && _foreground) _startPolling();
  }

  Future<void> _onLoadMoreRequested(
    ChatsLoadMoreRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final feed = state.feedFor(event.tab);
    if (!feed.hasLoaded ||
        feed.hasReachedMax ||
        feed.isLoading ||
        feed.isLoadingMore) {
      return;
    }

    final nextPage = feed.page + 1;
    final generation = _nextGeneration(event.tab);
    emit(
      state.withFeed(
        event.tab,
        feed.copyWith(
          isLoadingMore: true,
          clearErrorMessage: true,
          clearFailedPage: true,
        ),
      ),
    );

    final result = await _fetchPage(event.tab, nextPage);
    if (!_isCurrent(event.tab, generation)) return;
    final currentFeed = state.feedFor(event.tab);
    if (result.errorMessage != null) {
      emit(
        state.withFeed(
          event.tab,
          currentFeed.copyWith(
            isLoadingMore: false,
            errorMessage: result.errorMessage,
            failedPage: nextPage,
          ),
        ),
      );
      return;
    }

    final page = result.page!;
    if (page.pageNumber != nextPage) {
      emit(
        state.withFeed(
          event.tab,
          currentFeed.copyWith(
            isLoadingMore: false,
            errorMessage: 'chat_page_out_of_date',
            failedPage: nextPage,
          ),
        ),
      );
      return;
    }

    emit(
      state.withFeed(
        event.tab,
        _feedFromPage(
          page,
          items: _dedupe([...currentFeed.items, ...page.items]),
        ),
      ),
    );
  }

  Future<void> _onPollTicked(
    ChatsPollTicked event,
    Emitter<ChatsState> emit,
  ) async {
    if (!_started || !_foreground || _pollInFlight) return;
    _pollInFlight = true;
    emit(state.copyWith(isPolling: true));
    final result = await _getChatSummary(
      GetChatSummaryParams(since: _summarySince),
    );
    if (isClosed) {
      _pollInFlight = false;
      return;
    }
    var shouldReload = false;
    result.fold(
      (failure) {
        _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 5).toInt();
        emit(state.copyWith(errorMessage: failure.errorMessage));
      },
      (summary) {
        _consecutiveFailures = 0;
        _summarySince = summary.serverTime;
        shouldReload =
            summary.changedConversationIds.isNotEmpty ||
            summary.totalUnread != state.unreadTotal;
        emit(
          state.copyWith(
            unreadTotal: summary.totalUnread,
            clearErrorMessage: true,
          ),
        );
      },
    );
    if (shouldReload) {
      await _reloadLoadedPrefix(ChatsTab.active, emit);
      if (state.archivedFeed.hasLoaded) {
        await _reloadLoadedPrefix(ChatsTab.archived, emit);
      }
    }
    _pollInFlight = false;
    emit(state.copyWith(isPolling: false));
    if (_started && _foreground) _startPolling();
  }

  void _onLifecycleChanged(
    ChatsLifecycleChanged event,
    Emitter<ChatsState> emit,
  ) {
    switch (event.lifecycleState) {
      case AppLifecycleState.resumed:
        _foreground = true;
        if (_started) {
          _startPolling();
          add(const ChatsPollTicked());
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _foreground = false;
        _stopPolling();
    }
  }

  Future<void> _loadFirstPage(ChatsTab tab, Emitter<ChatsState> emit) async {
    final generation = _nextGeneration(tab);
    final feed = state.feedFor(tab);
    emit(
      state.withFeed(
        tab,
        feed.copyWith(
          isLoading: true,
          isLoadingMore: false,
          clearErrorMessage: true,
          clearFailedPage: true,
        ),
      ),
    );

    final result = await _fetchPage(tab, 1);
    if (!_isCurrent(tab, generation)) return;
    final currentFeed = state.feedFor(tab);
    if (result.errorMessage != null) {
      emit(
        state.withFeed(
          tab,
          currentFeed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: result.errorMessage,
            failedPage: 1,
          ),
        ),
      );
      return;
    }

    final page = result.page!;
    if (page.pageNumber != 1) {
      emit(
        state.withFeed(
          tab,
          currentFeed.copyWith(
            isLoading: false,
            errorMessage: 'chat_page_out_of_date',
            failedPage: 1,
          ),
        ),
      );
      return;
    }
    emit(state.withFeed(tab, _feedFromPage(page)));
  }

  Future<void> _reloadLoadedPrefix(
    ChatsTab tab,
    Emitter<ChatsState> emit,
  ) async {
    final existing = state.feedFor(tab);
    if (!existing.hasLoaded) return;

    final targetPage = existing.page < 1 ? 1 : existing.page;
    final generation = _nextGeneration(tab);
    emit(
      state.withFeed(
        tab,
        existing.copyWith(
          isLoading: true,
          isLoadingMore: false,
          clearErrorMessage: true,
          clearFailedPage: true,
        ),
      ),
    );

    final items = <ChatConversation>[];
    ChatConversationsPage? lastPage;
    for (var requestedPage = 1; requestedPage <= targetPage; requestedPage++) {
      final result = await _fetchPage(tab, requestedPage);
      if (!_isCurrent(tab, generation)) return;
      if (result.errorMessage != null) {
        final currentFeed = state.feedFor(tab);
        emit(
          state.withFeed(
            tab,
            currentFeed.copyWith(
              isLoading: false,
              errorMessage: result.errorMessage,
              failedPage: requestedPage,
            ),
          ),
        );
        return;
      }

      final page = result.page!;
      if (page.pageNumber != requestedPage) {
        final currentFeed = state.feedFor(tab);
        emit(
          state.withFeed(
            tab,
            currentFeed.copyWith(
              isLoading: false,
              errorMessage: 'chat_page_out_of_date',
              failedPage: requestedPage,
            ),
          ),
        );
        return;
      }
      lastPage = page;
      items.addAll(page.items);
      if (!page.hasMore) break;
    }

    if (lastPage == null) return;
    emit(state.withFeed(tab, _feedFromPage(lastPage, items: _dedupe(items))));
  }

  Future<_PageResult> _fetchPage(ChatsTab tab, int page) async {
    ChatConversationsPage? response;
    String? errorMessage;
    final result = await _getConversations(
      GetConversationsParams(archived: tab.isArchived, page: page),
    );
    result.fold(
      (failure) => errorMessage = failure.errorMessage,
      (value) => response = value,
    );
    return _PageResult(page: response, errorMessage: errorMessage);
  }

  ChatsFeedState _feedFromPage(
    ChatConversationsPage page, {
    List<ChatConversation>? items,
  }) {
    return ChatsFeedState(
      items: items ?? _dedupe(page.items),
      page: page.pageNumber,
      numPages: page.numPages,
      count: page.count,
      hasLoaded: true,
      hasReachedMax: !page.hasMore,
    );
  }

  Future<void> _onArchiveToggled(
    ChatsArchiveToggled event,
    Emitter<ChatsState> emit,
  ) async {
    final originalActive = state.activeFeed;
    final originalArchived = state.archivedFeed;
    final item = _findConversation(event.conversationId);
    if (item == null) return;

    final updated = item.copyWith(isArchived: event.archived);
    final sourceTab = event.archived ? ChatsTab.active : ChatsTab.archived;
    final targetTab = event.archived ? ChatsTab.archived : ChatsTab.active;
    var nextState = state.withFeed(
      sourceTab,
      _removeFromFeed(state.feedFor(sourceTab), item.id),
    );
    nextState = nextState.withFeed(
      targetTab,
      _insertIntoFeed(nextState.feedFor(targetTab), updated),
    );
    emit(nextState);

    final result = await _setConversationArchived(
      SetConversationArchivedParams(
        conversationId: event.conversationId,
        value: event.archived,
      ),
    );
    String? errorMessage;
    result.fold((failure) => errorMessage = failure.errorMessage, (_) {});
    if (errorMessage != null) {
      emit(
        state.copyWith(
          activeFeed: originalActive,
          archivedFeed: originalArchived,
          errorMessage: errorMessage,
        ),
      );
      return;
    }

    await _reloadLoadedPrefix(ChatsTab.active, emit);
    if (state.archivedFeed.hasLoaded) {
      await _reloadLoadedPrefix(ChatsTab.archived, emit);
    }
  }

  Future<void> _onMuteToggled(
    ChatsMuteToggled event,
    Emitter<ChatsState> emit,
  ) async {
    final originalActive = state.activeFeed;
    final originalArchived = state.archivedFeed;
    if (_findConversation(event.conversationId) == null) return;
    emit(
      state.copyWith(
        activeFeed: _replaceMute(originalActive, event),
        archivedFeed: _replaceMute(originalArchived, event),
      ),
    );
    final result = await _setConversationMuted(
      SetConversationMutedParams(
        conversationId: event.conversationId,
        value: event.muted,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          activeFeed: originalActive,
          archivedFeed: originalArchived,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onReported(
    ChatsConversationReported event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await _reportConversation(
      ReportConversationParams(
        conversationId: event.conversationId,
        reason: event.reason,
        note: event.note,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (_) {},
    );
  }

  Future<void> _onDeleted(
    ChatsConversationDeleted event,
    Emitter<ChatsState> emit,
  ) async {
    final originalActive = state.activeFeed;
    final originalArchived = state.archivedFeed;
    if (_findConversation(event.conversationId) == null) return;
    emit(
      state.copyWith(
        activeFeed: _removeFromFeed(originalActive, event.conversationId),
        archivedFeed: _removeFromFeed(originalArchived, event.conversationId),
      ),
    );
    final result = await _deleteConversation(
      DeleteConversationParams(conversationId: event.conversationId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          activeFeed: originalActive,
          archivedFeed: originalArchived,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {},
    );
  }

  int _nextGeneration(ChatsTab tab) {
    final generation = (_requestGenerations[tab] ?? 0) + 1;
    _requestGenerations[tab] = generation;
    return generation;
  }

  bool _isCurrent(ChatsTab tab, int generation) {
    return !isClosed && _requestGenerations[tab] == generation;
  }

  ChatConversation? _findConversation(int id) {
    for (final item in [
      ...state.activeFeed.items,
      ...state.archivedFeed.items,
    ]) {
      if (item.id == id) return item;
    }
    return null;
  }

  ChatsFeedState _removeFromFeed(ChatsFeedState feed, int id) {
    final contained = feed.items.any((item) => item.id == id);
    if (!contained) return feed;
    return feed.copyWith(
      items: feed.items.where((item) => item.id != id).toList(growable: false),
      count: feed.count > 0 ? feed.count - 1 : 0,
    );
  }

  ChatsFeedState _insertIntoFeed(ChatsFeedState feed, ChatConversation value) {
    final alreadyContained = feed.items.any((item) => item.id == value.id);
    return feed.copyWith(
      items: _upsert(feed.items, value),
      count: alreadyContained ? feed.count : feed.count + 1,
    );
  }

  ChatsFeedState _replaceMute(ChatsFeedState feed, ChatsMuteToggled event) {
    return feed.copyWith(
      items: feed.items
          .map(
            (item) => item.id == event.conversationId
                ? item.copyWith(isMuted: event.muted)
                : item,
          )
          .toList(growable: false),
    );
  }

  List<ChatConversation> _upsert(
    List<ChatConversation> items,
    ChatConversation value,
  ) {
    final result = [...items];
    final index = result.indexWhere((item) => item.id == value.id);
    if (index == -1) {
      result.insert(0, value);
    } else {
      result[index] = value;
    }
    return result;
  }

  List<ChatConversation> _dedupe(List<ChatConversation> items) {
    final seenIds = <int>{};
    return [
      for (final item in items)
        if (seenIds.add(item.id)) item,
    ];
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!_started || !_foreground) return;
    final seconds = switch (_consecutiveFailures) {
      0 => 5,
      1 => 10,
      2 => 20,
      3 => 40,
      _ => 60,
    };
    _pollTimer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => add(const ChatsPollTicked()),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

class _PageResult {
  const _PageResult({this.page, this.errorMessage});

  final ChatConversationsPage? page;
  final String? errorMessage;
}
