import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/contact_us/contact_us_screen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/support_remote_data_source.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/data/models/support_links_model.dart';
import 'package:ideal_mobile/presentation/profile/widgets/help_and_support.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_bloc.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_state.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

import '../../test_helpers.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockSupportRemoteDataSource extends Mock
    implements SupportRemoteDataSource {}

const testProfile = MobileUserProfile(
  id: 1,
  firstName: 'Test',
  lastName: 'User',
  patronymic: null,
  email: 'test@example.com',
  phone: '+998901234567',
  nationality: 'Uzbek',
  avatarUrl: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileBloc mockProfileBloc;
  late MockSupportRemoteDataSource mockSupportDataSource;
  late MockThemeBloc mockThemeBloc;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockSupportDataSource = MockSupportRemoteDataSource();
    mockThemeBloc = MockThemeBloc();
    when(() => mockThemeBloc.state).thenReturn(const ThemeState.test());
    when(
      () => mockProfileBloc.state,
    ).thenReturn(const ProfileState.test(profile: testProfile));

    if (sl.isRegistered<SupportRemoteDataSource>()) {
      sl.unregister<SupportRemoteDataSource>();
    }
    sl.registerLazySingleton<SupportRemoteDataSource>(
      () => mockSupportDataSource,
    );
  });

  tearDown(() {
    if (sl.isRegistered<SupportRemoteDataSource>()) {
      sl.unregister<SupportRemoteDataSource>();
    }
  });

  Future<void> pumpHelpAndSupport(WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, screenType) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
              BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
            ],
            child: MaterialApp(
              theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
              locale: const Locale('en'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const Scaffold(body: HelpAndSupport()),
            ),
          );
        },
      ),
    );
  }

  testWidgets('shows all options when both Telegram and WhatsApp exist', (
    tester,
  ) async {
    when(() => mockSupportDataSource.getSupportLinks()).thenAnswer(
      (_) async => const SupportLinksModel(
        telegramUrl: 'https://t.me/ideal_support',
        whatsappUrl: 'https://wa.me/998901234567',
      ),
    );

    await pumpHelpAndSupport(tester);

    await tester.tap(find.byType(HelpAndSupport));
    await tester.pumpAndSettle();

    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets('hides WhatsApp when whatsapp_url is missing', (tester) async {
    when(() => mockSupportDataSource.getSupportLinks()).thenAnswer(
      (_) async =>
          const SupportLinksModel(telegramUrl: 'https://t.me/ideal_support'),
    );

    await pumpHelpAndSupport(tester);

    await tester.tap(find.byType(HelpAndSupport));
    await tester.pumpAndSettle();

    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Telegram'), findsOneWidget);
    expect(find.text('WhatsApp'), findsNothing);
  });

  testWidgets('hides Telegram and WhatsApp when both are missing', (
    tester,
  ) async {
    when(
      () => mockSupportDataSource.getSupportLinks(),
    ).thenAnswer((_) async => const SupportLinksModel());

    await pumpHelpAndSupport(tester);

    await tester.tap(find.byType(HelpAndSupport));
    await tester.pumpAndSettle();

    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Telegram'), findsNothing);
    expect(find.text('WhatsApp'), findsNothing);
  });

  testWidgets('tapping Contact us navigates to ContactUsScreen', (
    tester,
  ) async {
    when(
      () => mockSupportDataSource.getSupportLinks(),
    ).thenAnswer((_) async => const SupportLinksModel());

    await pumpHelpAndSupport(tester);

    await tester.tap(find.byType(HelpAndSupport));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contact Us'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactUsScreen), findsOneWidget);
  });
}
