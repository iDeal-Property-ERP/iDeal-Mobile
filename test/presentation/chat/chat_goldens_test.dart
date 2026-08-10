import 'package:alchemist/alchemist.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart';
import 'package:ideal_mobile/presentation/chat/chats_screen.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';
import 'chat_test_helpers.dart';
import 'data/chat_model_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
          ChatsState.test(activeItems: [buildChatConversation()]),
        );
        return createTestScenario(
          name: 'chats page',
          providers: [],
          child: ChatsScreen(bloc: bloc),
        );
      },
    );

    goldenTest(
      'chats page archived expanded',
      fileName: 'chats_page_archived_expanded',
      pumpWidget: pumpWithMockedImages,
      pumpBeforeTest: settleWithMockedImages,
      builder: () {
        final bloc = mockChatsBloc(
          ChatsState.test(
            activeItems: [buildChatConversation()],
            archivedItems: [
              buildChatConversation(isArchived: true, unreadCount: 0),
            ],
            archivedExpanded: true,
            archivedLoaded: true,
          ),
        );
        return createTestScenario(
          name: 'chats page archived expanded',
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
