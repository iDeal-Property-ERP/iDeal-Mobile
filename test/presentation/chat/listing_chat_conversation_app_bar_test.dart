import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_avatar.dart';
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

  testWidgets(
    'vertically centers avatar, title, back button, and menu action together',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);

      await tester.runWidgetTest(
        child: const Scaffold(
          appBar: ListingChatConversationAppBar(
            listing: ChatListingRef(
              id: 42,
              title: 'Sunny apartment near the park',
              coverImageUrl: null,
              price: 520,
              currency: 'USD',
              isAvailable: true,
            ),
            listingIsAvailable: true,
            isArchived: false,
            isMuted: false,
          ),
        ),
      );

      final backButtonCenter = tester.getCenter(
        find.byIcon(TablerIcons.arrow_left),
      );
      final menuButtonCenter = tester.getCenter(find.byTooltip('Show menu'));
      final avatarCenter = tester.getCenter(find.byType(ChatAvatar));
      final titleCenter = tester.getCenter(
        find.text('Sunny apartment near the park'),
      );

      // Expected vertical center is top inset (24) + AppTopBar.height (56) / 2 = 52.0
      expect(backButtonCenter.dy, 52.0);
      expect(menuButtonCenter.dy, 52.0);
      expect(avatarCenter.dy, 52.0);
      expect(titleCenter.dy, 52.0);

      final topBarMaterial = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AppTopBar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(topBarMaterial.color, isNotNull);
    },
  );
}
