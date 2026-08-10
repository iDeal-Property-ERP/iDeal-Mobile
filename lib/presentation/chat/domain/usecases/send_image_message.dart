import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SendImageMessage
    with UseCaseWithParams<ChatMessage, SendImageMessageParams> {
  const SendImageMessage(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatMessage> call(SendImageMessageParams params) {
    return _repository.sendImageMessage(
      conversationId: params.conversationId,
      image: params.image,
      clientId: params.clientId,
    );
  }
}

class SendImageMessageParams extends Equatable {
  const SendImageMessageParams({
    required this.conversationId,
    required this.image,
    required this.clientId,
  });

  final int conversationId;
  final File image;
  final String clientId;

  @override
  List<Object> get props => [conversationId, image, clientId];
}
