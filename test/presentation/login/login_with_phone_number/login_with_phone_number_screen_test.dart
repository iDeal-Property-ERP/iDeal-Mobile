import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/heading_welcome_widget.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/channel_picker_sheet.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/phone_number_text_field.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/send_otp_button.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/terms_agreement_notice.dart';
import 'package:ideal_mobile/services/firebase_auth_services.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../integration_test/mock_firebase_auth.dart';
import '../../../../integration_test/mock_firebase_performance.dart';
import '../../../flutter_test_config.dart';
import '../../../test_helpers.dart';

class MockLoginBloc extends MockBloc<LoginEvents, LoginState>
    implements LoginBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mokFirebaseAuth;
  late FirebaseAuthService mockFirebaseAuthService;
  late MockFirebasePerformance mockFirebasePerformance;

  setUp(() {
    mokFirebaseAuth = MockFirebaseAuth();
    mockFirebasePerformance = MockFirebasePerformance();
    sl.allowReassignment = true;
    mockFirebaseAuthService = FirebaseAuthService(
      firebaseAuth: mokFirebaseAuth,
    );
    sl.registerLazySingleton<FirebaseAuthService>(
      () => mockFirebaseAuthService,
    );
    sl.allowReassignment = true;
    sl.registerLazySingleton<PerformanceMonitoringService>(
      () => PerformanceMonitoringService(performance: mockFirebasePerformance),
    );
  });

  // Widget tests
  group('Login With Phone Number Screen', () {
    testWidgets('Login With Phone Number Screen renders correctly', (
      tester,
    ) async {
      await tester.runWidgetTest(child: const LoginWithPhoneNumberScreen());
      expect(find.byType(LoginWithPhoneNumberScreen), findsOneWidget);
      expect(find.byType(HeadingWelcomeWidget), findsOneWidget);
      expect(find.text('iDeal'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byType(TermsAgreementNotice), findsOneWidget);
      expect(find.byType(PhoneNumberTextField), findsOneWidget);
      expect(find.byType(SendOTPButton), findsOneWidget);
      expect(find.text('Continue with Email'), findsNothing);
      expect(find.text('Continue with Google'), findsNothing);
    });

    testWidgets('OTP channel picker has no edit action', (tester) async {
      await tester.runWidgetTest(
        child: const Scaffold(
          body: ChannelPickerSheet(phoneNumber: '+998937240401'),
        ),
      );

      expect(find.text('Via Telegram (recommended)'), findsOneWidget);
      expect(find.text('Via SMS'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
    });
  });

  // Golden tests for main screen
  testExecutable(() {
    goldenTest(
      'Login With Phone Number Screen UI Test',
      fileName: 'login_with_phone_number_screen',
      pumpBeforeTest: precacheImages,
      builder: () {
        final loginBlocEmpty = MockLoginBloc();
        when(() => loginBlocEmpty.state).thenReturn(
          LoginState.test(phoneNumberLoginState: PhoneNumberLoginState.test()),
        );

        final loginBlocFilled = MockLoginBloc();
        when(() => loginBlocFilled.state).thenReturn(
          LoginState.test(
            phoneNumberLoginState: PhoneNumberLoginState.test(
              countryCode: '+91',
              phoneNumber: '9876543210',
            ),
          ),
        );

        final loginBlocWithError = MockLoginBloc();
        when(() => loginBlocWithError.state).thenReturn(
          LoginState.test(
            phoneNumberLoginState: PhoneNumberLoginState.test(
              countryCode: '+91',
              phoneNumber: '123456',
              phoneNumErrorMessage: 'Invalid phone number',
            ),
          ),
        );

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'default phone number state',
              child: const LoginWithPhoneNumberBody(isFromDeleteAccount: false),
              addScaffold: true,
              providers: [BlocProvider<LoginBloc>.value(value: loginBlocEmpty)],
            ),
            createTestScenario(
              name: 'valid phone number state',
              child: const LoginWithPhoneNumberBody(isFromDeleteAccount: false),
              addScaffold: true,
              providers: [
                BlocProvider<LoginBloc>.value(value: loginBlocFilled),
              ],
            ),
            createTestScenario(
              name: 'error phone number state',
              child: const LoginWithPhoneNumberBody(isFromDeleteAccount: false),
              addScaffold: true,
              providers: [
                BlocProvider<LoginBloc>.value(value: loginBlocWithError),
              ],
            ),
          ],
        );
      },
    );
  });

  // Golden tests for send OTP button
  testExecutable(() {
    goldenTest(
      'Send OTP Button UI Test',
      fileName: 'login_send_otp_button',
      pumpBeforeTest: precacheImages,
      builder: () {
        final loginBlocDisabled = MockLoginBloc();
        when(() => loginBlocDisabled.state).thenReturn(
          LoginState.test(phoneNumberLoginState: PhoneNumberLoginState.test()),
        );

        final loginBlocEnabled = MockLoginBloc();
        when(() => loginBlocEnabled.state).thenReturn(
          LoginState.test(
            phoneNumberLoginState: PhoneNumberLoginState.test(
              countryCode: '+91',
              phoneNumber: '9876543210',
              isPhoneNumValid: true,
            ),
          ),
        );

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'disabled button state',
              child: const SendOTPButton(),
              addScaffold: true,
              providers: [
                BlocProvider<LoginBloc>.value(value: loginBlocDisabled),
              ],
            ),
            createTestScenario(
              name: 'enabled button state',
              child: const SendOTPButton(),
              addScaffold: true,
              providers: [
                BlocProvider<LoginBloc>.value(value: loginBlocEnabled),
              ],
            ),
          ],
        );
      },
    );
  });
}
