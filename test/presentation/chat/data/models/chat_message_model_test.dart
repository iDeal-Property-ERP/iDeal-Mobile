import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a text message', () {
    final model = ChatMessageModel.fromJson(messageJson());

    expect(model.toJson(), messageJson());
  });

  test('tolerates null image url and missing optional media fields', () {
    final json = messageJson()..remove('client_id');
    final model = ChatMessageModel.fromJson(json);

    expect(model.imageUrl, isNull);
    expect(model.imageWidth, isNull);
    expect(model.imageHeight, isNull);
    expect(model.clientId, isNull);
  });

  test('throws for a malformed required conversation id', () {
    expect(
      () => ChatMessageModel.fromJson({
        ...messageJson(),
        'conversation_id': 'bad',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
