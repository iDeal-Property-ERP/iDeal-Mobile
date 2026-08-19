import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPCodeInputField extends StatefulWidget {
  const OTPCodeInputField({super.key});

  @override
  State<OTPCodeInputField> createState() => _OTPCodeInputFieldState();
}

class _OTPCodeInputFieldState extends State<OTPCodeInputField>
    with CodeAutoFill {
  late TextEditingController _pinController;
  static const double pinHeight = 56;
  static const double pinWidth = 48;

  @override
  void initState() {
    _pinController = TextEditingController(
      text:
          context.read<LoginBloc>().state.phoneNumberLoginState.phoneOTPText ??
          '',
    );
    super.initState();
    // TODO: prevent in test environment
    SmsAutoFill().listenForCode();
  }

  @override
  void codeUpdated() {
    context.read<LoginBloc>().add(PhoneOtpAutoFilledEvent(otpCode: code ?? ''));
  }

  @override
  void dispose() {
    _pinController.dispose();
    // TODO: prevent in test environment
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? errorText = context.select<LoginBloc, String?>(
      (LoginBloc bloc) =>
          bloc.state.phoneNumberLoginState.phoneOTPErrorMessage,
    );
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is PhoneOtpAutoFilledState) {
          _pinController.text = state.phoneNumberLoginState.phoneOTPText;
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (errorText.haveContent()) {
            context.read<LoginBloc>().add(const PhoneOtpErrorEvent(errorMessage: ''));
          }
          if (_pinController.text.isNotEmpty) {
            _pinController.text = '';
            context.read<LoginBloc>().add(
              const PhoneOtpTextChangeEvent(phoneOtpText: ''),
            );
          }
          final bool isResendOTPEnabled =
              context
                  .read<LoginBloc>()
                  .state
                  .phoneNumberLoginState
                  .isResendOTPEnabled ??
              false;
          if (isResendOTPEnabled) {
            context.read<LoginBloc>().add(
              const IsResendOTPEnabledEvent(isResendOTPEnabled: false),
            );
          }
        },
        child: ClarityMask(
          child: Pinput(
            key: keys.signInPage.otpTextField,
            length: 6,
            controller: _pinController,
            focusedPinTheme: _focusedPinTheme(),
            defaultPinTheme: _defaultPinTheme(),
            submittedPinTheme: _submittedPinTheme(),
            errorPinTheme: errorText.isNullOrEmpty() ? null : _errorPinTheme(),
            pinAnimationType: PinAnimationType.fade,
            forceErrorState: true,
            errorText: errorText.isNullOrEmpty() ? null : errorText,
            errorTextStyle: AppTextStyles.p4Regular.copyWith(
              color: context.currentTheme.textErrorSecondary,
            ),
            onChanged: (pin) {
              if (errorText.haveContent()) {
                context.read<LoginBloc>().add(
                  const PhoneOtpErrorEvent(errorMessage: ''),
                );
              }
              context.read<LoginBloc>().add(
                PhoneOtpTextChangeEvent(phoneOtpText: pin),
              );
            },
            onCompleted: (phoneOtpText) {
              if (phoneOtpText.isNotEmpty && phoneOtpText.length == 6) {
                context.read<LoginBloc>().add(const VerifyPhoneOtpEvent());
              }
            },
          ),
        ),
      ),
    );
  }

  PinTheme _defaultPinTheme() {
    return PinTheme(
      width: pinWidth,
      height: pinHeight,
      decoration: _pinInputBoxDecoration(),
      textStyle: AppTextStyles.h2Bold.copyWith(
        color: context.currentTheme.textNeutralPrimary,
      ),
    );
  }

  PinTheme _focusedPinTheme() {
    return PinTheme(
      width: pinWidth,
      height: pinHeight,
      decoration: _pinInputBoxDecoration().copyWith(
        border: Border.all(color: context.currentTheme.strokeBrandDefault),
      ),
      textStyle: AppTextStyles.h2Bold,
    );
  }

  PinTheme _submittedPinTheme() {
    return PinTheme(
      width: pinWidth,
      height: pinHeight,
      decoration: _pinInputBoxDecoration().copyWith(
        border: Border.all(color: context.currentTheme.strokeNeutralDefault),
      ),
      textStyle: AppTextStyles.h2Bold,
    );
  }

  PinTheme _errorPinTheme() {
    return PinTheme(
      width: pinWidth,
      height: pinHeight,
      decoration: _pinInputBoxDecoration().copyWith(
        border: Border.all(color: context.currentTheme.strokeErrorDefault),
      ),
      textStyle: AppTextStyles.h2Bold,
    );
  }

  BoxDecoration _pinInputBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: context.currentTheme.strokeNeutralLight200),
      color: context.currentTheme.bgSurfaceBase2,
      borderRadius: BorderRadius.circular(AppRadius.input),
    );
  }
}
