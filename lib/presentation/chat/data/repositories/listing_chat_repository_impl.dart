import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingChatRepositoryImpl implements ListingChatRepository {
  const ListingChatRepositoryImpl(this._remote);

  final ChatRemoteDataSource _remote;

  @override
  ResultFuture<ChatConversation> openConversation({required int listingId}) =>
      _run(() => _remote.openConversation(listingId: listingId));

  @override
  ResultFuture<ChatConversationsPage> getConversations({
    required bool archived,
    required int page,
    required int perPage,
  }) => _run(
    () => _remote.getConversations(
      archived: archived,
      page: page,
      perPage: perPage,
    ),
  );

  @override
  ResultFuture<ChatSummary> getChatSummary({DateTime? since}) =>
      _run(() => _remote.getChatSummary(since: since));

  @override
  ResultFuture<ChatConversation> getConversation({required int id}) =>
      _run(() => _remote.getConversation(id: id));

  @override
  ResultFuture<ChatMessagesPage> getMessages({
    required int conversationId,
    int? afterId,
    int? beforeId,
    required int limit,
  }) => _run(
    () => _remote.getMessages(
      conversationId: conversationId,
      afterId: afterId,
      beforeId: beforeId,
      limit: limit,
    ),
  );

  @override
  ResultFuture<ChatMessage> sendTextMessage({
    required int conversationId,
    required String text,
    required String clientId,
  }) => _run(
    () => _remote.sendTextMessage(
      conversationId: conversationId,
      text: text,
      clientId: clientId,
    ),
  );

  @override
  ResultFuture<ChatMessage> sendImageMessage({
    required int conversationId,
    required File image,
    required String clientId,
  }) => _run(
    () => _remote.sendImageMessage(
      conversationId: conversationId,
      image: image,
      clientId: clientId,
    ),
  );

  @override
  ResultFuture<ChatConversationState> markConversationRead({
    required int conversationId,
    int? upToMessageId,
  }) => _run(
    () => _remote.markConversationRead(
      conversationId: conversationId,
      upToMessageId: upToMessageId,
    ),
  );

  @override
  ResultFuture<ChatConversationState> setConversationArchived({
    required int conversationId,
    required bool value,
  }) => _run(
    () => _remote.setConversationArchived(
      conversationId: conversationId,
      value: value,
    ),
  );

  @override
  ResultFuture<ChatConversationState> setConversationMuted({
    required int conversationId,
    required bool value,
  }) => _run(
    () => _remote.setConversationMuted(
      conversationId: conversationId,
      value: value,
    ),
  );

  @override
  ResultVoid reportConversation({
    required int conversationId,
    required String reason,
    String? note,
  }) => _runVoid(
    () => _remote.reportConversation(
      conversationId: conversationId,
      reason: reason,
      note: note,
    ),
  );

  @override
  ResultVoid deleteConversation({required int conversationId}) => _runVoid(
    () => _remote.deleteConversation(conversationId: conversationId),
  );

  Future<Either<Failure, T>> _run<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  ResultVoid _runVoid(Future<void> Function() request) async {
    try {
      await request();
      return const Right(null);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
