import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class DeleteConversation
    with UseCaseWithParams<void, DeleteConversationParams> {
  const DeleteConversation(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultVoid call(DeleteConversationParams params) {
    return _repository.deleteConversation(
      conversationId: params.conversationId,
    );
  }
}

class DeleteConversationParams extends Equatable {
  const DeleteConversationParams({required this.conversationId});

  final int conversationId;

  @override
  List<Object> get props => [conversationId];
}
