import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('primary buttons keep white text without an override', (
    tester,
  ) async {
    await tester.runWidgetTest(
      child: const Scaffold(
        body: AppButton(
          label: 'Save',
          size: AppButtonSize.large,
          shouldSetFullWidth: true,
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Save'));
    expect(label.style?.color, Colors.white);
  });
}
