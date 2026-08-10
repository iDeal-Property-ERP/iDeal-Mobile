import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
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
    _setupEventListeners();
  }

  final GetConversations _getConversations;
  final GetChatSummary _getChatSummary;
  final SetConversationArchived _setConversationArchived;
  final SetConversationMuted _setConversationMuted;
  final ReportConversation _reportConversation;
  final DeleteConversation _deleteConversation;

  Timer? _pollTimer;
  bool _pollInFlight = false;
  bool _started = false;
  bool _foreground = true;
  int _consecutiveFailures = 0;
  DateTime? _summarySince;

  void _setupEventListeners() {
    on<ChatsStarted>(_onStarted);
    on<ChatsStopped>(_onStopped);
    on<ChatsLoadRequested>(_onLoadRequested);
    on<ChatsRefreshRequested>(_onRefreshRequested);
    on<ChatsArchivedToggled>(_onArchivedToggled);
    on<ChatsPollTicked>(_onPollTicked);
    on<ChatsLifecycleChanged>(_onLifecycleChanged);
    on<ChatsArchiveToggled>(_onArchiveToggled);
    on<ChatsMuteToggled>(_onMuteToggled);
    on<ChatsConversationReported>(_onReported);
    on<ChatsConversationDeleted>(_onDeleted);
  }

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
    await _loadConversations(archived: false, emit: emit);
    if (_started && _foreground) _startPolling();
  }

  void _onStopped(ChatsStopped event, Emitter<ChatsState> emit) {
    _started = false;
    _stopPolling();
    emit(state.copyWith(isPolling: false));
  }

  Future<void> _onLoadRequested(
    ChatsLoadRequested event,
    Emitter<ChatsState> emit,
  ) {
    return _loadConversations(archived: false, emit: emit);
  }

  Future<void> _onRefreshRequested(
    ChatsRefreshRequested event,
    Emitter<ChatsState> emit,
  ) async {
    _consecutiveFailures = 0;
    await _loadConversations(archived: false, emit: emit);
    if (state.archivedLoaded) {
      await _loadConversations(archived: true, emit: emit);
    }
    if (_started && _foreground) _startPolling();
  }

  Future<void> _onArchivedToggled(
    ChatsArchivedToggled event,
    Emitter<ChatsState> emit,
  ) async {
    final shouldExpand = !state.archivedExpanded;
    emit(state.copyWith(archivedExpanded: shouldExpand));
    if (shouldExpand && !state.archivedLoaded) {
      emit(state.copyWith(isLoadingArchived: true, clearErrorMessage: true));
      await _loadConversations(archived: true, emit: emit);
    }
  }

  Future<void> _onPollTicked(
    ChatsPollTicked event,
    Emitter<ChatsState> emit,
  ) async {
    if (!_started || !_foreground || _pollInFlight) return;
    _pollInFlight = true;
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
      await _loadConversations(archived: false, emit: emit);
      if (state.archivedLoaded) {
        await _loadConversations(archived: true, emit: emit);
      }
    }
    _pollInFlight = false;
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

  Future<void> _loadConversations({
    required bool archived,
    required Emitter<ChatsState> emit,
  }) async {
    if (!archived) {
      emit(
        state.copyWith(
          status: state.activeItems.isEmpty
              ? ChatsStatus.loading
              : state.status,
          clearErrorMessage: true,
        ),
      );
    }
    final result = await _getConversations(
      GetConversationsParams(archived: archived),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: archived ? state.status : ChatsStatus.failure,
          isLoadingArchived: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: archived ? state.status : ChatsStatus.loaded,
          activeItems: archived ? null : page.items,
          archivedItems: archived ? page.items : null,
          archivedLoaded: archived ? true : state.archivedLoaded,
          isLoadingArchived: false,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onArchiveToggled(
    ChatsArchiveToggled event,
    Emitter<ChatsState> emit,
  ) async {
    final originalActive = state.activeItems;
    final originalArchived = state.archivedItems;
    final item = _findConversation(event.conversationId);
    if (item == null) return;
    final updated = item.copyWith(isArchived: event.archived);
    emit(
      state.copyWith(
        activeItems: event.archived
            ? _without(originalActive, item.id)
            : _upsert(originalActive, updated),
        archivedItems: event.archived
            ? _upsert(originalArchived, updated)
            : _without(originalArchived, item.id),
      ),
    );
    final result = await _setConversationArchived(
      SetConversationArchivedParams(
        conversationId: event.conversationId,
        value: event.archived,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          activeItems: originalActive,
          archivedItems: originalArchived,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onMuteToggled(
    ChatsMuteToggled event,
    Emitter<ChatsState> emit,
  ) async {
    final originalActive = state.activeItems;
    final originalArchived = state.archivedItems;
    if (_findConversation(event.conversationId) == null) return;
    emit(
      state.copyWith(
        activeItems: _replaceMute(originalActive, event),
        archivedItems: _replaceMute(originalArchived, event),
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
          activeItems: originalActive,
          archivedItems: originalArchived,
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
    final originalActive = state.activeItems;
    final originalArchived = state.archivedItems;
    if (_findConversation(event.conversationId) == null) return;
    emit(
      state.copyWith(
        activeItems: _without(originalActive, event.conversationId),
        archivedItems: _without(originalArchived, event.conversationId),
      ),
    );
    final result = await _deleteConversation(
      DeleteConversationParams(conversationId: event.conversationId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          activeItems: originalActive,
          archivedItems: originalArchived,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {},
    );
  }

  ChatConversation? _findConversation(int id) {
    for (final item in [...state.activeItems, ...state.archivedItems]) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<ChatConversation> _without(List<ChatConversation> items, int id) {
    return items.where((item) => item.id != id).toList(growable: false);
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

  List<ChatConversation> _replaceMute(
    List<ChatConversation> items,
    ChatsMuteToggled event,
  ) {
    return items
        .map(
          (item) => item.id == event.conversationId
              ? item.copyWith(isMuted: event.muted)
              : item,
        )
        .toList(growable: false);
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
