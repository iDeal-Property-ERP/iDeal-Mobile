import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SendTextMessage
    with UseCaseWithParams<ChatMessage, SendTextMessageParams> {
  const SendTextMessage(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatMessage> call(SendTextMessageParams params) {
    return _repository.sendTextMessage(
      conversationId: params.conversationId,
      text: params.text,
      clientId: params.clientId,
    );
  }
}

class SendTextMessageParams extends Equatable {
  const SendTextMessageParams({
    required this.conversationId,
    required this.text,
    required this.clientId,
  });

  final int conversationId;
  final String text;
  final String clientId;

  @override
  List<Object> get props => [conversationId, text, clientId];
}
