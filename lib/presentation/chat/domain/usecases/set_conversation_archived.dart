import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SetConversationArchived
    with
        UseCaseWithParams<
          ChatConversationState,
          SetConversationArchivedParams
        > {
  const SetConversationArchived(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversationState> call(
    SetConversationArchivedParams params,
  ) {
    return _repository.setConversationArchived(
      conversationId: params.conversationId,
      value: params.value,
    );
  }
}

class SetConversationArchivedParams extends Equatable {
  const SetConversationArchivedParams({
    required this.conversationId,
    required this.value,
  });

  final int conversationId;
  final bool value;

  @override
  List<Object> get props => [conversationId, value];
}
