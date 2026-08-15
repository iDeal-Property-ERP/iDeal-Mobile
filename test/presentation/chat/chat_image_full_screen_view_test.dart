import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_image_full_screen_view.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

import '../../test_helpers.dart';

void main() {
  testWidgets('fullscreen close action is an overlay control below the inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24);
    addTearDown(tester.view.reset);

    await tester.runWidgetTest(
      child: const ChatImageFullScreenView(path: '/tmp/chat-image.jpg'),
    );

    final action = find.byType(AppTopBarAction);
    expect(action, findsOneWidget);
    expect(tester.getTopLeft(action).dy, 36);
    expect(tester.getSize(action), const Size(44, 44));
    expect(
      tester.widget<AppTopBarAction>(action).style,
      AppTopBarActionStyle.overlay,
    );

    await tester.tap(find.byTooltip('Close'));
    expect(tester.takeException(), isNull);
  });
}
