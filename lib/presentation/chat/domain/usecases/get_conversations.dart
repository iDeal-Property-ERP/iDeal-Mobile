import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetConversations
    with UseCaseWithParams<ChatConversationsPage, GetConversationsParams> {
  const GetConversations(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatConversationsPage> call(GetConversationsParams params) {
    return _repository.getConversations(
      archived: params.archived,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetConversationsParams extends Equatable {
  const GetConversationsParams({
    required this.archived,
    this.page = 1,
    this.perPage = 20,
  });

  final bool archived;
  final int page;
  final int perPage;

  @override
  List<Object> get props => [archived, page, perPage];
}
