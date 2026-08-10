import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_state_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_messages_page_model.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_messages_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_messages.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/mark_conversation_read.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_image_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_text_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';
import 'package:mocktail/mocktail.dart';

import '../data/chat_model_test_fixtures.dart';

class MockGetConversation extends Mock implements GetConversation {}

class MockGetMessages extends Mock implements GetMessages {}

class MockMarkConversationRead extends Mock implements MarkConversationRead {}

class MockSendTextMessage extends Mock implements SendTextMessage {}

class MockSendImageMessage extends Mock implements SendImageMessage {}

class MockSetConversationArchived extends Mock
    implements SetConversationArchived {}

class MockSetConversationMuted extends Mock implements SetConversationMuted {}

class MockReportConversation extends Mock implements ReportConversation {}

ChatConversationModel _conversation() {
  return ChatConversationModel.fromJson(conversationJson());
}

ChatMessageModel _message({
  int id = 9,
  String? clientId = 'client-9',
  bool isMine = true,
}) {
  return ChatMessageModel.fromJson({
    ...messageJson(id: id, clientId: clientId),
    'is_mine': isMine,
  });
}

ChatMessagesPage _page({
  List<ChatMessage> messages = const <ChatMessage>[],
  bool hasMore = false,
  bool isReadOnly = false,
}) {
  return ChatMessagesPageModel(
    messages: messages,
    hasMore: hasMore,
    conversation: ChatConversationStateModel.fromJson(
      conversationStateJson(
        isReadOnly: isReadOnly,
        lastMessageId: messages.isEmpty ? 9 : messages.last.id,
      ),
    ),
  );
}

ListingChatConversationBloc _buildBloc({
  required MockGetConversation getConversation,
  required MockGetMessages getMessages,
  required MockMarkConversationRead markRead,
  MockSendTextMessage? sendText,
  MockSendImageMessage? sendImage,
}) {
  return ListingChatConversationBloc(
    conversationId: 42,
    getConversation: getConversation,
    getMessages: getMessages,
    markConversationRead: markRead,
    sendTextMessage: sendText ?? MockSendTextMessage(),
    sendImageMessage: sendImage ?? MockSendImageMessage(),
    setConversationArchived: MockSetConversationArchived(),
    setConversationMuted: MockSetConversationMuted(),
    reportConversation: MockReportConversation(),
  );
}

void _stubInitial(
  MockGetConversation getConversation,
  MockGetMessages getMessages,
  MockMarkConversationRead markRead,
) {
  when(
    () => getConversation(any()),
  ).thenAnswer((_) async => Right<Failure, ChatConversation>(_conversation()));
  when(
    () => getMessages(any()),
  ).thenAnswer((_) async => Right<Failure, ChatMessagesPage>(_page()));
  when(() => markRead(any())).thenAnswer(
    (_) async => Right<Failure, ChatConversationStateModel>(
      ChatConversationStateModel.fromJson(conversationStateJson()),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetConversationParams(conversationId: 42));
    registerFallbackValue(const GetMessagesParams(conversationId: 42));
    registerFallbackValue(const MarkConversationReadParams(conversationId: 42));
    registerFallbackValue(
      const SendTextMessageParams(
        conversationId: 42,
        text: 'fallback',
        clientId: 'fallback',
      ),
    );
  });

  test('merge deduplicates both server id and client id', () {
    final pending = PendingChatMessage(
      clientId: 'client-1',
      text: 'hello',
      localPath: null,
      createdAt: DateTime(2026, 8, 9, 10),
      status: ChatMessageStatus.sending,
    );
    final server = _message(id: 10, clientId: 'client-1');

    final first = mergeChatMessages(
      existing: const <ChatMessage>[],
      pending: [pending],
      incoming: [server],
    );
    final second = mergeChatMessages(
      existing: first.messages,
      pending: first.pending,
      incoming: [server],
    );

    expect(first.messages, hasLength(1));
    expect(first.pending, isEmpty);
    expect(second.messages, hasLength(1));
  });

  test('peer read watermark changes own message status to read', () {
    final state = ListingChatConversationState.test(
      messages: [_message()],
      peerLastReadMessageId: 9,
    );

    expect(state.statusFor(state.messages.single), ChatMessageStatus.read);
  });

  test('read-only state cannot send a draft', () {
    const state = ListingChatConversationState.test(
      isReadOnly: true,
      draft: 'hello',
    );

    expect(state.canSend, isFalse);
  });

  test('a poll changing read-only state disables sending', () async {
    final getConversation = MockGetConversation();
    final getMessages = MockGetMessages();
    final markRead = MockMarkConversationRead();
    _stubInitial(getConversation, getMessages, markRead);
    var initial = true;
    when(() => getMessages(any())).thenAnswer((_) async {
      if (initial) {
        initial = false;
        return Right<Failure, ChatMessagesPage>(_page());
      }
      return Right<Failure, ChatMessagesPage>(_page(isReadOnly: true));
    });
    final bloc = _buildBloc(
      getConversation: getConversation,
      getMessages: getMessages,
      markRead: markRead,
    );

    bloc.add(const ChatConversationStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ChatConversationDraftChanged('hello'));
    bloc.add(const ChatConversationPollTicked());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.isReadOnly, isTrue);
    expect(bloc.state.canSend, isFalse);
    await bloc.close();
  });

  test('poll timer fires once per second and stops on close', () {
    fakeAsync((async) {
      final getConversation = MockGetConversation();
      final getMessages = MockGetMessages();
      final markRead = MockMarkConversationRead();
      _stubInitial(getConversation, getMessages, markRead);
      var calls = 0;
      when(() => getMessages(any())).thenAnswer((_) async {
        calls++;
        return Right<Failure, ChatMessagesPage>(_page());
      });
      final bloc = _buildBloc(
        getConversation: getConversation,
        getMessages: getMessages,
        markRead: markRead,
      );

      bloc.add(const ChatConversationStarted());
      async.flushMicrotasks();
      final initialCalls = calls;
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(calls, initialCalls + 1);
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(calls, initialCalls + 2);

      unawaited(bloc.close());
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();
      expect(calls, initialCalls + 2);
    });
  });

  test('does not issue a second poll while the first is unresolved', () {
    fakeAsync((async) {
      final getConversation = MockGetConversation();
      final getMessages = MockGetMessages();
      final markRead = MockMarkConversationRead();
      _stubInitial(getConversation, getMessages, markRead);
      final pendingPoll = Completer<Either<Failure, ChatMessagesPage>>();
      var calls = 0;
      var initial = true;
      when(() => getMessages(any())).thenAnswer((_) {
        if (initial) {
          initial = false;
          return Future.value(Right<Failure, ChatMessagesPage>(_page()));
        }
        calls++;
        return pendingPoll.future;
      });
      final bloc = _buildBloc(
        getConversation: getConversation,
        getMessages: getMessages,
        markRead: markRead,
      );

      bloc.add(const ChatConversationStarted());
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(calls, 1);

      pendingPoll.complete(Right<Failure, ChatMessagesPage>(_page()));
      async.flushMicrotasks();
      unawaited(bloc.close());
    });
  });

  test('paused stops polling and resumed fires an immediate poll', () {
    fakeAsync((async) {
      final getConversation = MockGetConversation();
      final getMessages = MockGetMessages();
      final markRead = MockMarkConversationRead();
      _stubInitial(getConversation, getMessages, markRead);
      var calls = 0;
      when(() => getMessages(any())).thenAnswer((_) async {
        calls++;
        return Right<Failure, ChatMessagesPage>(_page());
      });
      final bloc = _buildBloc(
        getConversation: getConversation,
        getMessages: getMessages,
        markRead: markRead,
      );
      bloc.add(const ChatConversationStarted());
      async.flushMicrotasks();
      final beforePause = calls;
      bloc.add(
        const ChatConversationLifecycleChanged(AppLifecycleState.paused),
      );
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 2));
      expect(calls, beforePause);
      bloc.add(
        const ChatConversationLifecycleChanged(AppLifecycleState.resumed),
      );
      async.flushMicrotasks();
      expect(calls, beforePause + 1);
      unawaited(bloc.close());
    });
  });

  test('five consecutive poll failures stop the timer', () {
    fakeAsync((async) {
      final getConversation = MockGetConversation();
      final getMessages = MockGetMessages();
      final markRead = MockMarkConversationRead();
      _stubInitial(getConversation, getMessages, markRead);
      var initial = true;
      var calls = 0;
      when(() => getMessages(any())).thenAnswer((_) async {
        if (initial) {
          initial = false;
          return Right<Failure, ChatMessagesPage>(_page());
        }
        calls++;
        return const Left<Failure, ChatMessagesPage>(
          APIFailure(message: 'offline', statusCode: 503),
        );
      });
      final bloc = _buildBloc(
        getConversation: getConversation,
        getMessages: getMessages,
        markRead: markRead,
      );
      bloc.add(const ChatConversationStarted());
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 31));
      async.flushMicrotasks();
      expect(calls, 5);
      async.elapse(const Duration(seconds: 30));
      async.flushMicrotasks();
      expect(calls, 5);
      unawaited(bloc.close());
    });
  });

  test('optimistic text send changes sending to sent', () async {
    final getConversation = MockGetConversation();
    final getMessages = MockGetMessages();
    final markRead = MockMarkConversationRead();
    final sendText = MockSendTextMessage();
    when(() => sendText(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as SendTextMessageParams;
      return Right<Failure, ChatMessage>(
        _message(id: 12, clientId: params.clientId),
      );
    });
    final bloc = _buildBloc(
      getConversation: getConversation,
      getMessages: getMessages,
      markRead: markRead,
      sendText: sendText,
    );
    bloc.add(const ChatConversationDraftChanged('hello'));
    bloc.add(const ChatConversationTextSent());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.pending, isEmpty);
    expect(bloc.state.messages.single.clientId, isNotEmpty);
    verify(() => sendText(any())).called(1);
    await bloc.close();
  });

  test('failed send retries with the same client id', () async {
    final getConversation = MockGetConversation();
    final getMessages = MockGetMessages();
    final markRead = MockMarkConversationRead();
    final sendText = MockSendTextMessage();
    var attempt = 0;
    final clientIds = <String>[];
    when(() => sendText(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as SendTextMessageParams;
      clientIds.add(params.clientId);
      attempt++;
      if (attempt == 1) {
        return const Left<Failure, ChatMessage>(
          APIFailure(message: 'Offline', statusCode: 503),
        );
      }
      return Right<Failure, ChatMessage>(
        _message(id: 13, clientId: params.clientId),
      );
    });
    final bloc = _buildBloc(
      getConversation: getConversation,
      getMessages: getMessages,
      markRead: markRead,
      sendText: sendText,
    );
    bloc.add(const ChatConversationDraftChanged('retry me'));
    bloc.add(const ChatConversationTextSent());
    await Future<void>.delayed(Duration.zero);
    final clientId = bloc.state.pending.single.clientId;
    expect(bloc.state.pending.single.status, ChatMessageStatus.failed);

    bloc.add(ChatConversationRetrySent(clientId));
    await Future<void>.delayed(Duration.zero);

    expect(clientIds, [clientId, clientId]);
    expect(bloc.state.pending, isEmpty);
    await bloc.close();
  });
}
