import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class MarkConversationRead
    with UseCaseWithParams<ChatConversationState, MarkConversationReadParams> {
  const MarkConversationRead(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversationState> call(MarkConversationReadParams params) {
    return _repository.markConversationRead(
      conversationId: params.conversationId,
      upToMessageId: params.upToMessageId,
    );
  }
}

class MarkConversationReadParams extends Equatable {
  const MarkConversationReadParams({
    required this.conversationId,
    this.upToMessageId,
  });

  final int conversationId;
  final int? upToMessageId;

  @override
  List<Object?> get props => [conversationId, upToMessageId];
}
