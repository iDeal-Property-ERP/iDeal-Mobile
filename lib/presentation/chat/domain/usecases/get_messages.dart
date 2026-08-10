import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetMessages with UseCaseWithParams<ChatMessagesPage, GetMessagesParams> {
  const GetMessages(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatMessagesPage> call(GetMessagesParams params) {
    return _repository.getMessages(
      conversationId: params.conversationId,
      afterId: params.afterId,
      beforeId: params.beforeId,
      limit: params.limit,
    );
  }
}

class GetMessagesParams extends Equatable {
  const GetMessagesParams({
    required this.conversationId,
    this.afterId,
    this.beforeId,
    this.limit = 50,
  });

  final int conversationId;
  final int? afterId;
  final int? beforeId;
  final int limit;

  @override
  List<Object?> get props => [conversationId, afterId, beforeId, limit];
}
