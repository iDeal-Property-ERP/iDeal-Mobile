import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/request_otp.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/verify_otp.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/validators/validators.dart';

Future<void> _initializeNotificationsFromService() =>
    NotificationService.instance.initialize();

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.localizations,
    RequestOtp? requestOtp,
    VerifyOtp? verifyOtp,
    SecureStorageService? secureStorageService,
    Future<void> Function()? initializeNotifications,
  }) : _requestOtp =
           requestOtp ??
           (sl.isRegistered<RequestOtp>() ? sl<RequestOtp>() : null),
       _verifyOtp =
           verifyOtp ?? (sl.isRegistered<VerifyOtp>() ? sl<VerifyOtp>() : null),
       _secureStorageService =
           secureStorageService ??
           (sl.isRegistered<SecureStorageService>()
               ? sl<SecureStorageService>()
               : null),
       _initializeNotifications =
           initializeNotifications ?? _initializeNotificationsFromService,
       super(LoginState.initial()) {
    on<PhoneInputHasFocus>(_onPhoneInputHasFocus);
    on<IsPhoneNumValidEvent>(_onPhoneValidityChanged);
    on<CountryCodeChangeEvent>(_onCountryCodeChanged);
    on<PhoneNumChangeEvent>(_onPhoneNumberChanged);
    on<PhoneNumErrorEvent>(_onPhoneNumberError);
    on<PhoneOtpTextChangeEvent>(_onOtpChanged);
    on<PhoneOtpAutoFilledEvent>(_onOtpAutoFilled);
    on<PhoneOtpErrorEvent>(_onOtpError);
    on<IsResendOTPEnabledEvent>(_onResendEnabledChanged);
    on<ResendOTPTimeLeftEvent>(_onResendTimeChanged);
    on<SelectOtpChannelEvent>(_onChannelChanged);
    on<LoginWithPhoneNumEvent>(_onLoginWithPhoneNumber);
    on<RequestPhoneOtpEvent>(_onRequestOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyOtp);
    on<NavigateToOtpEvent>((_, emit) => emit(NavigateToOTPScreenState(state)));
    on<NavigateToHomeScreenEvent>(
      (_, emit) => emit(NavigateToHomeScreenState(state)),
    );
    on<ResetPhoneNumberStateEvent>((_, emit) => emit(LoginState.initial()));
  }

  final AppLocalizations localizations;
  final RequestOtp? _requestOtp;
  final VerifyOtp? _verifyOtp;
  final SecureStorageService? _secureStorageService;
  final Future<void> Function() _initializeNotifications;

  PhoneNumberLoginState get _phone => state.phoneNumberLoginState;

  void _onPhoneInputHasFocus(
    PhoneInputHasFocus event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(
        phoneInputHasFocus: event.hasFocus,
      ),
    ),
  );

  void _onPhoneValidityChanged(
    IsPhoneNumValidEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(isPhoneNumValid: event.isValid),
    ),
  );

  void _onCountryCodeChanged(
    CountryCodeChangeEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(countryCode: event.countryCode),
    ),
  );

  void _onPhoneNumberChanged(
    PhoneNumChangeEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(phoneNumber: event.phoneNumber),
    ),
  );

  void _onPhoneNumberError(
    PhoneNumErrorEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(
        phoneNumErrorMessage: event.errorMessage,
      ),
    ),
  );

  void _onOtpChanged(PhoneOtpTextChangeEvent event, Emitter<LoginState> emit) =>
      emit(
        state.copyWith(
          phoneNumberLoginState: _phone.copyWith(
            phoneOTPText: event.phoneOtpText,
            canSetOTPErrorMessageToNull: true,
          ),
        ),
      );

  void _onOtpAutoFilled(
    PhoneOtpAutoFilledEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(
      PhoneOtpAutoFilledState(
        state.copyWith(
          phoneNumberLoginState: _phone.copyWith(phoneOTPText: event.otpCode),
        ),
      ),
    );
  }

  void _onOtpError(PhoneOtpErrorEvent event, Emitter<LoginState> emit) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(
        phoneOTPErrorMessage: event.errorMessage,
        canSetOTPErrorMessageToNull: event.errorMessage.isEmpty,
      ),
    ),
  );

  void _onResendEnabledChanged(
    IsResendOTPEnabledEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(
        isResendOTPEnabled: event.isResendOTPEnabled,
      ),
    ),
  );

  void _onResendTimeChanged(
    ResendOTPTimeLeftEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(
        resendOTPTimeLeft: event.resentOTPTimeLeft,
      ),
    ),
  );

  void _onChannelChanged(
    SelectOtpChannelEvent event,
    Emitter<LoginState> emit,
  ) => emit(
    state.copyWith(
      phoneNumberLoginState: _phone.copyWith(channel: event.channel),
    ),
  );

  Future<void> _onLoginWithPhoneNumber(
    LoginWithPhoneNumEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (!await isPhoneNumberValid(event.phoneNumberWithCode)) {
      emit(
        state.copyWith(
          phoneNumberLoginState: _phone.copyWith(
            phoneNumErrorMessage: localizations.invalid_mobile_number,
          ),
        ),
      );
      return;
    }
    add(const RequestPhoneOtpEvent());
  }

  Future<void> _onRequestOtp(
    RequestPhoneOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    final requestOtp = _requestOtp;
    if (requestOtp == null) {
      emit(_failure(localizations.opps_something_went_wrong));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await requestOtp(
        RequestOtpParams(phone: _phone.phoneNumber, channel: _phone.channel),
      );
      result.fold((failure) => emit(_failure(failure.message)), (_) {
        emit(state.copyWith(isLoading: false));
        if (!event.isResend) add(const NavigateToOtpEvent());
      });
    } catch (error) {
      emit(_failure(error.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyPhoneOtpEvent event,
    Emitter<LoginState> emit,
  ) async {
    final verifyOtp = _verifyOtp;
    if (verifyOtp == null) {
      emit(_otpFailure(localizations.opps_something_went_wrong));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await verifyOtp(
        VerifyOtpParams(phone: _phone.phoneNumber, code: _phone.phoneOTPText),
      );
      await result.fold((failure) async => emit(_otpFailure(failure.message)), (
        tokens,
      ) async {
        await _storeBackendTokens(tokens);
        try {
          await _initializeNotifications();
        } catch (error) {
          debugPrint('Notification initialization failed after login: $error');
        }
        await HapticFeedbackUtil.success();
        emit(state.copyWith(isLoading: false));
        add(const NavigateToHomeScreenEvent());
      });
    } catch (error) {
      emit(_otpFailure(error.toString()));
    }
  }

  LoginState _failure(String message) => state.copyWith(
    isLoading: false,
    errorMessage: message.isEmpty
        ? localizations.opps_something_went_wrong
        : message,
  );

  LoginState _otpFailure(String message) => state.copyWith(
    isLoading: false,
    phoneNumberLoginState: _phone.copyWith(phoneOTPErrorMessage: message),
  );

  Future<void> _storeBackendTokens(AuthTokens tokens) async {
    final secureStorage = _secureStorageService;
    if (secureStorage == null)
      throw StateError('Secure storage is not configured.');

    await secureStorage.writeAuthTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await Prefs.setString(
      PrefKeys.kUserDetails,
      json.encode(
        LoginDetails(
          phoneNumber: _phone.phoneNumber,
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ).toJson(),
      ),
    );
    await Prefs.remove(PrefKeys.kSkippedLogin);
  }
}
