import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/home/widgets/tariff_filter_sheet.dart';

import '../../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TariffFilterSheet', () {
    testWidgets(
      'renders Standard, Comfort, Premium and checkmark on selection',
      (tester) async {
        String? selected;

        await tester.runWidgetTest(
          child: Scaffold(
            body: TariffFilterSheet(
              initialTariff: 'comfort',
              onTariffSelected: (t) => selected = t,
            ),
          ),
        );

        expect(find.text('Tariff'), findsOneWidget);
        expect(find.text('Standard'), findsOneWidget);
        expect(find.text('Comfort'), findsOneWidget);
        expect(find.text('Premium'), findsOneWidget);
        expect(find.byIcon(TablerIcons.check), findsOneWidget);

        await tester.tap(find.text('Premium'));
        expect(selected, 'premium');
      },
    );

    testWidgets('tapping selected tariff again deselects (clears) it', (
      tester,
    ) async {
      String? selected = 'comfort';

      await tester.runWidgetTest(
        child: Scaffold(
          body: TariffFilterSheet(
            initialTariff: 'comfort',
            onTariffSelected: (t) => selected = t,
          ),
        ),
      );

      await tester.tap(find.text('Comfort'));
      expect(selected, isNull);
    });
  });
}
