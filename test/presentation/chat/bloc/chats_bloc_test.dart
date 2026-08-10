import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversations_page_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_summary_model.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/delete_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversations.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';
import 'package:mocktail/mocktail.dart';

import '../data/chat_model_test_fixtures.dart';

class MockGetConversations extends Mock implements GetConversations {}

class MockGetChatSummary extends Mock implements GetChatSummary {}

class MockSetConversationArchived extends Mock
    implements SetConversationArchived {}

class MockSetConversationMuted extends Mock implements SetConversationMuted {}

class MockReportConversation extends Mock implements ReportConversation {}

class MockDeleteConversation extends Mock implements DeleteConversation {}

ChatConversationsPage _page() {
  return ChatConversationsPageModel.fromJson(conversationsPageJson());
}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetConversationsParams(archived: false));
    registerFallbackValue(const GetChatSummaryParams());
    registerFallbackValue(
      const SetConversationArchivedParams(conversationId: 42, value: false),
    );
    registerFallbackValue(
      const SetConversationMutedParams(conversationId: 42, value: false),
    );
    registerFallbackValue(
      const ReportConversationParams(conversationId: 42, reason: 'spam'),
    );
    registerFallbackValue(const DeleteConversationParams(conversationId: 42));
  });

  late MockGetConversations getConversations;
  late MockGetChatSummary getSummary;
  late MockSetConversationArchived archive;
  late MockSetConversationMuted mute;
  late MockReportConversation report;
  late MockDeleteConversation delete;

  setUp(() {
    getConversations = MockGetConversations();
    getSummary = MockGetChatSummary();
    archive = MockSetConversationArchived();
    mute = MockSetConversationMuted();
    report = MockReportConversation();
    delete = MockDeleteConversation();
    when(
      () => getConversations(any()),
    ).thenAnswer((_) async => Right<Failure, ChatConversationsPage>(_page()));
    when(() => getSummary(any())).thenAnswer(
      (_) async =>
          Right<Failure, ChatSummary>(ChatSummaryModel.fromJson(summaryJson())),
    );
    when(() => archive(any())).thenAnswer(
      (_) async => const Right<Failure, ChatConversationState>(
        ChatConversationState(
          id: 42,
          isReadOnly: false,
          deletedByPeer: false,
          isBlocked: false,
          isArchived: false,
          isMuted: false,
          unreadCount: 0,
          lastMessageId: null,
          peerLastReadMessageId: null,
          listingIsAvailable: true,
        ),
      ),
    );
    when(() => mute(any())).thenAnswer(
      (_) async => const Right<Failure, ChatConversationState>(
        ChatConversationState(
          id: 42,
          isReadOnly: false,
          deletedByPeer: false,
          isBlocked: false,
          isArchived: false,
          isMuted: false,
          unreadCount: 0,
          lastMessageId: null,
          peerLastReadMessageId: null,
          listingIsAvailable: true,
        ),
      ),
    );
    when(
      () => report(any()),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  ChatsBloc build() => ChatsBloc(
    getConversations: getConversations,
    getChatSummary: getSummary,
    setConversationArchived: archive,
    setConversationMuted: mute,
    reportConversation: report,
    deleteConversation: delete,
  );

  test('loads active conversations on ChatsStarted', () async {
    final bloc = build();

    bloc.add(const ChatsStarted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.activeItems.single.id, 42);
    expect(bloc.state.status, ChatsStatus.loaded);
    verify(
      () => getConversations(const GetConversationsParams(archived: false)),
    ).called(1);
    await bloc.close();
  });

  test('does not poll before ChatsStarted', () async {
    final bloc = build();

    bloc.add(const ChatsPollTicked());
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => getSummary(any()));
    await bloc.close();
  });

  test('loads archived conversations only on first expand', () async {
    final bloc = build();
    bloc.add(const ChatsStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ChatsArchivedToggled());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ChatsArchivedToggled());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ChatsArchivedToggled());
    await Future<void>.delayed(Duration.zero);

    verify(
      () => getConversations(const GetConversationsParams(archived: true)),
    ).called(1);
    expect(bloc.state.archivedExpanded, isTrue);
    expect(bloc.state.archivedLoaded, isTrue);
    await bloc.close();
  });

  test('optimistic delete rolls back on failure', () async {
    when(() => delete(any())).thenAnswer(
      (_) async => const Left<Failure, void>(
        APIFailure(message: 'Delete failed', statusCode: 503),
      ),
    );
    final bloc = build();
    bloc.add(const ChatsStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ChatsConversationDeleted(42));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.activeItems.single.id, 42);
    expect(bloc.state.errorMessage, contains('Delete failed'));
    await bloc.close();
  });
}
