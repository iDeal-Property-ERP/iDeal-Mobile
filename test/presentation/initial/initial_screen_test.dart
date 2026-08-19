import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/initialize_app.dart';
import 'package:ideal_mobile/presentation/initial/initial_screen.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../test_helpers.dart';

class MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(() {
    registerFallbackValue(const LoginWithPhoneNumberRoute());
  });

  group('Initial screen body', () {
    testWidgets('stays visible while app startup is pending', (tester) async {
      final startupCompleter = Completer<void>();

      await tester.runWidgetTest(
        child: AppStartupScope(
          startupFuture: startupCompleter.future,
          child: const InitialScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      _expectSplashContents(tester);
      expect(find.byType(InitialScreen), findsOneWidget);
    });

    testWidgets('renders the Login branding and loader in light theme', (
      tester,
    ) async {
      await tester.runWidgetTest(child: const InitialScreenBody());
      await tester.pump(const Duration(milliseconds: 250));

      _expectSplashContents(tester);
    });

    testWidgets('renders the Login branding and loader in dark theme', (
      tester,
    ) async {
      await tester.runWidgetTest(
        child: const InitialScreenBody(),
        theme: AppThemeEnum.DarkTheme,
      );
      await tester.pump(const Duration(milliseconds: 250));

      _expectSplashContents(tester);
    });
  });

  group('Initial startup routing', () {
    late MockStackRouter router;
    setUp(() async {
      _setMockPreferences({});
      await sl.reset();

      router = MockStackRouter();
      when(() => router.replace(any())).thenAnswer((_) async => null);
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('unauthenticated user routes to Login once', (tester) async {
      await _pumpRoutableInitialScreen(tester, router);

      final route = verify(() => router.replace(captureAny())).captured.single;
      expect(route, isA<LoginWithPhoneNumberRoute>());
    });

    testWidgets('skipped login routes to Home once', (tester) async {
      _setMockPreferences({PrefKeys.kSkippedLogin: true});

      await _pumpRoutableInitialScreen(tester, router);

      final route = verify(() => router.replace(captureAny())).captured.single;
      expect(route, isA<HomeRoute>());
    });

    testWidgets('authenticated user routes to Home once', (tester) async {
      _setMockPreferences({
        PrefKeys.kUserDetails: '{"accessToken":"backend-session"}',
      });

      await _pumpRoutableInitialScreen(tester, router);

      final route = verify(() => router.replace(captureAny())).captured.single;
      expect(route, isA<HomeRoute>());
    });
  });
}

void _setMockPreferences(Map<String, Object> values) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(values);
  Prefs.init();
}

Future<void> _pumpRoutableInitialScreen(
  WidgetTester tester,
  StackRouter router,
) async {
  await tester.runWidgetTest(
    child: StackRouterScope(
      controller: router,
      stateHash: 0,
      child: AppStartupScope(
        startupFuture: Future<void>.value(),
        child: const InitialScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}

void _expectSplashContents(WidgetTester tester) {
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  expect(scaffold.backgroundColor, Colors.black);
  expect(find.text('iDeal'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  final loader = tester.widget<SizedBox>(
    find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        )
        .first,
  );
  expect(loader.width, 28);
  expect(loader.height, 28);

  final logo = tester.widget<Image>(find.byType(Image));
  expect(logo.image, isA<AssetImage>());
  expect((logo.image as AssetImage).assetName, Assets.icons.loginLogo.path);
  expect(logo.fit, BoxFit.contain);
  expect(logo.filterQuality, FilterQuality.high);
}
