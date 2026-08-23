import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/profile/bloc/phone_change_cubit.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/data/models/phone_change_otp_challenge.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/confirm_phone_change.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_phone_change_otp_methods.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/request_phone_change_otp.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPhoneChangeOtpMethods extends Mock
    implements GetPhoneChangeOtpMethods {}

class MockRequestPhoneChangeOtp extends Mock implements RequestPhoneChangeOtp {}

class MockConfirmPhoneChange extends Mock implements ConfirmPhoneChange {}

void main() {
  const phone = '+998901234567';
  const profile = MobileUserProfile(
    id: 1,
    firstName: 'Aziz',
    lastName: null,
    patronymic: null,
    email: null,
    phone: phone,
    nationality: null,
    avatarUrl: null,
  );

  late MockGetPhoneChangeOtpMethods getOtpMethods;
  late MockRequestPhoneChangeOtp requestOtp;
  late MockConfirmPhoneChange confirmPhoneChange;

  PhoneChangeCubit buildCubit() => PhoneChangeCubit(
    getOtpMethods: getOtpMethods,
    requestOtp: requestOtp,
    confirmPhoneChange: confirmPhoneChange,
  );

  setUpAll(() {
    registerFallbackValue(
      const RequestPhoneChangeOtpParams(phone: phone, channel: 'telegram'),
    );
    registerFallbackValue(
      const ConfirmPhoneChangeParams(phone: phone, code: '123456'),
    );
  });

  setUp(() {
    getOtpMethods = MockGetPhoneChangeOtpMethods();
    requestOtp = MockRequestPhoneChangeOtp();
    confirmPhoneChange = MockConfirmPhoneChange();
  });

  test('auto-requests the only available OTP channel', () async {
    when(
      () => getOtpMethods(),
    ).thenAnswer((_) async => const Right(['telegram']));
    when(() => requestOtp(any())).thenAnswer(
      (_) async => const Right(
        PhoneChangeOtpChallenge(
          channel: 'telegram',
          expiresIn: 300,
          resendAfter: 60,
        ),
      ),
    );
    final cubit = buildCubit();

    await cubit.start(phone);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.step, PhoneChangeStep.code);
    expect(cubit.state.channel, 'telegram');
    expect(cubit.state.resendAfter, 60);
    verify(
      () => requestOtp(
        const RequestPhoneChangeOtpParams(phone: phone, channel: 'telegram'),
      ),
    ).called(1);
    await cubit.close();
  });

  test(
    'shows the channel selector when more than one delivery channel exists',
    () async {
      when(
        () => getOtpMethods(),
      ).thenAnswer((_) async => const Right(['telegram', 'sms']));
      final cubit = buildCubit();

      await cubit.start(phone);

      expect(cubit.state.step, PhoneChangeStep.channel);
      expect(cubit.state.channels, ['telegram', 'sms']);
      verifyNever(() => requestOtp(any()));
      await cubit.close();
    },
  );

  test(
    'keeps the user on the sheet and exposes detailed request failures',
    () async {
      when(() => requestOtp(any())).thenAnswer(
        (_) async => const Left(
          APIFailure(
            message: 'This phone number is already in use',
            statusCode: 409,
          ),
        ),
      );
      final cubit = buildCubit();

      await cubit.requestOtp(phone, 'telegram');

      expect(cubit.state.errorMessage, 'This phone number is already in use');
      expect(cubit.state.step, PhoneChangeStep.number);
      await cubit.close();
    },
  );

  test('publishes the confirmed profile only after the OTP succeeds', () async {
    when(
      () => confirmPhoneChange(any()),
    ).thenAnswer((_) async => const Right(profile));
    when(() => requestOtp(any())).thenAnswer(
      (_) async => const Right(
        PhoneChangeOtpChallenge(
          channel: 'telegram',
          expiresIn: 300,
          resendAfter: 60,
        ),
      ),
    );
    final cubit = buildCubit();
    await cubit.requestOtp(phone, 'telegram');

    await cubit.confirm('123456');

    expect(cubit.state.updatedProfile, profile);
    await cubit.close();
  });
}
