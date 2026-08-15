import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart';
import 'package:ideal_mobile/presentation/chat/chats_screen.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';
import 'chat_test_helpers.dart';
import 'data/chat_model_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dispatches refresh from the Chats root top bar', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);
    final bloc = mockChatsBloc(const ChatsState.initial());

    await tester.runWidgetTest(child: ChatsScreen(bloc: bloc));

    final visibleRefresh = find.byIcon(TablerIcons.refresh).hitTestable();
    expect(tester.getTopLeft(visibleRefresh).dy, greaterThanOrEqualTo(24));
    await tester.tap(visibleRefresh);
    await tester.pump();

    verify(
      () => bloc.add(const ChatsRefreshRequested(tab: ChatsTab.active)),
    ).called(1);
  });

  testWidgets('uses the localized Chats root title', (tester) async {
    for (final scenario in const [
      (Locale('en'), 'Chats', 'Active', 'Archived'),
      (Locale('ru'), 'Чаты', 'Активные', 'Архив'),
      (Locale('uz'), 'Suhbatlar', 'Faol', 'Arxiv'),
    ]) {
      final bloc = mockChatsBloc(const ChatsState.initial());
      await tester.pumpWidget(
        MaterialApp(
          locale: scenario.$1,
          theme: ThemeData.light(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ChatsScreen(bloc: bloc),
        ),
      );
      await tester.pump();

      expect(find.text(scenario.$2).hitTestable(), findsOneWidget);
      expect(find.text(scenario.$3).hitTestable(), findsOneWidget);
      expect(find.text(scenario.$4).hitTestable(), findsOneWidget);
    }
  });

  Future<void> pumpWithMockedImages(WidgetTester tester, Widget widget) {
    return mockNetworkImages(() => tester.pumpWidget(widget));
  }

  Future<void> settleWithMockedImages(WidgetTester tester) {
    return mockNetworkImages(() => tester.pump());
  }

  testExecutable(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => '/tmp',
        );
    goldenTest(
      'chats page',
      fileName: 'chats_page',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockChatsBloc(
          ChatsState.test(
            activeFeed: ChatsFeedState(
              items: [buildChatConversation()],
              page: 1,
              numPages: 1,
              count: 1,
              hasLoaded: true,
              hasReachedMax: true,
            ),
          ),
        );
        return createTestScenario(
          name: 'chats page',
          providers: [],
          child: ChatsScreen(bloc: bloc),
        );
      },
    );

    goldenTest(
      'chats page archived tab',
      fileName: 'chats_page_archived_expanded',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockChatsBloc(
          ChatsState.test(
            selectedTab: ChatsTab.archived,
            activeFeed: ChatsFeedState(
              items: [buildChatConversation()],
              page: 1,
              numPages: 1,
              count: 1,
              hasLoaded: true,
              hasReachedMax: true,
            ),
            archivedFeed: ChatsFeedState(
              items: [buildChatConversation(isArchived: true, unreadCount: 0)],
              page: 1,
              numPages: 1,
              count: 1,
              hasLoaded: true,
              hasReachedMax: true,
            ),
          ),
        );
        return createTestScenario(
          name: 'chats page archived tab',
          child: ChatsScreen(bloc: bloc),
        );
      },
    );

    goldenTest(
      'chat conversation page',
      fileName: 'chat_conversation_page',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockConversationBloc(
          ListingChatConversationState.test(
            conversationId: 42,
            listing: buildChatConversation().listing,
            messages: [
              ChatMessageModel.fromJson(messageJson(id: 8, clientId: null)),
              ChatMessageModel.fromJson(messageJson()),
            ],
          ),
        );
        return createTestScenario(
          name: 'chat conversation page',
          child: ChatConversationScreen(bloc: bloc, conversationId: 42),
        );
      },
    );

    goldenTest(
      'chat conversation read only',
      fileName: 'chat_conversation_read_only',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockConversationBloc(
          ListingChatConversationState.test(
            conversationId: 42,
            listing: buildChatConversation(isReadOnly: true).listing,
            isReadOnly: true,
            messages: [ChatMessageModel.fromJson(messageJson())],
          ),
        );
        return createTestScenario(
          name: 'chat conversation read only',
          child: ChatConversationScreen(bloc: bloc, conversationId: 42),
        );
      },
    );

    goldenTest(
      'chat conversation with image',
      fileName: 'chat_conversation_with_image',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockConversationBloc(
          ListingChatConversationState.test(
            conversationId: 42,
            listing: buildChatConversation().listing,
            messages: [buildChatImageMessage()],
          ),
        );
        return createTestScenario(
          name: 'chat conversation with image',
          child: ChatConversationScreen(bloc: bloc, conversationId: 42),
        );
      },
    );
  });
}
