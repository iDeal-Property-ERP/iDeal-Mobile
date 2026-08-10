import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_messages_page_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a cursor page', () {
    final model = ChatMessagesPageModel.fromJson(messagesPageJson());

    expect(model.toJson(), messagesPageJson());
    expect(model.messages.single.id, 9);
  });

  test('throws when the required message list is malformed', () {
    expect(
      () => ChatMessagesPageModel.fromJson({
        ...messagesPageJson(),
        'messages': null,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
