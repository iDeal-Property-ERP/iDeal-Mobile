import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_listing_rail.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

import '../../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ListingCard testListing(int id, {String title = 'Sunny apartment'}) =>
      ListingCard(
        id: id,
        propertyId: id + 100,
        title: title,
        district: 'Yunusobod',
        address: 'Amir Temur 42',
        propertyType: 'apartment',
        rooms: 2,
        areaSqm: 65,
        floor: 3,
        totalFloors: 9,
        furnishing: 'furnished',
        price: 520,
        currency: 'USD',
        tariff: 'comfort',
        isVerified: true,
        isFeatured: false,
        score: 9.2,
        reviewCount: 10,
        coverImageUrl: null,
        mapLat: null,
        mapLon: null,
      );

  group('HomeListingRail', () {
    testWidgets('renders empty when listings list is empty', (tester) async {
      await tester.runWidgetTest(
        child: HomeListingRail(
          title: 'Recent searches',
          listings: const [],
          onListingTap: (_) {},
          onFavoriteToggle: (_) {},
        ),
      );

      expect(find.text('Recent searches'), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('renders title, subtitle, and cards when listings exist', (
      tester,
    ) async {
      final items = [
        testListing(1, title: 'Sunny flat'),
        testListing(2, title: 'City view home'),
      ];

      var tappedListingId = 0;
      var toggledFavoriteId = 0;

      await tester.runWidgetTest(
        child: HomeListingRail(
          title: 'From your recent searches',
          contextSubtitle: 'Based on Yunusobod and your last filters',
          listings: items,
          onListingTap: (l) => tappedListingId = l.id,
          onFavoriteToggle: (id) => toggledFavoriteId = id,
        ),
      );

      expect(find.text('From your recent searches'), findsOneWidget);
      expect(
        find.text('Based on Yunusobod and your last filters'),
        findsOneWidget,
      );
      expect(find.text('Sunny flat'), findsOneWidget);
      expect(find.text('City view home'), findsOneWidget);

      await tester.tap(find.text('Sunny flat'));
      expect(tappedListingId, 1);

      await tester.tap(find.byIcon(TablerIcons.heart).first);
      expect(toggledFavoriteId, 1);
    });

    testWidgets('renders title without subtitle when contextSubtitle is null', (
      tester,
    ) async {
      final items = [testListing(1, title: 'Sunny flat')];

      await tester.runWidgetTest(
        child: HomeListingRail(
          title: 'Recommended for you',
          listings: items,
          onListingTap: (_) {},
          onFavoriteToggle: (_) {},
        ),
      );

      expect(find.text('Recommended for you'), findsOneWidget);
      expect(find.text('Sunny flat'), findsOneWidget);
    });
  });
}
