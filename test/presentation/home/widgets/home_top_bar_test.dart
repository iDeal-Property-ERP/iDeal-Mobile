import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_top_bar.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

const _testProfile = MobileUserProfile(
  id: 1,
  firstName: 'Mehroj',
  lastName: 'User',
  patronymic: null,
  email: 'mehroj@example.com',
  phone: '+998901234567',
  nationality: null,
  avatarUrl: null,
);

Widget _buildTestSubject({
  required Widget child,
  ProfileBloc? profileBloc,
  Locale locale = const Locale('en'),
  AppThemeEnum theme = AppThemeEnum.LightTheme,
}) {
  final widget = MaterialApp(
    locale: locale,
    debugShowCheckedModeBanner: false,
    theme: AppThemesData.themeData[theme],
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: CustomScrollView(slivers: [child])),
  );

  if (profileBloc != null) {
    return BlocProvider<ProfileBloc>.value(value: profileBloc, child: widget);
  }
  return widget;
}

void main() {
  group('homeMottoText', () {
    testWidgets('maps all 10 mottos correctly and wraps modulo', (
      tester,
    ) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              buildContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final mottos = List.generate(
        10,
        (index) => homeMottoText(buildContext, index),
      );
      expect(mottos.toSet().length, 10);
      expect(mottos[0], 'Ready for your next deal?');
      expect(homeMottoText(buildContext, 10), mottos[0]);
    });
  });

  group('HomeSliverTopBar', () {
    testWidgets(
      'renders personalized greeting when profile first name exists',
      (tester) async {
        final profileBloc = MockProfileBloc();
        when(
          () => profileBloc.state,
        ).thenReturn(const ProfileState.initial(profile: _testProfile));

        await tester.pumpWidget(
          _buildTestSubject(
            profileBloc: profileBloc,
            child: const HomeSliverTopBar(mottoIndex: 0, unreadCount: 0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi, Mehroj'), findsOneWidget);
        expect(find.text('Ready for your next deal?'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets('renders guest greeting when profile is unset or guest', (
      tester,
    ) async {
      final profileBloc = MockProfileBloc();
      when(() => profileBloc.state).thenReturn(const ProfileState.initial());

      await tester.pumpWidget(
        _buildTestSubject(
          profileBloc: profileBloc,
          child: const HomeSliverTopBar(mottoIndex: 1, unreadCount: 0),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('Find your perfect space'), findsOneWidget);
    });

    testWidgets('renders unread badge counts correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestSubject(
          child: const HomeSliverTopBar(mottoIndex: 0, unreadCount: 3),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      await tester.pumpWidget(
        _buildTestSubject(
          child: const HomeSliverTopBar(mottoIndex: 0, unreadCount: 150),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('triggers notification callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildTestSubject(
          child: HomeSliverTopBar(
            mottoIndex: 0,
            unreadCount: 0,
            onNotificationTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders in DarkTheme without issue', (tester) async {
      await tester.pumpWidget(
        _buildTestSubject(
          theme: AppThemeEnum.DarkTheme,
          child: const HomeSliverTopBar(mottoIndex: 0, unreadCount: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
