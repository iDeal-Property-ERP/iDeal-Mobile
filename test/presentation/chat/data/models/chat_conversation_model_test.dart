import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a conversation with listing context', () {
    final model = ChatConversationModel.fromJson(conversationJson());

    expect(model.toJson(), conversationJson());
    expect(model.listing.title, 'Sunny apartment');
  });

  test('defaults optional preview fields', () {
    final json = conversationJson()
      ..remove('last_message_preview')
      ..remove('last_message_kind')
      ..remove('last_message_at');
    final model = ChatConversationModel.fromJson(json);

    expect(model.lastMessagePreview, isNull);
    expect(model.lastMessageKind, isNull);
    expect(model.lastMessageAt, isNull);
  });

  test('throws for a malformed required listing', () {
    expect(
      () => ChatConversationModel.fromJson({
        ...conversationJson(),
        'listing': null,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
