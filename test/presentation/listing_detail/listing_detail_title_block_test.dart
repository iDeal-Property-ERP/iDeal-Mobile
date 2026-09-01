import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_title_block.dart';

import '../../test_helpers.dart';
import 'listing_detail_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListingDetailTitleBlock', () {
    testWidgets('renders landmark when present', (tester) async {
      final detail = buildListingDetail(landmark: 'Near Grand Mir Hotel');

      await tester.runWidgetTest(
        child: SingleChildScrollView(
          child: ListingDetailTitleBlock(detail: detail),
        ),
      );

      expect(
        find.text('Near Grand Mir Hotel', findRichText: true),
        findsNothing,
      );
      expect(
        find.textContaining('Near Grand Mir Hotel', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('omits landmark row when landmark is null', (tester) async {
      final detail = buildListingDetail();

      await tester.runWidgetTest(
        child: SingleChildScrollView(
          child: ListingDetailTitleBlock(detail: detail),
        ),
      );

      expect(
        find.textContaining('Near Grand Mir Hotel', findRichText: true),
        findsNothing,
      );
    });
  });
}
