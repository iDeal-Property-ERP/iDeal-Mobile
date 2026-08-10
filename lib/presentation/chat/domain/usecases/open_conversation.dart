import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class OpenConversation
    with UseCaseWithParams<ChatConversation, OpenConversationParams> {
  const OpenConversation(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversation> call(OpenConversationParams params) {
    return _repository.openConversation(listingId: params.listingId);
  }
}

class OpenConversationParams extends Equatable {
  const OpenConversationParams({required this.listingId});

  final int listingId;

  @override
  List<Object> get props => [listingId];
}
