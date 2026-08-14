import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/phone_number_otp_screen.dart';

part 'phone_number_login_state.dart';

class LoginState extends Equatable {
  const LoginState({
    required this.phoneNumberLoginState,
    this.isLoading = false,
    this.errorMessage,
  });

  factory LoginState.initial() =>
      LoginState(phoneNumberLoginState: PhoneNumberLoginState.initial());

  @visibleForTesting
  factory LoginState.test({PhoneNumberLoginState? phoneNumberLoginState}) =>
      LoginState(
        phoneNumberLoginState:
            phoneNumberLoginState ?? PhoneNumberLoginState.test(),
      );

  final PhoneNumberLoginState phoneNumberLoginState;
  final bool isLoading;
  final String? errorMessage;

  LoginState copyWith({
    PhoneNumberLoginState? phoneNumberLoginState,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => LoginState(
    phoneNumberLoginState: phoneNumberLoginState ?? this.phoneNumberLoginState,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [phoneNumberLoginState, isLoading, errorMessage];
}

class NavigateToOTPScreenState extends LoginState {
  NavigateToOTPScreenState(LoginState state)
    : super(
        phoneNumberLoginState: state.phoneNumberLoginState,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      );
}

class NavigateToHomeScreenState extends LoginState {
  NavigateToHomeScreenState(LoginState state)
    : super(
        phoneNumberLoginState: state.phoneNumberLoginState,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      );
}

class AuthenticationExceptionState extends LoginState {
  AuthenticationExceptionState(LoginState state)
    : super(
        phoneNumberLoginState: state.phoneNumberLoginState,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      );
}

class PhoneOtpAutoFilledState extends LoginState {
  PhoneOtpAutoFilledState(LoginState state)
    : super(
        phoneNumberLoginState: state.phoneNumberLoginState,
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
      );
}
