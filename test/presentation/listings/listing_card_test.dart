import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListingCardTile', () {
    testWidgets('formats USD, UZS, and null prices', (tester) async {
      await _pumpCard(tester, _listing());
      expect(find.text(r'$520'), findsOneWidget);

      await _pumpCard(tester, _listing(currency: 'UZS'));
      expect(find.text('520 UZS'), findsOneWidget);

      await _pumpCard(tester, _listing(price: null));
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('only renders the rating row for a positive score', (
      tester,
    ) async {
      await _pumpCard(tester, _listing(score: 0));
      expect(find.byIcon(TablerIcons.star_filled), findsNothing);

      await _pumpCard(tester, _listing());
      expect(find.byIcon(TablerIcons.star_filled), findsOneWidget);
      expect(find.text('9.2'), findsOneWidget);
    });

    testWidgets('omits the floor segment when floor is null', (tester) async {
      await _pumpCard(tester, _listing(floor: null));

      expect(find.text('Yunusobod · 2 rooms · 68 m²'), findsOneWidget);
      expect(find.textContaining('Floor'), findsNothing);
    });

    testWidgets('shows the floor alone when total floors are unknown', (
      tester,
    ) async {
      await _pumpCard(tester, _listing(totalFloors: null));

      // A dedicated l10n string, not a patched listings_floor_of: Uzbek renders
      // the total before the floor, so string surgery corrupts the number.
      expect(
        find.text('Yunusobod · 2 rooms · 68 m² · Floor 4'),
        findsOneWidget,
      );
    });

    testWidgets('renders a clean meta line when optional facts are null', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        _listing(rooms: null, areaSqm: null, floor: null, totalFloors: null),
      );

      expect(find.text('Yunusobod'), findsOneWidget);
      expect(find.textContaining('·'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
    });

    testWidgets('localizes tariff labels', (tester) async {
      await _pumpCard(tester, _listing());

      expect(find.text('Comfort'), findsOneWidget);
      expect(find.text('comfort'), findsNothing);
    });

    testWidgets('fires favorite callback and renders the filled icon', (
      tester,
    ) async {
      var callbackCount = 0;
      var isFavorite = false;

      await tester.runWidgetTest(
        child: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 388,
              child: ListingCardTile(
                listing: _listing(),
                isFavorite: isFavorite,
                onFavoriteToggle: () {
                  callbackCount++;
                  setState(() => isFavorite = !isFavorite);
                },
              ),
            );
          },
        ),
      );

      expect(find.byIcon(TablerIcons.heart), findsOneWidget);
      await tester.tap(find.byIcon(TablerIcons.heart));
      await tester.pump();

      expect(callbackCount, 1);
      expect(find.byIcon(TablerIcons.heart_filled), findsOneWidget);
    });
  });

  testExecutable(() {
    goldenTest(
      'Listing card light and dark themes',
      fileName: 'listing_card',
      pumpBeforeTest: precacheImages,
      builder: () {
        final listing = _listing();

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'listing_card Light Theme',
              addScaffold: true,
              child: SizedBox(
                width: 379,
                child: ListingCardTile(
                  listing: listing,
                  isFavorite: false,
                  onFavoriteToggle: _noop,
                ),
              ),
            ),
            createTestScenario(
              name: 'listing_card Dark Theme',
              addScaffold: true,
              theme: AppThemeEnum.DarkTheme,
              child: SizedBox(
                width: 379,
                child: ListingCardTile(
                  listing: listing,
                  isFavorite: false,
                  onFavoriteToggle: _noop,
                ),
              ),
            ),
          ],
        );
      },
    );
  });
}

Future<void> _pumpCard(WidgetTester tester, ListingCard listing) async {
  await tester.runWidgetTest(
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: 388,
          child: ListingCardTile(
            listing: listing,
            isFavorite: false,
            onFavoriteToggle: _noop,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ListingCard _listing({
  String? district = 'Yunusobod',
  String address = '12-kvartal',
  int? rooms = 2,
  int? areaSqm = 68,
  int? floor = 4,
  int? totalFloors = 9,
  double? price = 520,
  String currency = 'USD',
  String tariff = 'comfort',
  double score = 9.2,
}) {
  return ListingCard(
    id: 12,
    propertyId: 34,
    title: 'Sunny apartment near the park',
    district: district,
    address: address,
    propertyType: 'apartment',
    rooms: rooms,
    areaSqm: areaSqm,
    floor: floor,
    totalFloors: totalFloors,
    furnishing: 'furnished',
    price: price,
    currency: currency,
    tariff: tariff,
    isVerified: true,
    isFeatured: false,
    score: score,
    reviewCount: 14,
    coverImageUrl: 'https://example.com/photo.jpg',
    mapLat: 41.36,
    mapLon: 69.28,
  );
}

void _noop() {}
