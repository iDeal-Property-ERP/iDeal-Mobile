import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversations_page_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a paginated conversation list', () {
    final model = ChatConversationsPageModel.fromJson(conversationsPageJson());

    expect(model.toJson(), conversationsPageJson());
    expect(model.hasMore, isFalse);
  });

  test('throws when pagination metadata is malformed', () {
    expect(
      () => ChatConversationsPageModel.fromJson({
        ...conversationsPageJson(),
        'page': null,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
