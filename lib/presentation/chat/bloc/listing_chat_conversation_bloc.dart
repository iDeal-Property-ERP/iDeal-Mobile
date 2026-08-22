import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_messages.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/mark_conversation_read.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_image_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_text_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';
import 'package:uuid/uuid.dart';

class ChatMessageMergeResult {
  const ChatMessageMergeResult({required this.messages, required this.pending});

  final List<ChatMessage> messages;
  final List<PendingChatMessage> pending;
}

ChatMessageMergeResult mergeChatMessages({
  required List<ChatMessage> existing,
  required List<PendingChatMessage> pending,
  required List<ChatMessage> incoming,
}) {
  final byId = <int, ChatMessage>{};
  final clientToId = <String, int>{};
  for (final message in existing) {
    final oldId = message.clientId == null
        ? null
        : clientToId[message.clientId!];
    if (oldId != null) byId.remove(oldId);
    byId[message.id] = message;
    if (message.clientId != null) {
      clientToId[message.clientId!] = message.id;
    }
  }

  final incomingClientIds = <String>{};
  for (final message in incoming) {
    final oldId = message.clientId == null
        ? null
        : clientToId[message.clientId!];
    if (oldId != null && oldId != message.id) byId.remove(oldId);
    byId[message.id] = message;
    if (message.clientId != null) {
      clientToId[message.clientId!] = message.id;
      incomingClientIds.add(message.clientId!);
    }
  }

  final mergedMessages = byId.values.toList(growable: false)
    ..sort((left, right) => left.id.compareTo(right.id));
  final remainingPending = pending
      .where((message) => !incomingClientIds.contains(message.clientId))
      .toList(growable: false);
  return ChatMessageMergeResult(
    messages: mergedMessages,
    pending: remainingPending,
  );
}

class ListingChatConversationBloc
    extends Bloc<ListingChatConversationEvent, ListingChatConversationState> {
  ListingChatConversationBloc({
    required int conversationId,
    ChatConversation? initialConversation,
    GetConversation? getConversation,
    GetMessages? getMessages,
    SendTextMessage? sendTextMessage,
    SendImageMessage? sendImageMessage,
    MarkConversationRead? markConversationRead,
    SetConversationArchived? setConversationArchived,
    SetConversationMuted? setConversationMuted,
    ReportConversation? reportConversation,
  }) : _conversationId = conversationId,
       _getConversation = getConversation ?? sl<GetConversation>(),
       _getMessages = getMessages ?? sl<GetMessages>(),
       _sendTextMessage = sendTextMessage ?? sl<SendTextMessage>(),
       _sendImageMessage = sendImageMessage ?? sl<SendImageMessage>(),
       _markConversationRead =
           markConversationRead ?? sl<MarkConversationRead>(),
       _setConversationArchived =
           setConversationArchived ?? sl<SetConversationArchived>(),
       _setConversationMuted =
           setConversationMuted ?? sl<SetConversationMuted>(),
       _reportConversation = reportConversation ?? sl<ReportConversation>(),
       super(
         initialConversation?.id == conversationId
             ? const ListingChatConversationState.initial()
                   .withConversationSeed(initialConversation!)
             : const ListingChatConversationState.initial().copyWith(
                 conversationId: conversationId,
               ),
       ) {
    _setupEventListeners();
  }

  final int _conversationId;
  final GetConversation _getConversation;
  final GetMessages _getMessages;
  final SendTextMessage _sendTextMessage;
  final SendImageMessage _sendImageMessage;
  final MarkConversationRead _markConversationRead;
  final SetConversationArchived _setConversationArchived;
  final SetConversationMuted _setConversationMuted;
  final ReportConversation _reportConversation;

  Timer? _pollTimer;
  bool _pollInFlight = false;
  bool _readInFlight = false;
  bool _started = false;
  bool _initialMessagesLoaded = false;
  bool _initialLoadFinalized = false;
  bool _foreground = true;
  int _consecutiveFailures = 0;
  DateTime? _lastTrafficAt;
  DateTime? _lastReadAt;

  void _setupEventListeners() {
    on<ChatConversationStarted>(_onStarted);
    on<ChatConversationMetadataLoaded>(_onMetadataLoaded);
    on<ChatConversationInitialMessagesLoaded>(_onInitialMessagesLoaded);
    on<ChatConversationStopped>(_onStopped);
    on<ChatConversationPollTicked>(_onPollTicked);
    on<ChatConversationRefreshRequested>(_onRefreshRequested);
    on<ChatConversationLoadOlder>(_onLoadOlder);
    on<ChatConversationLifecycleChanged>(_onLifecycleChanged);
    on<ChatConversationDraftChanged>(_onDraftChanged);
    on<ChatConversationTextSent>(_onTextSent);
    on<ChatConversationImageSent>(_onImageSent);
    on<ChatConversationRetrySent>(_onRetrySent);
    on<ChatConversationArchiveToggled>(_onArchiveToggled);
    on<ChatConversationMuteToggled>(_onMuteToggled);
    on<ChatConversationReportRequested>(_onReportRequested);
  }

  @override
  Future<void> close() {
    _started = false;
    _stopPolling();
    return super.close();
  }

  Future<void> _onStarted(
    ChatConversationStarted event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (_started) return;
    _started = true;
    _initialMessagesLoaded = false;
    _initialLoadFinalized = false;
    _foreground = true;
    _consecutiveFailures = 0;
    emit(
      state.copyWith(
        status: ListingChatConversationStatus.loading,
        clearErrorMessage: true,
      ),
    );
    // Start both reads before awaiting either. Metadata and the message area
    // can then reveal independently instead of serializing two round trips.
    unawaited(
      _getConversation(
        GetConversationParams(conversationId: _conversationId),
      ).then((result) => add(ChatConversationMetadataLoaded(result))),
    );
    unawaited(
      _getMessages(
        GetMessagesParams(conversationId: _conversationId),
      ).then((result) => add(ChatConversationInitialMessagesLoaded(result))),
    );
  }

  Future<void> _onMetadataLoaded(
    ChatConversationMetadataLoaded event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final conversationResult = event.result;
    var conversationLoaded = false;
    conversationResult.fold(
      (failure) => emit(
        state.copyWith(
          status: state.messages.isEmpty
              ? ListingChatConversationStatus.failure
              : ListingChatConversationStatus.loaded,
          errorMessage: failure.errorMessage,
        ),
      ),
      (conversation) {
        conversationLoaded = true;
        emit(
          state.copyWith(
            conversationId: conversation.id,
            listing: conversation.listing,
            isReadOnly: conversation.isReadOnly,
            isBlocked: conversation.isBlocked,
            isArchived: conversation.isArchived,
            isMuted: conversation.isMuted,
            listingIsAvailable: conversation.listingIsAvailable,
            lastKnownMessageId: conversation.lastMessageId,
            peerLastReadMessageId: conversation.peerLastReadMessageId,
            metadataConfirmed: true,
            clearErrorMessage: true,
          ),
        );
      },
    );
    if (!conversationLoaded || isClosed) {
      _started = false;
      _stopPolling();
      return;
    }
    await _finishInitialLoad(emit);
  }

  Future<void> _onInitialMessagesLoaded(
    ChatConversationInitialMessagesLoaded event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    _loadMessagesResult(event.result, emit: emit);
    _initialMessagesLoaded = true;
    await _finishInitialLoad(emit);
  }

  Future<void> _finishInitialLoad(
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (_initialLoadFinalized ||
        !_initialMessagesLoaded ||
        !state.metadataConfirmed ||
        isClosed) {
      return;
    }
    _initialLoadFinalized = true;
    _lastTrafficAt = DateTime.now();
    await _markReadIfAllowed(force: true);
    if (_started && _foreground) _startPolling();
  }

  void _onStopped(
    ChatConversationStopped event,
    Emitter<ListingChatConversationState> emit,
  ) {
    _started = false;
    _stopPolling();
  }

  Future<void> _onPollTicked(
    ChatConversationPollTicked event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    await _pollNow(emit);
  }

  Future<void> _pollNow(Emitter<ListingChatConversationState> emit) async {
    if (!_started || !_foreground || _pollInFlight) return;
    if (_consecutiveFailures >= 5) return;
    _pollInFlight = true;
    final result = await _getMessages(
      GetMessagesParams(
        conversationId: _conversationId,
        afterId: state.lastKnownMessageId,
      ),
    );
    if (isClosed) {
      _pollInFlight = false;
      return;
    }
    ChatMessagesPage? successPage;
    result.fold(
      (failure) {
        _consecutiveFailures = (_consecutiveFailures + 1).clamp(0, 5).toInt();
        emit(state.copyWith(errorMessage: failure.errorMessage));
      },
      (page) {
        successPage = page;
      },
    );
    final page = successPage;
    if (page != null) {
      final oldIds = state.messages.map((message) => message.id).toSet();
      final hasNewStaffMessage = page.messages.any(
        (message) => !oldIds.contains(message.id) && !message.isMine,
      );
      _applyPage(page, emit);
      if (page.messages.isNotEmpty) _lastTrafficAt = DateTime.now();
      _consecutiveFailures = 0;
      if (hasNewStaffMessage) await _markReadIfAllowed();
    }
    _pollInFlight = false;
    if (_started && _foreground && _consecutiveFailures < 5) {
      _startPolling();
    } else if (_consecutiveFailures >= 5) {
      _stopPolling();
    }
  }

  Future<void> _onRefreshRequested(
    ChatConversationRefreshRequested event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (!_started) {
      add(const ChatConversationStarted());
      return;
    }
    _consecutiveFailures = 0;
    if (_started && _foreground) {
      _startPolling();
      await _pollNow(emit);
    }
  }

  Future<void> _onLoadOlder(
    ChatConversationLoadOlder event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (state.isLoadingOlder || !state.hasMoreOlder) return;
    final oldestId = state.messages.isEmpty ? null : state.messages.first.id;
    if (oldestId == null) return;
    emit(state.copyWith(isLoadingOlder: true, clearErrorMessage: true));
    final result = await _getMessages(
      GetMessagesParams(conversationId: _conversationId, beforeId: oldestId),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingOlder: false,
          errorMessage: failure.errorMessage,
        ),
      ),
      (page) {
        _applyPage(page, emit, isOlder: true);
        emit(state.copyWith(isLoadingOlder: false));
      },
    );
  }

  void _onLifecycleChanged(
    ChatConversationLifecycleChanged event,
    Emitter<ListingChatConversationState> emit,
  ) {
    switch (event.lifecycleState) {
      case AppLifecycleState.resumed:
        _foreground = true;
        if (_started) {
          _startPolling();
          add(const ChatConversationPollTicked());
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _foreground = false;
        _stopPolling();
    }
  }

  void _onDraftChanged(
    ChatConversationDraftChanged event,
    Emitter<ListingChatConversationState> emit,
  ) {
    emit(state.copyWith(draft: event.draft));
  }

  Future<void> _onTextSent(
    ChatConversationTextSent event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (!state.metadataConfirmed || state.isReadOnly || state.isSending) return;
    final text = (event.text ?? state.draft).trim();
    if (text.isEmpty) return;
    if (text.length > 1024) {
      emit(state.copyWith(errorMessage: 'chat_message_too_long'));
      return;
    }
    final clientId = const Uuid().v4();
    final pending = PendingChatMessage(
      clientId: clientId,
      text: text,
      localPath: null,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );
    emit(
      state.copyWith(
        pending: [...state.pending, pending],
        draft: '',
        isSending: true,
        clearErrorMessage: true,
      ),
    );
    await _sendText(pending, emit);
  }

  Future<void> _onImageSent(
    ChatConversationImageSent event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (!state.metadataConfirmed || state.isReadOnly || state.isSending) return;
    final file = File(event.path);
    if (!await file.exists()) {
      emit(state.copyWith(errorMessage: 'chat_image_unsupported_format'));
      return;
    }
    final extension = _extension(event.path);
    if (!_supportedImageExtensions.contains(extension)) {
      emit(state.copyWith(errorMessage: 'chat_image_unsupported_format'));
      return;
    }
    late final int fileSize;
    try {
      fileSize = await file.length();
    } on FileSystemException {
      emit(state.copyWith(errorMessage: 'chat_image_unsupported_format'));
      return;
    }
    if (fileSize > _maxImageBytes) {
      emit(state.copyWith(errorMessage: 'chat_image_too_large'));
      return;
    }
    final clientId = const Uuid().v4();
    final pending = PendingChatMessage(
      clientId: clientId,
      text: null,
      localPath: event.path,
      createdAt: DateTime.now(),
      status: ChatMessageStatus.sending,
    );
    emit(
      state.copyWith(
        pending: [...state.pending, pending],
        isSending: true,
        clearErrorMessage: true,
      ),
    );
    await _sendImage(pending, emit);
  }

  Future<void> _onRetrySent(
    ChatConversationRetrySent event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    if (!state.metadataConfirmed || state.isReadOnly || state.isSending) return;
    final pending = state.pending
        .where((item) => item.clientId == event.clientId)
        .firstOrNull;
    if (pending == null || pending.status != ChatMessageStatus.failed) {
      return;
    }
    final updated = pending.copyWith(status: ChatMessageStatus.sending);
    emit(
      state.copyWith(
        pending: _replacePending(updated),
        isSending: true,
        clearErrorMessage: true,
      ),
    );
    if (updated.isImage) {
      await _sendImage(updated, emit);
    } else {
      await _sendText(updated, emit);
    }
  }

  Future<void> _onArchiveToggled(
    ChatConversationArchiveToggled event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final previous = state.isArchived;
    emit(state.copyWith(isArchived: event.archived, clearErrorMessage: true));
    final result = await _setConversationArchived(
      SetConversationArchivedParams(
        conversationId: _conversationId,
        value: event.archived,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isArchived: previous,
          errorMessage: failure.errorMessage,
        ),
      ),
      (source) => emit(state.withConversationState(source)),
    );
  }

  Future<void> _onMuteToggled(
    ChatConversationMuteToggled event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final previous = state.isMuted;
    emit(state.copyWith(isMuted: event.muted, clearErrorMessage: true));
    final result = await _setConversationMuted(
      SetConversationMutedParams(
        conversationId: _conversationId,
        value: event.muted,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(isMuted: previous, errorMessage: failure.errorMessage),
      ),
      (source) => emit(state.withConversationState(source)),
    );
  }

  Future<void> _onReportRequested(
    ChatConversationReportRequested event,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final result = await _reportConversation(
      ReportConversationParams(
        conversationId: _conversationId,
        reason: event.reason,
        note: event.note,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (_) {},
    );
  }

  Future<void> _sendText(
    PendingChatMessage pending,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final result = await _sendTextMessage(
      SendTextMessageParams(
        conversationId: _conversationId,
        text: pending.text ?? '',
        clientId: pending.clientId,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => _markFailed(pending.clientId, failure.errorMessage, emit),
      (message) => _completeSend(message, emit),
    );
  }

  Future<void> _sendImage(
    PendingChatMessage pending,
    Emitter<ListingChatConversationState> emit,
  ) async {
    final path = pending.localPath;
    if (path == null) return;
    final result = await _sendImageMessage(
      SendImageMessageParams(
        conversationId: _conversationId,
        image: File(path),
        clientId: pending.clientId,
      ),
    );
    if (isClosed) return;
    result.fold(
      (failure) => _markFailed(pending.clientId, failure.errorMessage, emit),
      (message) => _completeSend(message, emit),
    );
  }

  void _markFailed(
    String clientId,
    String error,
    Emitter<ListingChatConversationState> emit,
  ) {
    final item = state.pending
        .where((value) => value.clientId == clientId)
        .firstOrNull;
    emit(
      state.copyWith(
        pending: item == null
            ? state.pending
            : _replacePending(item.copyWith(status: ChatMessageStatus.failed)),
        isSending: false,
        errorMessage: error,
      ),
    );
  }

  void _completeSend(
    ChatMessage message,
    Emitter<ListingChatConversationState> emit,
  ) {
    _lastTrafficAt = DateTime.now();
    _consecutiveFailures = 0;
    final merged = mergeChatMessages(
      existing: state.messages,
      pending: state.pending,
      incoming: [message],
    );
    final lastKnown = _maxKnown(state.lastKnownMessageId, message.id);
    emit(
      state.copyWith(
        messages: merged.messages,
        pending: merged.pending,
        lastKnownMessageId: lastKnown,
        isSending: false,
        status: ListingChatConversationStatus.loaded,
        clearErrorMessage: true,
      ),
    );
    if (_started && _foreground) _startPolling();
  }

  List<PendingChatMessage> _replacePending(PendingChatMessage value) {
    return state.pending
        .map((item) => item.clientId == value.clientId ? value : item)
        .toList(growable: false);
  }

  void _applyPage(
    ChatMessagesPage page,
    Emitter<ListingChatConversationState> emit, {
    bool isOlder = false,
  }) {
    final merged = mergeChatMessages(
      existing: state.messages,
      pending: state.pending,
      incoming: page.messages,
    );
    final latest = page.messages.fold<int?>(
      _maxKnown(state.lastKnownMessageId, page.conversation.lastMessageId),
      (current, message) => _maxKnown(current, message.id),
    );
    emit(
      state.copyWith(
        messages: merged.messages,
        pending: merged.pending,
        hasMoreOlder: isOlder ? page.hasMore : state.hasMoreOlder,
        status: ListingChatConversationStatus.loaded,
        lastKnownMessageId: latest,
        peerLastReadMessageId:
            page.conversation.peerLastReadMessageId ??
            state.peerLastReadMessageId,
        isReadOnly: page.conversation.isReadOnly,
        isBlocked: page.conversation.isBlocked,
        isArchived: page.conversation.isArchived,
        isMuted: page.conversation.isMuted,
        listingIsAvailable: page.conversation.listingIsAvailable,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _loadMessages({
    required Emitter<ListingChatConversationState> emit,
  }) async {
    final result = await _getMessages(
      GetMessagesParams(conversationId: _conversationId),
    );
    if (isClosed) return;
    _loadMessagesResult(result, emit: emit);
  }

  void _loadMessagesResult(
    Either<Failure, ChatMessagesPage> result, {
    required Emitter<ListingChatConversationState> emit,
  }) {
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ListingChatConversationStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (page) {
        _applyPage(page, emit, isOlder: true);
        emit(state.copyWith(hasMoreOlder: page.hasMore));
      },
    );
  }

  Future<void> _markReadIfAllowed({bool force = false}) async {
    if (!_foreground || _readInFlight) return;
    final lastRead = _lastReadAt;
    if (!force &&
        lastRead != null &&
        DateTime.now().difference(lastRead) < const Duration(seconds: 2)) {
      return;
    }
    _lastReadAt = DateTime.now();
    _readInFlight = true;
    final result = await _markConversationRead(
      MarkConversationReadParams(
        conversationId: _conversationId,
        upToMessageId: state.lastKnownMessageId,
      ),
    );
    _readInFlight = false;
    if (isClosed) return;
    result.fold((_) {}, (source) {
      emit(state.withConversationState(source));
    });
  }

  int? _maxKnown(int? first, int? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first > second ? first : second;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!_started || !_foreground || _consecutiveFailures >= 5) return;
    final period = _pollPeriod();
    _pollTimer = Timer.periodic(
      period,
      (_) => add(const ChatConversationPollTicked()),
    );
  }

  Duration _pollPeriod() {
    switch (_consecutiveFailures) {
      case 0:
        final traffic = _lastTrafficAt;
        if (traffic != null &&
            DateTime.now().difference(traffic) >= const Duration(seconds: 60)) {
          return const Duration(seconds: 2);
        }
        return const Duration(seconds: 1);
      case 1:
        return const Duration(seconds: 2);
      case 2:
        return const Duration(seconds: 5);
      default:
        return const Duration(seconds: 10);
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  static const _supportedImageExtensions = {
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
  };
  static const _maxImageBytes = 5 * 1024 * 1024;

  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot + 1).toLowerCase();
  }
}
