import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/channel_picker_sheet.dart';

import '../../../test_helpers.dart';

void main() {
  group('ChannelPickerSheet', () {
    testWidgets('renders both buttons when both channels are available', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const Scaffold(
          body: ChannelPickerSheet(phoneNumber: '+998901234567'),
        ),
      );

      expect(find.text('+998901234567'), findsOneWidget);
      expect(find.byType(ChannelPickerSheet), findsOneWidget);
      // Finds both buttons
      expect(find.textContaining('Telegram'), findsOneWidget);
      expect(find.textContaining('SMS'), findsOneWidget);
    });

    testWidgets(
      'renders only telegram button when only telegram is available',
      (tester) async {
        await tester.runWidgetTest(
          child: const Scaffold(
            body: ChannelPickerSheet(
              phoneNumber: '+998901234567',
              availableChannels: ['telegram'],
            ),
          ),
        );

        expect(find.textContaining('Telegram'), findsOneWidget);
        expect(find.textContaining('SMS'), findsNothing);
      },
    );

    testWidgets('renders only sms button when only sms is available', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const Scaffold(
          body: ChannelPickerSheet(
            phoneNumber: '+998901234567',
            availableChannels: ['sms'],
          ),
        ),
      );

      expect(find.textContaining('Telegram'), findsNothing);
      expect(find.textContaining('SMS'), findsOneWidget);
    });
  });
}
