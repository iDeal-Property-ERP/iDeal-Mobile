import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/services/push/active_chat_conversation_tracker.dart';

void main() {
  final tracker = ActiveChatConversationTracker.instance;

  setUp(() => tracker.setConversationId(null));

  test('tracks and clears the visible conversation without Firebase', () {
    expect(tracker.conversationId, isNull);

    tracker.setConversationId(42);
    expect(tracker.conversationId, 42);

    tracker.setConversationId(null);
    expect(tracker.conversationId, isNull);
  });
}
