import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SetConversationMuted
    with UseCaseWithParams<ChatConversationState, SetConversationMutedParams> {
  const SetConversationMuted(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversationState> call(SetConversationMutedParams params) {
    return _repository.setConversationMuted(
      conversationId: params.conversationId,
      value: params.value,
    );
  }
}

class SetConversationMutedParams extends Equatable {
  const SetConversationMutedParams({
    required this.conversationId,
    required this.value,
  });

  final int conversationId;
  final bool value;

  @override
  List<Object> get props => [conversationId, value];
}
