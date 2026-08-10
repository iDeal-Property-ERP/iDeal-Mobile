import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/open_conversation.dart';

enum OpenConversationStatus { idle, loading, success, failure }

class OpenConversationState extends Equatable {
  const OpenConversationState({
    this.status = OpenConversationStatus.idle,
    this.conversationId,
    this.errorMessage,
  });

  final OpenConversationStatus status;
  final int? conversationId;
  final String? errorMessage;

  const OpenConversationState.initial()
    : status = OpenConversationStatus.idle,
      conversationId = null,
      errorMessage = null;

  @visibleForTesting
  const OpenConversationState.test({
    this.status = OpenConversationStatus.idle,
    this.conversationId,
    this.errorMessage,
  });

  OpenConversationState copyWith({
    OpenConversationStatus? status,
    int? conversationId,
    String? errorMessage,
  }) {
    return OpenConversationState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversationId, errorMessage];
}

class OpenConversationCubit extends Cubit<OpenConversationState> {
  OpenConversationCubit({OpenConversation? openConversation})
    : _openConversation = openConversation ?? sl<OpenConversation>(),
      super(const OpenConversationState.initial());

  final OpenConversation _openConversation;

  Future<void> open(int listingId) async {
    emit(const OpenConversationState(status: OpenConversationStatus.loading));
    final result = await _openConversation(
      OpenConversationParams(listingId: listingId),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        OpenConversationState(
          status: OpenConversationStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (conversation) => emit(
        OpenConversationState(
          status: OpenConversationStatus.success,
          conversationId: conversation.id,
        ),
      ),
    );
  }

  void reset() => emit(const OpenConversationState.initial());
}
