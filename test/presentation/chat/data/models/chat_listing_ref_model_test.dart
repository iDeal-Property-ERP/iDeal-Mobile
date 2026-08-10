import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_listing_ref_model.dart';

import '../chat_model_test_fixtures.dart';

void main() {
  test('round trips a listing reference', () {
    final model = ChatListingRefModel.fromJson(listingJson());

    expect(model.toJson(), listingJson());
  });

  test('defaults missing optional listing fields', () {
    final model = ChatListingRefModel.fromJson(
      listingJson(includeOptional: false),
    );

    expect(model.coverImageUrl, isNull);
    expect(model.price, isNull);
    expect(model.currency, isEmpty);
  });

  test('throws for a malformed required id', () {
    expect(
      () => ChatListingRefModel.fromJson({...listingJson(), 'id': 'bad'}),
      throwsA(isA<FormatException>()),
    );
  });
}
