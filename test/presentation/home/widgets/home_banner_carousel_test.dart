import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_banner_carousel.dart';

import '../../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeBannerCarousel Widget Tests', () {
    testWidgets('renders all initial banner elements and indicators', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const Scaffold(body: HomeBannerCarousel()),
      );

      // Verify carousel and indicator exist
      expect(find.byKey(keys.homePage.bannerCarouselKey), findsOneWidget);
      expect(find.byKey(keys.homePage.bannerIndicatorKey), findsOneWidget);

      // First banner is visible by default
      expect(find.text('100% Actual Listings'), findsOneWidget);
      expect(
        find.text(
          'Whatever you see is available. '
          'No expired listings or outdated offers.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(TablerIcons.circle_check), findsOneWidget);

      // Find the 4 indicator AnimatedContainer dots
      final indicatorFinder = find.descendant(
        of: find.byKey(keys.homePage.bannerIndicatorKey),
        matching: find.byType(AnimatedContainer),
      );
      expect(indicatorFinder, findsNWidgets(4));

      // First dot should be active (width 24), other 3 inactive (width 6)
      final firstDot = tester.widget<AnimatedContainer>(indicatorFinder.at(0));
      final secondDot = tester.widget<AnimatedContainer>(indicatorFinder.at(1));
      final thirdDot = tester.widget<AnimatedContainer>(indicatorFinder.at(2));
      final fourthDot = tester.widget<AnimatedContainer>(indicatorFinder.at(3));

      expect(firstDot.constraints?.maxWidth ?? 24.0, 24.0);
      expect(secondDot.constraints?.maxWidth ?? 6.0, 6.0);
      expect(thirdDot.constraints?.maxWidth ?? 6.0, 6.0);
      expect(fourthDot.constraints?.maxWidth ?? 6.0, 6.0);
    });

    testWidgets(
      'manual swipe changes banner and updates active indicator dot',
      (tester) async {
        await tester.runWidgetTest(
          child: const Scaffold(body: HomeBannerCarousel()),
        );

        expect(find.text('100% Actual Listings'), findsOneWidget);

        // Swipe left to go to banner 2
        await tester.fling(
          find.byKey(keys.homePage.bannerCarouselKey),
          const Offset(-400, 0),
          1000,
        );
        await tester.pumpAndSettle();

        // Banner 2 should now be visible
        expect(find.text('Verified Properties'), findsOneWidget);
        expect(
          find.text(
            'Our team inspects each home to '
            'ensure photos and terms match reality.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(TablerIcons.shield_check), findsOneWidget);

        // Dot 2 should now be active
        final indicatorFinder = find.descendant(
          of: find.byKey(keys.homePage.bannerIndicatorKey),
          matching: find.byType(AnimatedContainer),
        );
        final firstDot = tester.widget<AnimatedContainer>(
          indicatorFinder.at(0),
        );
        final secondDot = tester.widget<AnimatedContainer>(
          indicatorFinder.at(1),
        );

        expect(firstDot.constraints?.maxWidth ?? 6.0, 6.0);
        expect(secondDot.constraints?.maxWidth ?? 24.0, 24.0);
      },
    );

    testWidgets('manual swipe stops at the last banner', (tester) async {
      final pageController = PageController();
      await tester.runWidgetTest(
        child: Scaffold(
          body: HomeBannerCarousel(pageController: pageController),
        ),
      );

      // Swipe through to banner 4 (index 3)
      for (int i = 0; i < 3; i++) {
        await tester.fling(
          find.byKey(keys.homePage.bannerCarouselKey),
          const Offset(-400, 0),
          1000,
        );
        await tester.pumpAndSettle();
      }

      expect(find.text('Official Legal Agreements'), findsOneWidget);
      expect(pageController.page?.round(), 3);

      // Attempt to drag past the last banner
      await tester.fling(
        find.byKey(keys.homePage.bannerCarouselKey),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Still at banner 4 (cannot manual swipe past end)
      expect(find.text('Official Legal Agreements'), findsOneWidget);
      expect(pageController.page?.round(), 3);
    });

    testWidgets('auto-slides every 5 seconds', (tester) async {
      await tester.runWidgetTest(
        child: const Scaffold(body: HomeBannerCarousel()),
      );

      expect(find.text('100% Actual Listings'), findsOneWidget);

      // Advance time by 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Now at banner 2
      expect(find.text('Verified Properties'), findsOneWidget);

      // Advance another 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Now at banner 3
      expect(find.text('We Arrange Viewings'), findsOneWidget);

      // Advance another 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Now at banner 4
      expect(find.text('Official Legal Agreements'), findsOneWidget);
    });

    testWidgets(
      'auto-slide loops back to banner 1 after reaching the last banner',
      (tester) async {
        final pageController = PageController();
        await tester.runWidgetTest(
          child: Scaffold(
            body: HomeBannerCarousel(pageController: pageController),
          ),
        );

        // Advance to banner 4 (index 3) through 3 intervals of 5s
        for (int i = 0; i < 3; i++) {
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
        }
        expect(find.text('Official Legal Agreements'), findsOneWidget);
        expect(pageController.page?.round(), 3);

        // Next 5-second tick triggers loop rewind back to banner 1 (index 0)
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();

        expect(find.text('100% Actual Listings'), findsOneWidget);
        expect(pageController.page?.round(), 0);
      },
    );

    testWidgets('user touch interaction resets 5-second auto-slide timer', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const Scaffold(body: HomeBannerCarousel()),
      );

      expect(find.text('100% Actual Listings'), findsOneWidget);

      // Wait 3 seconds (not yet at 5s)
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('100% Actual Listings'), findsOneWidget);

      // User performs manual swipe to banner 2 at second 3
      await tester.fling(
        find.byKey(keys.homePage.bannerCarouselKey),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('Verified Properties'), findsOneWidget);

      // 3 seconds later (total 6s since start, 3s since swipe) -> banner 2
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Verified Properties'), findsOneWidget);

      // Another 2 seconds later (full 5s since swipe) -> advances to banner 3
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('We Arrange Viewings'), findsOneWidget);
    });

    testWidgets('empty banners list renders SizedBox.shrink', (tester) async {
      await tester.runWidgetTest(
        child: const Scaffold(
          body: HomeBannerCarousel(banners: <HomeBannerItem>[]),
        ),
      );

      expect(find.byKey(keys.homePage.bannerCarouselKey), findsNothing);
      expect(find.byKey(keys.homePage.bannerIndicatorKey), findsNothing);
    });
  });
}
