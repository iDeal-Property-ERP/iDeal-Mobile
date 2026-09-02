import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_about.dart';

import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListingDetailAbout', () {
    testWidgets('renders empty when description is empty or whitespace', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const ListingDetailAbout(description: '   \n  '),
      );

      expect(find.byType(ListingDetailAbout), findsOneWidget);
      expect(find.text('About this home'), findsNothing);
    });

    testWidgets('renders rich HTML formatted content with header', (
      tester,
    ) async {
      const richHtml =
          '<h3>Modern Space</h3> '
          '<p>Bright home with <strong>renovated</strong> interior and <em>quiet</em> view.</p> '
          '<ul><li>First amenity</li><li>Second amenity</li></ul> '
          '<ol><li>Step one</li><li>Step two</li></ol>';

      await tester.runWidgetTest(
        child: const ListingDetailAbout(description: richHtml),
      );

      expect(find.text('About this home'), findsOneWidget);
      expect(find.text('Modern Space'), findsOneWidget);
      expect(find.text('First amenity'), findsOneWidget);
      expect(find.text('Second amenity'), findsOneWidget);
      expect(find.text('Step one'), findsOneWidget);
      expect(find.text('Step two'), findsOneWidget);
      expect(find.text('• '), findsNWidgets(2));
      expect(find.text('1. '), findsOneWidget);
      expect(find.text('2. '), findsOneWidget);
    });

    testWidgets('renders plain text gracefully as paragraph', (tester) async {
      const plainText = 'A simple plain text description of the property.';

      await tester.runWidgetTest(
        child: const ListingDetailAbout(description: plainText),
      );

      expect(find.text('About this home'), findsOneWidget);
      expect(find.text(plainText), findsOneWidget);
    });

    testWidgets('does not contain read more or show less toggles', (
      tester,
    ) async {
      const longHtml =
          '<p>Paragraph 1 with long content that would have been clamped previously.</p> '
          '<p>Paragraph 2 with even more detail.</p>';

      await tester.runWidgetTest(
        child: const ListingDetailAbout(description: longHtml),
      );

      expect(find.text('Read more'), findsNothing);
      expect(find.text('Show less'), findsNothing);
    });
  });
}
