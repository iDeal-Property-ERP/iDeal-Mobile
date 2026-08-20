import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_state.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/profile_screen.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_details.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockStackRouter extends Mock implements StackRouter {}

class FakePageRouteInfo extends Fake implements PageRouteInfo<Object?> {}

const testProfile = MobileUserProfile(
  id: 1,
  firstName: 'Test',
  lastName: 'User',
  patronymic: null,
  email: 'test@example.com',
  phone: '+998901234567',
  nationality: null,
  avatarUrl: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    registerFallbackValue(FakePageRouteInfo());
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'tenantIdTest',
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
  });

  // Widget tests
  group('Profile Page', () {
    testWidgets('Profile page', (tester) async {
      //arrange
      final mockProfileBloc = MockProfileBloc();
      when(
        () => mockProfileBloc.state,
      ).thenReturn(const ProfileState.test(profile: testProfile));

      //act
      await tester.runWidgetTest(
        providers: [BlocProvider<ProfileBloc>.value(value: mockProfileBloc)],
        child: const ProfileScreenBody(), // Use ProfileScreenBody instead of
        // ProfileScreen to avoid duplicate BlocProvider
      );

      // assert
      expect(find.byType(ProfileScreenBody), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('redirects to home tab and replaces route on SignOutState', (
      tester,
    ) async {
      final profileBloc = MockProfileBloc();
      final homeBloc = MockHomeBloc();
      final router = MockStackRouter();

      final profileStreamController =
          StreamController<ProfileState>.broadcast();
      addTearDown(profileStreamController.close);

      when(
        () => profileBloc.state,
      ).thenReturn(const ProfileState.test(profile: testProfile));
      when(
        () => profileBloc.stream,
      ).thenAnswer((_) => profileStreamController.stream);
      when(
        () => homeBloc.state,
      ).thenReturn(HomeState.test(currentBottomNavIndex: 3));
      when(() => router.replaceAll(any())).thenAnswer((_) async {});

      await tester.runWidgetTest(
        providers: [
          BlocProvider<ProfileBloc>.value(value: profileBloc),
          BlocProvider<HomeBloc>.value(value: homeBloc),
        ],
        child: StackRouterScope(
          controller: router,
          stateHash: 0,
          child: const ProfileScreenBody(),
        ),
      );

      profileStreamController.add(SignOutState());
      await tester.pumpAndSettle();

      verify(
        () => homeBloc.add(const BottomNavBarIndexChangedEvent(index: 0)),
      ).called(1);
      final routes =
          verify(() => router.replaceAll(captureAny())).captured.single
              as List<PageRouteInfo>;
      expect(routes, hasLength(1));
      expect(routes.first, isA<HomeRoute>());
    });

    testWidgets('uses the localized Profile root title', (tester) async {
      for (final scenario in const [
        (Locale('en'), 'Profile'),
        (Locale('ru'), 'Профиль'),
        (Locale('uz'), 'Profil'),
      ]) {
        final profileBloc = MockProfileBloc();
        when(
          () => profileBloc.state,
        ).thenReturn(const ProfileState.test(profile: testProfile));

        await tester.pumpWidget(
          Sizer(
            builder: (context, orientation, screenType) {
              return MaterialApp(
                locale: scenario.$1,
                theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: BlocProvider<ProfileBloc>.value(
                  value: profileBloc,
                  child: const ProfileScreenBody(),
                ),
              );
            },
          ),
        );
        await tester.pump();

        expect(find.text(scenario.$2), findsOneWidget);
      }
    });

    testWidgets('ProfileDetails renders name and phone but not email', (
      tester,
    ) async {
      final profileBloc = MockProfileBloc();
      when(
        () => profileBloc.state,
      ).thenReturn(const ProfileState.test(profile: testProfile));

      await tester.runWidgetTest(
        providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
        child: const ProfileDetails(),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('+998901234567'), findsOneWidget);
      expect(find.text('test@example.com'), findsNothing);
    });

    testWidgets('ProfileDetails renders phone when name is empty', (
      tester,
    ) async {
      final profileBloc = MockProfileBloc();
      when(() => profileBloc.state).thenReturn(
        const ProfileState.test(
          profile: MobileUserProfile(
            id: 1,
            firstName: '',
            lastName: null,
            patronymic: null,
            phone: '+998901234567',
            nationality: null,
            avatarUrl: null,
          ),
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
        child: const ProfileDetails(),
      );

      expect(find.text('+998901234567'), findsOneWidget);
    });

    // Golden tests
    testExecutable(() {
      group('Profile Page UI test', () {
        goldenTest(
          'Profile page',
          fileName: 'profile_page',
          pumpBeforeTest: precacheImages,
          builder: () {
            //arrange

            final mockProfileBloc = MockProfileBloc();
            when(
              () => mockProfileBloc.state,
            ).thenReturn(const ProfileState.test(profile: testProfile));

            // act, assert
            return GoldenTestGroup(
              // Fixes "LayoutBuilder does not support returning
              // intrinsic dimensions" error
              columnWidthBuilder: (_) =>
                  const FixedColumnWidth(pixel5DeviceWidth),
              children: [
                createTestScenario(
                  name: 'Profile page Light Theme',
                  child: const ProfileScreenBody(),
                  addScaffold: true,
                  providers: [
                    BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                  ],
                ),
                createTestScenario(
                  name: 'Profile page Dark Theme',
                  child: const ProfileScreenBody(),
                  addScaffold: true,
                  theme: AppThemeEnum.DarkTheme,
                  providers: [
                    BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                  ],
                ),
                createTestScenario(
                  name: 'Profile details Light Theme',
                  child: const ProfileDetails(),
                  addScaffold: true,
                  providers: [
                    BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                  ],
                ),
                createTestScenario(
                  name: 'Profile details Dark Theme',
                  child: const ProfileDetails(),
                  addScaffold: true,
                  theme: AppThemeEnum.DarkTheme,
                  providers: [
                    BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                  ],
                ),
              ],
            );
          },
        );
      });
    });
  });

  testExecutable(() {
    goldenTest(
      'Profile details with long name',
      fileName: 'profile_details_long_name',
      pumpBeforeTest: precacheImages,
      builder: () {
        // arrange
        final profileBloc = MockProfileBloc();
        when(() => profileBloc.state).thenReturn(
          const ProfileState.test(
            profile: MobileUserProfile(
              id: 2,
              firstName: 'This is very long name for testing purpose only',
              lastName: '',
              patronymic: null,
              email: 'x5t4T_wzkrhzj_45454_qweurnzzlahrnzgkhf@example.com',
              phone: null,
              nationality: null,
              avatarUrl: null,
            ),
          ),
        );

        // act, assert
        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'Profile details with long name Light Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
            ),
            createTestScenario(
              name: 'Profile details with long name Dark Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              theme: AppThemeEnum.DarkTheme,
              providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
            ),
          ],
        );
      },
    );
  });

  testExecutable(() {
    goldenTest(
      'Regular User Profile details',
      fileName: 'profile_details_regular_user',
      pumpBeforeTest: precacheImages,
      builder: () {
        // arrange
        final profileBloc = MockProfileBloc();
        when(
          () => profileBloc.state,
        ).thenReturn(const ProfileState.test(profile: testProfile));

        // act, assert
        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'Regular User Profile details Light Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
            ),
            createTestScenario(
              name: 'Regular User Profile details Dark Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              theme: AppThemeEnum.DarkTheme,
              providers: [BlocProvider<ProfileBloc>.value(value: profileBloc)],
            ),
          ],
        );
      },
    );
  });

  testExecutable(() {
    goldenTest(
      'Profile details UI test',
      fileName: 'profile_details',
      pumpBeforeTest: precacheImages,
      builder: () {
        // arrange
        final proUserProfileBloc = MockProfileBloc();
        when(
          () => proUserProfileBloc.state,
        ).thenReturn(const ProfileState.test(profile: testProfile));

        final nonProUserProfileBloc = MockProfileBloc();
        when(
          () => nonProUserProfileBloc.state,
        ).thenReturn(const ProfileState.test(profile: testProfile));

        // act, assert
        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'Pro User Profile details Light Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              providers: [
                BlocProvider<ProfileBloc>.value(value: proUserProfileBloc),
              ],
            ),
            createTestScenario(
              name: 'Pro User Profile details Dark Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              theme: AppThemeEnum.DarkTheme,
              providers: [
                BlocProvider<ProfileBloc>.value(value: proUserProfileBloc),
              ],
            ),
            createTestScenario(
              name: 'Non-Pro User Profile details Light Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              providers: [
                BlocProvider<ProfileBloc>.value(value: nonProUserProfileBloc),
              ],
            ),
            createTestScenario(
              name: 'Non-Pro User Profile details Dark Theme',
              child: const ProfileDetails(),
              addScaffold: true,
              theme: AppThemeEnum.DarkTheme,
              providers: [
                BlocProvider<ProfileBloc>.value(value: nonProUserProfileBloc),
              ],
            ),
          ],
        );
      },
    );
  });
}
