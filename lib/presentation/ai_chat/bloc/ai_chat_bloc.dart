import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/ai_chat/bloc/ai_chat_event.dart';
import 'package:ideal_mobile/presentation/ai_chat/bloc/ai_chat_state.dart';
import 'package:ideal_mobile/presentation/ai_chat/model/ai_chat_message.dart';
import 'package:ideal_mobile/services/ai/gemini_constants.dart';
import 'package:ideal_mobile/services/ai/gemini_service.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  AiChatBloc({
    required GeminiService geminiService,
    required AppLocalizations localizations,
  }) : _geminiService = geminiService,
       _localizations = localizations,
       super(const AiChatState.initial()) {
    _setupEventListeners();
  }

  final GeminiService _geminiService;
  final AppLocalizations _localizations;
  StreamSubscription<String>? _streamSubscription;
  GeminiChatSession? _chatSession;

  void _setupEventListeners() {
    on<SendMessageEvent>(_onSendMessageEvent);
    on<StreamResponseChunkEvent>(_onStreamResponseChunkEvent);
    on<StreamResponseCompleteEvent>(_onStreamResponseCompleteEvent);
    on<StreamResponseErrorEvent>(_onStreamResponseErrorEvent);
    on<StopGenerationEvent>(_onStopGenerationEvent);
    on<ClearChatEvent>(_onClearChatEvent);
  }

  GeminiChatSession _getOrCreateSession() {
    if (_chatSession != null) return _chatSession!;
    final systemInstruction =
        '${GeminiConstants.aiChatSystemInstruction}\n\n${_buildAppContext()}';
    _chatSession = _geminiService.createChatSession(systemInstruction);
    return _chatSession!;
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSendMessageEvent(
    SendMessageEvent event,
    Emitter<AiChatState> emit,
  ) async {
    if (state.isGenerating) return;

    final userMessage = AiChatMessage(
      role: AiChatRole.user,
      content: event.message,
      timestamp: DateTime.now(),
    );

    final assistantMessage = AiChatMessage(
      role: AiChatRole.assistant,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage, assistantMessage],
        isGenerating: true,
        errorMessage: null,
      ),
    );

    try {
      final session = _getOrCreateSession();
      await _streamSubscription?.cancel();
      _streamSubscription = session
          .sendMessage(event.message)
          .listen(
            (chunk) => add(StreamResponseChunkEvent(chunk: chunk)),
            onDone: () => add(const StreamResponseCompleteEvent()),
            onError: (error) =>
                add(StreamResponseErrorEvent(errorMessage: error.toString())),
          );
    } catch (e) {
      add(StreamResponseErrorEvent(errorMessage: e.toString()));
    }
  }

  void _onStreamResponseChunkEvent(
    StreamResponseChunkEvent event,
    Emitter<AiChatState> emit,
  ) {
    if (state.messages.isEmpty) return;

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    final lastMessage = updatedMessages.last;

    updatedMessages[updatedMessages.length - 1] = lastMessage.copyWith(
      content: lastMessage.content + event.chunk,
    );

    emit(state.copyWith(messages: updatedMessages));
  }

  void _onStreamResponseCompleteEvent(
    StreamResponseCompleteEvent event,
    Emitter<AiChatState> emit,
  ) {
    if (state.messages.isEmpty) return;

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    final lastMessage = updatedMessages.last;

    if (lastMessage.content.trim().isEmpty) {
      updatedMessages.removeLast();
      emit(
        state.copyWith(
          messages: updatedMessages,
          isGenerating: false,
          errorMessage: _localizations.ai_chat_error_no_response,
        ),
      );
      return;
    }

    updatedMessages[updatedMessages.length - 1] = lastMessage.copyWith(
      isStreaming: false,
    );

    emit(state.copyWith(messages: updatedMessages, isGenerating: false));
  }

  void _onStreamResponseErrorEvent(
    StreamResponseErrorEvent event,
    Emitter<AiChatState> emit,
  ) {
    final userFriendlyMessage = _parseErrorMessage(event.errorMessage);

    if (state.messages.isNotEmpty) {
      final updatedMessages = List<AiChatMessage>.from(state.messages);
      updatedMessages.removeLast();
      emit(
        state.copyWith(
          messages: updatedMessages,
          isGenerating: false,
          errorMessage: userFriendlyMessage,
        ),
      );
    } else {
      emit(
        state.copyWith(isGenerating: false, errorMessage: userFriendlyMessage),
      );
    }
  }

  String _parseErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('quota') || lowerError.contains('429')) {
      return _localizations.ai_chat_error_quota;
    }
    if (lowerError.contains('timeout')) {
      return _localizations.ai_chat_error_timeout;
    }
    if (lowerError.contains('network') ||
        lowerError.contains('socket') ||
        lowerError.contains('connection')) {
      return _localizations.ai_chat_error_network;
    }
    return _localizations.ai_chat_error_generic;
  }

  void _onStopGenerationEvent(
    StopGenerationEvent event,
    Emitter<AiChatState> emit,
  ) {
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (state.messages.isEmpty) return;

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    final lastMessage = updatedMessages.last;

    if (!lastMessage.isUser) {
      if (lastMessage.content.trim().isEmpty) {
        updatedMessages.removeLast();
      } else {
        updatedMessages[updatedMessages.length - 1] = lastMessage.copyWith(
          isStreaming: false,
        );
      }
    }

    emit(state.copyWith(messages: updatedMessages, isGenerating: false));
  }

  void _onClearChatEvent(ClearChatEvent event, Emitter<AiChatState> emit) {
    _streamSubscription?.cancel();
    _chatSession = null;
    emit(const AiChatState.initial());
  }

  String _buildAppContext() {
    return '''
=== APP FEATURES ===
- Home: Browse and filter rental listings
- Listings: View property photos, amenities, location, and availability
- Chats: Message iDeal management about a listing
- Profile: View and edit profile details and settings
- Notifications: Review account and listing updates
- Settings: Theme, password, and biometric authentication
- Contact Us: Submit queries with attachments
- Feedback: Submit bug reports, suggestions, and compliments''';
  }
}
