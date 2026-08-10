import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_state_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips conversation state', () {
    final model = ChatConversationStateModel.fromJson(conversationStateJson());

    expect(model.toJson(), conversationStateJson());
  });

  test('defaults missing optional state fields', () {
    final model = ChatConversationStateModel.fromJson({'id': 42});

    expect(model.unreadCount, 0);
    expect(model.lastMessageId, isNull);
    expect(model.isReadOnly, isFalse);
    expect(model.listingIsAvailable, isTrue);
  });

  test('throws for a malformed required id', () {
    expect(
      () => ChatConversationStateModel.fromJson({'id': null}),
      throwsA(isA<FormatException>()),
    );
  });
}
