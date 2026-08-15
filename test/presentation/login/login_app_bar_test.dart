import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/login/widgets/login_app_bar.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('delegates to the shared page bar and keeps the branded logo', (
    tester,
  ) async {
    await tester.runWidgetTest(
      child: const Scaffold(
        appBar: LoginAppBar(removeLeading: false),
        body: SizedBox.shrink(),
      ),
    );

    expect(find.byType(AppTopBar), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });

  testWidgets('keeps the fixed extra action below the status-bar inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);

    await tester.runWidgetTest(
      child: const Scaffold(
        appBar: LoginAppBar(
          rightAction: SizedBox(
            key: ValueKey('login-extra-action'),
            width: 44,
            height: 44,
          ),
        ),
        body: SizedBox.shrink(),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('login-extra-action'))).dy,
      24 + 10,
    );
    expect(
      tester.getTopLeft(find.byType(AppButton)).dy,
      greaterThanOrEqualTo(24),
    );
  });
}
