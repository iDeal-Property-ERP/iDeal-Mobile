import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_summary_model.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversations_page.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/delete_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_conversations.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/report_conversation.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_archived.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/set_conversation_muted.dart';
import 'package:mocktail/mocktail.dart';

import '../chat_test_helpers.dart';
import '../data/chat_model_test_fixtures.dart';

class MockGetConversations extends Mock implements GetConversations {}

class MockGetChatSummary extends Mock implements GetChatSummary {}

class MockSetConversationArchived extends Mock
    implements SetConversationArchived {}

class MockSetConversationMuted extends Mock implements SetConversationMuted {}

class MockReportConversation extends Mock implements ReportConversation {}

class MockDeleteConversation extends Mock implements DeleteConversation {}

ChatConversationsPage _page({
  required List<int> ids,
  int page = 1,
  int numPages = 1,
  int? count,
  bool archived = false,
}) {
  return ChatConversationsPage(
    items: [
      for (final id in ids) buildChatConversation(id: id, isArchived: archived),
    ],
    count: count ?? ids.length,
    numPages: numPages,
    perPage: 20,
    pageNumber: page,
  );
}

Future<void> _waitFor(
  ChatsBloc bloc,
  bool Function(ChatsState state) predicate,
) async {
  if (predicate(bloc.state)) return;
  await bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 2));
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
    when(() => getConversations(any())).thenAnswer(
      (_) async => Right<Failure, ChatConversationsPage>(_page(ids: [42])),
    );
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
    when(
      () => delete(any()),
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

  test('loads Active first and Archived only on first tab selection', () async {
    when(() => getConversations(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as GetConversationsParams;
      return Right<Failure, ChatConversationsPage>(
        _page(
          ids: [if (params.archived) 90 else 10],
          archived: params.archived,
        ),
      );
    });
    final bloc = build();

    bloc.add(const ChatsStarted());
    await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
    expect(bloc.state.activeFeed.items.single.id, 10);
    expect(bloc.state.archivedFeed.hasLoaded, isFalse);

    bloc.add(const ChatsTabSelected(ChatsTab.archived));
    await _waitFor(bloc, (state) => state.archivedFeed.hasLoaded);
    bloc.add(const ChatsTabSelected(ChatsTab.active));
    bloc.add(const ChatsTabSelected(ChatsTab.archived));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.selectedTab, ChatsTab.archived);
    expect(bloc.state.archivedFeed.items.single.id, 90);
    verify(
      () => getConversations(const GetConversationsParams(archived: true)),
    ).called(1);
    await bloc.close();
  });

  test(
    'paginates each feed independently and deduplicates appended IDs',
    () async {
      when(() => getConversations(any())).thenAnswer((invocation) async {
        final params =
            invocation.positionalArguments.single as GetConversationsParams;
        if (params.archived) {
          return Right<Failure, ChatConversationsPage>(
            _page(
              ids: params.page == 1 ? [91, 90] : [90, 89],
              page: params.page,
              numPages: 2,
              count: 3,
              archived: true,
            ),
          );
        }
        return Right<Failure, ChatConversationsPage>(
          _page(
            ids: params.page == 1 ? [3, 2] : [2, 1],
            page: params.page,
            numPages: 2,
            count: 3,
          ),
        );
      });
      final bloc = build();

      bloc.add(const ChatsStarted());
      await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
      bloc.add(const ChatsLoadMoreRequested(ChatsTab.active));
      await _waitFor(bloc, (state) => state.activeFeed.page == 2);
      bloc.add(const ChatsTabSelected(ChatsTab.archived));
      await _waitFor(bloc, (state) => state.archivedFeed.hasLoaded);
      bloc.add(const ChatsLoadMoreRequested(ChatsTab.archived));
      await _waitFor(bloc, (state) => state.archivedFeed.page == 2);

      expect(bloc.state.activeFeed.items.map((item) => item.id), [3, 2, 1]);
      expect(bloc.state.archivedFeed.items.map((item) => item.id), [
        91,
        90,
        89,
      ]);
      expect(bloc.state.activeFeed.hasReachedMax, isTrue);
      expect(bloc.state.archivedFeed.hasReachedMax, isTrue);

      bloc.add(const ChatsLoadMoreRequested(ChatsTab.active));
      await Future<void>.delayed(Duration.zero);
      verify(
        () => getConversations(
          const GetConversationsParams(archived: false, page: 2),
        ),
      ).called(1);
      await bloc.close();
    },
  );

  test('ignores a stale first-page response', () async {
    final stale = Completer<Either<Failure, ChatConversationsPage>>();
    final fresh = Completer<Either<Failure, ChatConversationsPage>>();
    var calls = 0;
    when(() => getConversations(any())).thenAnswer((_) {
      calls += 1;
      return calls == 1 ? stale.future : fresh.future;
    });
    final bloc = build();

    bloc.add(const ChatsStarted());
    await _waitFor(bloc, (state) => state.activeFeed.isLoading);
    bloc.add(const ChatsRefreshRequested(tab: ChatsTab.active));
    fresh.complete(Right<Failure, ChatConversationsPage>(_page(ids: [2])));
    await _waitFor(
      bloc,
      (state) => state.activeFeed.items.firstOrNull?.id == 2,
    );
    stale.complete(Right<Failure, ChatConversationsPage>(_page(ids: [1])));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.activeFeed.items.single.id, 2);
    await bloc.close();
  });

  test('retains rows and exposes retry page after load-more failure', () async {
    when(() => getConversations(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as GetConversationsParams;
      if (params.page == 2) {
        return const Left<Failure, ChatConversationsPage>(
          APIFailure(message: 'Next page failed', statusCode: 503),
        );
      }
      return Right<Failure, ChatConversationsPage>(
        _page(ids: [2, 1], numPages: 2, count: 3),
      );
    });
    final bloc = build();

    bloc.add(const ChatsStarted());
    await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
    bloc.add(const ChatsLoadMoreRequested(ChatsTab.active));
    await _waitFor(bloc, (state) => state.activeFeed.errorMessage != null);

    expect(bloc.state.activeFeed.items.map((item) => item.id), [2, 1]);
    expect(bloc.state.activeFeed.failedPage, 2);
    expect(bloc.state.activeFeed.isLoadingMore, isFalse);
    await bloc.close();
  });

  test('polling refreshes the already-loaded page range', () async {
    final summary = Completer<Either<Failure, ChatSummary>>();
    when(() => getSummary(any())).thenAnswer((_) => summary.future);
    when(() => getConversations(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as GetConversationsParams;
      return Right<Failure, ChatConversationsPage>(
        _page(
          ids: params.page == 1 ? [4, 3] : [2, 1],
          page: params.page,
          numPages: 2,
          count: 4,
        ),
      );
    });
    final bloc = build();

    bloc.add(const ChatsStarted());
    await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
    bloc.add(const ChatsLoadMoreRequested(ChatsTab.active));
    await _waitFor(bloc, (state) => state.activeFeed.page == 2);
    clearInteractions(getConversations);
    bloc.add(const ChatsPollTicked());
    await _waitFor(bloc, (state) => state.isPolling);
    summary.complete(
      Right<Failure, ChatSummary>(ChatSummaryModel.fromJson(summaryJson())),
    );
    await _waitFor(bloc, (state) => !state.isPolling);

    verify(
      () => getConversations(const GetConversationsParams(archived: false)),
    ).called(1);
    verify(
      () => getConversations(
        const GetConversationsParams(archived: false, page: 2),
      ),
    ).called(1);
    expect(bloc.state.activeFeed.page, 2);
    expect(bloc.state.activeFeed.items.map((item) => item.id), [4, 3, 2, 1]);
    await bloc.close();
  });

  test(
    'archive movement is optimistic and rolls both feeds back on failure',
    () async {
      final result = Completer<Either<Failure, ChatConversationState>>();
      when(() => archive(any())).thenAnswer((_) => result.future);
      final bloc = build();

      bloc.add(const ChatsStarted());
      await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
      bloc.add(const ChatsArchiveToggled(conversationId: 42, archived: true));
      await _waitFor(bloc, (state) => state.activeFeed.items.isEmpty);

      expect(bloc.state.archivedFeed.items.single.id, 42);
      result.complete(
        const Left<Failure, ChatConversationState>(
          APIFailure(message: 'Archive failed', statusCode: 503),
        ),
      );
      await _waitFor(bloc, (state) => state.errorMessage != null);

      expect(bloc.state.activeFeed.items.single.id, 42);
      expect(bloc.state.archivedFeed.items, isEmpty);
      expect(bloc.state.errorMessage, contains('Archive failed'));
      await bloc.close();
    },
  );

  test('archive and unarchive reconcile both loaded feeds', () async {
    var archivedOnServer = false;
    when(() => getConversations(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single as GetConversationsParams;
      final matches = params.archived == archivedOnServer;
      return Right<Failure, ChatConversationsPage>(
        _page(
          ids: matches ? [42] : [],
          archived: params.archived,
          count: matches ? 1 : 0,
        ),
      );
    });
    when(() => archive(any())).thenAnswer((invocation) async {
      final params =
          invocation.positionalArguments.single
              as SetConversationArchivedParams;
      archivedOnServer = params.value;
      return Right<Failure, ChatConversationState>(
        ChatConversationState(
          id: 42,
          isReadOnly: false,
          deletedByPeer: false,
          isBlocked: false,
          isArchived: params.value,
          isMuted: false,
          unreadCount: 0,
          lastMessageId: null,
          peerLastReadMessageId: null,
          listingIsAvailable: true,
        ),
      );
    });
    final bloc = build();

    bloc.add(const ChatsStarted());
    await _waitFor(bloc, (state) => state.activeFeed.hasLoaded);
    bloc.add(const ChatsArchiveToggled(conversationId: 42, archived: true));
    await _waitFor(
      bloc,
      (state) => state.activeFeed.items.isEmpty && !state.activeFeed.isLoading,
    );
    expect(bloc.state.archivedFeed.items.single.id, 42);

    bloc.add(const ChatsTabSelected(ChatsTab.archived));
    await _waitFor(bloc, (state) => state.archivedFeed.hasLoaded);
    bloc.add(const ChatsArchiveToggled(conversationId: 42, archived: false));
    await _waitFor(
      bloc,
      (state) =>
          state.activeFeed.items.isNotEmpty &&
          state.archivedFeed.items.isEmpty &&
          !state.archivedFeed.isLoading,
    );

    expect(bloc.state.activeFeed.items.single.isArchived, isFalse);
    expect(bloc.state.archivedFeed.items, isEmpty);
    await bloc.close();
  });

  test('does not poll before ChatsStarted', () async {
    final bloc = build();

    bloc.add(const ChatsPollTicked());
    await Future<void>.delayed(Duration.zero);

    verifyNever(() => getSummary(any()));
    await bloc.close();
  });
}
