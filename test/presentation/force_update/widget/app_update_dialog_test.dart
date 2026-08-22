import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/force_update/models/app_update_info.dart';
import 'package:ideal_mobile/presentation/force_update/widget/app_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../test_helpers.dart';

void main() {
  const normalInfo = AppUpdateInfo(
    updateType: AppUpdateType.normal,
    currentVersion: '0.1.0',
    latestVersion: '1.0.0',
    storeUrl: 'https://play.google.com/store/apps/details?id=com.ideal.mobile',
  );

  const criticalInfo = AppUpdateInfo(
    updateType: AppUpdateType.critical,
    currentVersion: '0.1.0',
    latestVersion: '1.0.0',
    storeUrl: 'https://play.google.com/store/apps/details?id=com.ideal.mobile',
  );

  group('AppUpdateDialog - Normal Update', () {
    testWidgets('renders dialog contents and both action buttons', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const AppUpdateDialog(updateInfo: normalInfo),
      );
      await tester.pumpAndSettle();

      expect(find.text('It’s time to Update!'), findsOneWidget);
      expect(
        find.text(
          'The version you are using is old, to continue using you '
          'need to update the latest version in order to experience '
          'new features.',
        ),
        findsOneWidget,
      );
      expect(find.text('Update Now'), findsOneWidget);
      expect(find.text('Skip Update'), findsOneWidget);
    });

    testWidgets('tapping Skip Update dismisses the dialog', (tester) async {
      bool? dialogResult;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                dialogResult = await AppUpdateDialog.show(
                  context,
                  updateInfo: normalInfo,
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AppUpdateDialog), findsOneWidget);

      await tester.tap(find.text('Skip Update'));
      await tester.pumpAndSettle();

      expect(find.byType(AppUpdateDialog), findsNothing);
      expect(dialogResult, isFalse);
    });

    testWidgets(
      'tapping Update Now with successful launch dismisses normal dialog',
      (tester) async {
        bool? dialogResult;
        Uri? launchedUri;
        LaunchMode? launchedMode;

        await tester.runWidgetTest(
          child: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  dialogResult = await AppUpdateDialog.show(
                    context,
                    updateInfo: normalInfo,
                    launchUrlHandler: (uri, mode) async {
                      launchedUri = uri;
                      launchedMode = mode;
                      return true;
                    },
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update Now'));
        await tester.pumpAndSettle();

        expect(
          launchedUri,
          Uri.parse(
            'https://play.google.com/store/apps/details?id=com.ideal.mobile',
          ),
        );
        expect(launchedMode, LaunchMode.externalApplication);
        expect(find.byType(AppUpdateDialog), findsNothing);
        expect(dialogResult, isTrue);
      },
    );

    testWidgets(
      'tapping Update Now with failed launch keeps dialog visible with error',
      (tester) async {
        await tester.runWidgetTest(
          child: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await AppUpdateDialog.show(
                    context,
                    updateInfo: normalInfo,
                    launchUrlHandler: (uri, mode) async => false,
                  );
                },
                child: const Text('Show Dialog'),
              );
            },
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update Now'));
        await tester.pumpAndSettle();

        expect(find.byType(AppUpdateDialog), findsOneWidget);
        expect(
          find.text('Could not launch store link'),
          findsAtLeastNWidgets(1),
        );
      },
    );
  });

  group('AppUpdateDialog - Critical Update', () {
    testWidgets('renders only Update Now button and no Skip button', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const AppUpdateDialog(updateInfo: criticalInfo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update Now'), findsOneWidget);
      expect(find.text('Skip Update'), findsNothing);
    });

    testWidgets('successful launch keeps critical dialog open', (tester) async {
      Uri? launchedUri;

      await tester.runWidgetTest(
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await AppUpdateDialog.show(
                  context,
                  updateInfo: criticalInfo,
                  launchUrlHandler: (uri, mode) async {
                    launchedUri = uri;
                    return true;
                  },
                );
              },
              child: const Text('Show Dialog'),
            );
          },
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Now'));
      await tester.pumpAndSettle();

      expect(
        launchedUri,
        Uri.parse(
          'https://play.google.com/store/apps/details?id=com.ideal.mobile',
        ),
      );
      // Dialog remains visible!
      expect(find.byType(AppUpdateDialog), findsOneWidget);
    });
  });
}
