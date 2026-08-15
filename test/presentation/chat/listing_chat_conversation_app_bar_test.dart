import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/presentation/chat/widgets/listing_chat_conversation_app_bar.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('keeps listing identity, unavailable banner, and menu actions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);
    var archived = 0;
    await tester.runWidgetTest(
      child: Scaffold(
        appBar: ListingChatConversationAppBar(
          listing: const ChatListingRef(
            id: 42,
            title: 'Sunny apartment near the park',
            coverImageUrl: null,
            price: 520,
            currency: 'USD',
            isAvailable: false,
          ),
          listingIsAvailable: false,
          isArchived: false,
          isMuted: false,
          onArchive: () => archived++,
        ),
      ),
    );

    expect(find.byType(AppTopBar), findsOneWidget);
    expect(find.byType(AppTopBarAction), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(IconButton).last).dy,
      greaterThanOrEqualTo(24),
    );
    expect(find.text('Sunny apartment near the park'), findsOneWidget);
    expect(find.text('This listing is no longer available.'), findsOneWidget);

    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    expect(archived, 1);
  });
}
