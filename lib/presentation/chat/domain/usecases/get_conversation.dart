import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetConversation
    with UseCaseWithParams<ChatConversation, GetConversationParams> {
  const GetConversation(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversation> call(GetConversationParams params) {
    return _repository.getConversation(id: params.conversationId);
  }
}

class GetConversationParams extends Equatable {
  const GetConversationParams({required this.conversationId});

  final int conversationId;

  @override
  List<Object> get props => [conversationId];
}
