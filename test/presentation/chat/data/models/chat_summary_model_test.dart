import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_summary_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a summary', () {
    final model = ChatSummaryModel.fromJson(summaryJson());

    expect(model.toJson(), summaryJson());
    expect(model.totalUnread, 2);
  });

  test('throws for a malformed required server time', () {
    expect(
      () => ChatSummaryModel.fromJson({
        ...summaryJson(),
        'server_time': 'not-a-date',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
