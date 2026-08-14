import 'package:equatable/equatable.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
}

class PhoneInputHasFocus extends LoginEvent {
  const PhoneInputHasFocus({required this.hasFocus});
  final bool hasFocus;
  @override
  List<Object?> get props => [hasFocus];
}

class IsPhoneNumValidEvent extends LoginEvent {
  const IsPhoneNumValidEvent({required this.isValid});
  final bool isValid;
  @override
  List<Object?> get props => [isValid];
}

class CountryCodeChangeEvent extends LoginEvent {
  const CountryCodeChangeEvent({required this.countryCode});
  final String countryCode;
  @override
  List<Object?> get props => [countryCode];
}

class PhoneNumChangeEvent extends LoginEvent {
  const PhoneNumChangeEvent({required this.phoneNumber});
  final String phoneNumber;
  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneNumErrorEvent extends LoginEvent {
  const PhoneNumErrorEvent({required this.errorMessage});
  final String errorMessage;
  @override
  List<Object?> get props => [errorMessage];
}

class PhoneOtpTextChangeEvent extends LoginEvent {
  const PhoneOtpTextChangeEvent({required this.phoneOtpText});
  final String phoneOtpText;
  @override
  List<Object?> get props => [phoneOtpText];
}

class PhoneOtpAutoFilledEvent extends LoginEvent {
  const PhoneOtpAutoFilledEvent({required this.otpCode});
  final String otpCode;
  @override
  List<Object?> get props => [otpCode];
}

class PhoneOtpErrorEvent extends LoginEvent {
  const PhoneOtpErrorEvent({required this.errorMessage});
  final String errorMessage;
  @override
  List<Object?> get props => [errorMessage];
}

class IsResendOTPEnabledEvent extends LoginEvent {
  const IsResendOTPEnabledEvent({required this.isResendOTPEnabled});
  final bool isResendOTPEnabled;
  @override
  List<Object?> get props => [isResendOTPEnabled];
}

class ResendOTPTimeLeftEvent extends LoginEvent {
  const ResendOTPTimeLeftEvent({required this.resentOTPTimeLeft});
  final int resentOTPTimeLeft;
  @override
  List<Object?> get props => [resentOTPTimeLeft];
}

class SelectOtpChannelEvent extends LoginEvent {
  const SelectOtpChannelEvent({required this.channel});
  final String channel;
  @override
  List<Object?> get props => [channel];
}

class LoginWithPhoneNumEvent extends LoginEvent {
  const LoginWithPhoneNumEvent(this.phoneNumberWithCode);
  final String phoneNumberWithCode;
  @override
  List<Object?> get props => [phoneNumberWithCode];
}

class RequestPhoneOtpEvent extends LoginEvent {
  const RequestPhoneOtpEvent({this.isResend = false});
  final bool isResend;
  @override
  List<Object?> get props => [isResend];
}

class VerifyPhoneOtpEvent extends LoginEvent {
  const VerifyPhoneOtpEvent();
  @override
  List<Object?> get props => [];
}

class NavigateToOtpEvent extends LoginEvent {
  const NavigateToOtpEvent();
  @override
  List<Object?> get props => [];
}

class NavigateToHomeScreenEvent extends LoginEvent {
  const NavigateToHomeScreenEvent();
  @override
  List<Object?> get props => [];
}

class ResetPhoneNumberStateEvent extends LoginEvent {
  const ResetPhoneNumberStateEvent();
  @override
  List<Object?> get props => [];
}
