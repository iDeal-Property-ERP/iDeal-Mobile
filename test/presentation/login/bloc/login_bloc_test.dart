import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/i18n/app_localizations_en.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/get_otp_methods.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/request_otp.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/verify_otp.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetOtpMethods extends Mock implements GetOtpMethods {}

class MockRequestOtp extends Mock implements RequestOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockGetOtpMethods getOtpMethods;
  late MockRequestOtp requestOtp;
  late MockVerifyOtp verifyOtp;
  late MockSecureStorageService secureStorageService;
  late AppLocalizationsEn localizations;

  setUp(() {
    getOtpMethods = MockGetOtpMethods();
    requestOtp = MockRequestOtp();
    verifyOtp = MockVerifyOtp();
    secureStorageService = MockSecureStorageService();
    localizations = AppLocalizationsEn();

    registerFallbackValue(
      const RequestOtpParams(phone: '+998901234567', channel: 'telegram'),
    );
  });

  LoginBloc buildBloc() => LoginBloc(
    localizations: localizations,
    getOtpMethods: getOtpMethods,
    requestOtp: requestOtp,
    verifyOtp: verifyOtp,
    secureStorageService: secureStorageService,
    initializeNotifications: () async {},
  );

  group('LoginBloc dynamic OTP methods', () {
    const validPhone = '+998901234567';

    blocTest<LoginBloc, LoginState>(
      'single channel auto-requests OTP and navigates without picker',
      build: () {
        when(
          () => getOtpMethods(),
        ).thenAnswer((_) async => const Right(['sms']));
        when(
          () => requestOtp(any()),
        ).thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => LoginState.initial().copyWith(
        phoneNumberLoginState: PhoneNumberLoginState.initial().copyWith(
          phoneNumber: validPhone,
        ),
      ),
      act: (bloc) => bloc.add(const LoginWithPhoneNumEvent(validPhone)),
      verify: (_) {
        verify(() => getOtpMethods()).called(1);
        verify(
          () => requestOtp(
            const RequestOtpParams(phone: validPhone, channel: 'sms'),
          ),
        ).called(1);
      },
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LoginState>()
            .having((s) => s.phoneNumberLoginState.channel, 'channel', 'sms')
            .having((s) => s.isLoading, 'isLoading', true),
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', false),
        isA<NavigateToOTPScreenState>(),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'multiple channels emits PromptOtpChannelSelectionState',
      build: () {
        when(
          () => getOtpMethods(),
        ).thenAnswer((_) async => const Right(['telegram', 'sms']));
        return buildBloc();
      },
      seed: () => LoginState.initial().copyWith(
        phoneNumberLoginState: PhoneNumberLoginState.initial().copyWith(
          phoneNumber: validPhone,
        ),
      ),
      act: (bloc) => bloc.add(const LoginWithPhoneNumEvent(validPhone)),
      verify: (_) {
        verify(() => getOtpMethods()).called(1);
        verifyNever(() => requestOtp(any()));
      },
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
        isA<PromptOtpChannelSelectionState>().having(
          (s) => s.channels,
          'channels',
          ['telegram', 'sms'],
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'methods failure emits error message',
      build: () {
        when(() => getOtpMethods()).thenAnswer(
          (_) async =>
              const Left(APIFailure(message: 'Network error', statusCode: 500)),
        );
        return buildBloc();
      },
      seed: () => LoginState.initial().copyWith(
        phoneNumberLoginState: PhoneNumberLoginState.initial().copyWith(
          phoneNumber: validPhone,
        ),
      ),
      act: (bloc) => bloc.add(const LoginWithPhoneNumEvent(validPhone)),
      verify: (_) {
        verify(() => getOtpMethods()).called(1);
        verifyNever(() => requestOtp(any()));
      },
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LoginState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Network error',
        ),
      ],
    );
  });
}
