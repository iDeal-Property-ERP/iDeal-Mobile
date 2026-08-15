import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_hero.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

import '../../test_helpers.dart';
import 'listing_detail_test_helpers.dart';

void main() {
  testWidgets(
    'hero controls use overlay actions and preserve unwired actions',
    (tester) async {
      tester.view.physicalSize = const Size(375, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);

      await tester.runWidgetTest(
        child: Scaffold(body: ListingDetailHero(detail: buildListingDetail())),
      );

      final actions = tester.widgetList<AppTopBarAction>(
        find.byType(AppTopBarAction),
      );
      expect(actions, hasLength(3));
      expect(
        actions.every((action) => action.style == AppTopBarActionStyle.overlay),
        isTrue,
      );
      expect(tester.getTopLeft(find.byType(AppTopBarAction).first).dy, 36);

      await tester.tap(find.byTooltip('Share'));
      await tester.tap(find.byTooltip('Save'));
      expect(tester.takeException(), isNull);
    },
  );
}
