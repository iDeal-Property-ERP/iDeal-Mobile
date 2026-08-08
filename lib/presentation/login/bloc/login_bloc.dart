import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/request_otp.dart';
import 'package:ideal_mobile/presentation/login/domain/usecases/verify_otp.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/presentation/signup/enum/user_details_input_status.dart';
import 'package:ideal_mobile/services/firebase_auth_services.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/validators/validators.dart';

Future<void> _initializeNotificationsFromService() {
  return NotificationService.instance.initialize();
}

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  static const kMinimumPasswordLength = 8;

  final FirebaseAuthService _firebaseAuthService = sl();
  final PerformanceMonitoringService _performanceService = sl();
  final RequestOtp? _requestOtp;
  final VerifyOtp? _verifyOtp;
  final SecureStorageService? _secureStorageService;
  final Future<void> Function() _initializeNotifications;
  final AppLocalizations localizations;

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
    _setupEventListener();
  }

  void _setupEventListener() {
    on<EnableSignupModeEvent>(_onEnableSignupModeEvent);
    on<PhoneInputHasFocus>(_onUpdatePhoneInputHasFocusEvent);
    on<IsPhoneNumValidEvent>(_onUpdateIsPhoneNumValidEvent);
    on<CountryCodeChangeEvent>(_onUpdateCountryCodeChangeEvent);
    on<PhoneNumChangeEvent>(_onPhoneNumChangeEvent);
    on<NavigateToEmailVerifyScreenEvent>(_onNavigateToEmailVerifyScreenEvent);
    on<PhoneNumErrorEvent>(_onPhoneNumErrorEvent);
    on<PhoneOtpTextChangeEvent>(_onPhoneOtpTextChangeEvent);
    on<PhoneOtpErrorEvent>(_onPhoneOtpErrorEvent);
    on<IsResendOTPEnabledEvent>(_onIsResendOTPEnabledEvent);
    on<ResendOTPTimeLeftEvent>(_onResendOTPTimeLeftEvent);
    on<SelectOtpChannelEvent>(_onSelectOtpChannelEvent);
    on<NavigateToOtpEvent>(_onNavigateToOtpEvent);
    on<FirebasePhoneLoginEvent>(_onFirebasePhoneLoginEvent);
    on<FirebaseOTPVerificationEvent>(_onFirebaseOTPVerificationEvent);
    on<FirebaseOTPAutoVerificationEvent>(_onFirebaseOTPAutoVerificationEvent);
    on<NavigateToHomeScreenEvent>(_onNavigateToHomeScreenEvent);
    on<EmailChangeEvent>(_onEmailChangeEvent);
    on<EmailErrorEvent>(_onEmailErrorEvent);
    on<PasswordChangeEvent>(_onPasswordChangeEvent);
    on<PasswordErrorEvent>(_onPasswordErrorEvent);
    on<IsPasswordVisibleEvent>(_onIsPasswordVisibleEvent);
    on<EmailPasswordLoginEvent>(_onEmailPasswordLoginEvent);
    on<AuthenticationExceptionEvent>(_onAuthenticationExceptionEvent);
    on<CompleteOnboardingEvent>(_onCompleteOnboardingEvent);
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
    on<ResetPasswordLinkSentEvent>(_onResetPasswordLinkSentEvent);
    on<LoginWithGoogleEvent>(_onLoginWithGoogleSSOEvent);
    on<LoginWithAppleEvent>(_onLoginWithAppleSSOEvent);
    on<PhoneNumLoginLoadingEvent>(_onPhoneNumberLoadingEvent);
    on<EmailLoginLoadingEvent>(_onEmailLoginLoadingEvent);
    on<ResetEmailStateEvent>(_onResetEmailStateEvent);
    on<ResetPhoneNumberStateEvent>(_onResetPhoneNumberStateEvent);
    on<NavigateToVerifiedScreenEvent>(_onNavigateToVerifiedScreenEvent);

    on<SendEmailVerificationLinkEvent>(_onSendEmailVerificationLinkEvent);

    on<RestartVerificationMailResendTimerEvent>(
      _onRestartVerificationMailResendTimerEvent,
    );
    on<VerificationCodeFailedToSendEvent>(_onVerificationCodeFailedToSendEvent);
    on<LoginWithPhoneNumEvent>(_onLoginWithPhoneNumEvent);
    on<ChangeUserDetailsInputStatusEvent>(_onChangeUserDetailsInputStatusEvent);
    on<SelectLoginSignupTypeEvent>(_onSelectLoginSignupTypeEvent);
  }

  void _onSelectLoginSignupTypeEvent(
    SelectLoginSignupTypeEvent event,
    Emitter emit,
  ) {
    emit(state.copyWith(selectedLoginType: event.selectedType));
  }

  void _onEnableSignupModeEvent(EnableSignupModeEvent event, Emitter emit) {
    emit(state.copyWith(isSignup: event.isSignup));
  }

  void _onUpdatePhoneInputHasFocusEvent(
    PhoneInputHasFocus event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneInputHasFocus: event.hasFocus,
        ),
      ),
    );
  }

  void _onUpdateIsPhoneNumValidEvent(IsPhoneNumValidEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          isPhoneNumValid: event.isValid,
        ),
      ),
    );
  }

  void _onUpdateCountryCodeChangeEvent(
    CountryCodeChangeEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          countryCode: event.countryCode,
        ),
      ),
    );
  }

  void _onPhoneNumChangeEvent(PhoneNumChangeEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneNumber: event.phoneNumber,
        ),
      ),
    );
  }

  void _onPhoneNumErrorEvent(PhoneNumErrorEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneNumErrorMessage: event.errorMessage,
        ),
      ),
    );
  }

  void _onPhoneOtpTextChangeEvent(PhoneOtpTextChangeEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneOTPText: event.phoneOtpText,
        ),
      ),
    );
  }

  void _onPhoneOtpErrorEvent(PhoneOtpErrorEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          phoneOTPErrorMessage: event.errorMessage,
          canSetOTPErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onIsResendOTPEnabledEvent(IsResendOTPEnabledEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          isResendOTPEnabled: event.isResendOTPEnabled,
        ),
      ),
    );
  }

  void _onResendOTPTimeLeftEvent(ResendOTPTimeLeftEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          resendOTPTimeLeft: event.resentOTPTimeLeft,
        ),
      ),
    );
  }

  void _onSelectOtpChannelEvent(SelectOtpChannelEvent event, Emitter emit) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      state.copyWith(
        phoneNumberLoginState: phoneNumberLoginState.copyWith(
          channel: event.channel,
        ),
      ),
    );
  }

  void _onNavigateToOtpEvent(NavigateToOtpEvent event, Emitter emit) {
    emit(NavigateToOTPScreenState(state));
  }

  void _onNavigateToHomeScreenEvent(
    NavigateToHomeScreenEvent event,
    Emitter emit,
  ) {
    emit(NavigateToHomeScreenState(state));
  }

  Future<void> _onFirebasePhoneLoginEvent(
    FirebasePhoneLoginEvent event,
    Emitter emit,
  ) async {
    await _firebaseVerifyAndOpenOtpScreenOnCodeSent(
      isFromVerificationScreen: event.isFromVerificationScreen,
    );
  }

  Future<void> _onFirebaseOTPVerificationEvent(
    FirebaseOTPVerificationEvent event,
    Emitter emit,
  ) async {
    await _firebaseOTPVerification();
  }

  void _onFirebaseOTPAutoVerificationEvent(
    FirebaseOTPAutoVerificationEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();
    emit(
      FirebaseOTPAutoVerificationState(
        phoneNumberLoginState.copyWith(phoneOTPText: event.otpCode),
      ),
    );
  }

  void _onEmailChangeEvent(EmailChangeEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          email: event.email,
        ),
      ),
    );
  }

  void _onEmailErrorEvent(EmailErrorEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          emailErrorMessage: event.errorMessage,
          canSetEmailErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onPasswordChangeEvent(PasswordChangeEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          password: event.password,
        ),
      ),
    );
  }

  void _onPasswordErrorEvent(PasswordErrorEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          passwordErrorMessage: event.errorMessage,
          canSetPasswordErrorMessageToNull: true,
        ),
      ),
    );
  }

  void _onIsPasswordVisibleEvent(IsPasswordVisibleEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          isPasswordVisible: event.isPasswordVisible,
        ),
      ),
    );
  }

  Future<void> _onEmailPasswordLoginEvent(
    EmailPasswordLoginEvent event,
    Emitter emit,
  ) async {
    await _loginUsingEmailAndPassword();
  }

  void _onAuthenticationExceptionEvent(
    AuthenticationExceptionEvent event,
    Emitter emit,
  ) {
    final EmailPasswordLoginState emailPasswordLoginState =
        state.emailPasswordLoginState ?? EmailPasswordLoginState.initial();
    emit(
      state.copyWith(
        emailPasswordLoginState: emailPasswordLoginState.copyWith(
          authenticationErrorMessage: event.errorMessage,
        ),
        isLoading: false,
      ),
    );
    emit(AuthenticationExceptionState(state));
  }

  Future<void> _onCompleteOnboardingEvent(
    CompleteOnboardingEvent event,
    Emitter emit,
  ) async {
    await Prefs.setBool(PrefKeys.kHasCompletedOnboarding, value: true);
    add(ChangeUserDetailsInputStatusEvent(UserDetailsInputStatus.done));
    add(NavigateToHomeScreenEvent());
  }

  Future<void> _onForgotPasswordEvent(
    ForgotPasswordEvent event,
    Emitter emit,
  ) async {
    await _sendPasswordResetLink();
  }

  void _onResetPasswordLinkSentEvent(
    ResetPasswordLinkSentEvent event,
    Emitter emit,
  ) {
    emit(ResetPasswordLinkSentState(state));
  }

  Future<void> _onLoginWithGoogleSSOEvent(
    LoginWithGoogleEvent event,
    Emitter emit,
  ) async {
    await _loginWithGoogle();
  }

  Future<void> _onLoginWithAppleSSOEvent(
    LoginWithAppleEvent event,
    Emitter emit,
  ) async {
    await _loginWithApple();
  }

  void _onPhoneNumberLoadingEvent(
    PhoneNumLoginLoadingEvent event,
    Emitter emit,
  ) {
    emit(PhoneNumLoginLoadingState(state, isLoading: event.isLoading));
  }

  void _onEmailLoginLoadingEvent(EmailLoginLoadingEvent event, Emitter emit) {
    emit(EmailLoginLoadingState(state, isLoading: event.isLoading));
  }

  void _onResetEmailStateEvent(ResetEmailStateEvent event, Emitter emit) {
    final EmailPasswordLoginState emailPasswordLoginState =
        EmailPasswordLoginState.initial();
    emit(state.copyWith(emailPasswordLoginState: emailPasswordLoginState));
    emit(EmailLoginLoadingState(state, isLoading: false));
    emit(ClearLoginWithEmailControllerState(state));
  }

  void _onResetPhoneNumberStateEvent(
    ResetPhoneNumberStateEvent event,
    Emitter emit,
  ) {
    final PhoneNumberLoginState phoneNumberLoginState =
        PhoneNumberLoginState.initial();
    emit(state.copyWith(phoneNumberLoginState: phoneNumberLoginState));
    emit(PhoneNumLoginLoadingState(state, isLoading: false));
  }

  void _onNavigateToVerifiedScreenEvent(
    NavigateToVerifiedScreenEvent event,
    Emitter emit,
  ) {
    emit(
      NavigateToVerifiedScreenState(
        state.copyWith(
          userDetailsInputStatus: UserDetailsInputStatus.inProgress,
        ),
      ),
    );
  }

  void _onSendEmailVerificationLinkEvent(
    SendEmailVerificationLinkEvent event,
    Emitter emit,
  ) async {
    add(EmailLoginLoadingEvent(isLoading: true));
    await _firebaseAuthService.sendVerificationEmail(
      onError: (errorMessage, {stackTrace}) {
        add(EmailLoginLoadingEvent(isLoading: false));
        add(AuthenticationExceptionEvent(errorMessage: errorMessage));
      },
    );
    add(EmailLoginLoadingEvent(isLoading: false));
    add(RestartVerificationMailResendTimerEvent());
  }

  void _onRestartVerificationMailResendTimerEvent(
    RestartVerificationMailResendTimerEvent event,
    Emitter emit,
  ) {
    emit(RestartVerificationMailResendTimerState(state));
  }

  void _onVerificationCodeFailedToSendEvent(
    VerificationCodeFailedToSendEvent event,
    Emitter emit,
  ) {
    emit(VerificationCodeFailedToSendState(state));
  }

  Future<void> _onLoginWithPhoneNumEvent(
    LoginWithPhoneNumEvent event,
    Emitter emit,
  ) async {
    add(PhoneNumLoginLoadingEvent(isLoading: true));
    final isPhoneNumValid = await isPhoneNumberValid(event.phoneNumberWithCode);

    if (!isPhoneNumValid) {
      final phoneNumberLoginState =
          state.phoneNumberLoginState ?? PhoneNumberLoginState.initial();

      emit(
        state.copyWith(
          phoneNumberLoginState: phoneNumberLoginState.copyWith(
            phoneNumErrorMessage: localizations.invalid_mobile_number,
          ),
        ),
      );
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      return;
    }
    add(FirebasePhoneLoginEvent(isFromVerificationScreen: false));
  }

  void _onChangeUserDetailsInputStatusEvent(
    ChangeUserDetailsInputStatusEvent event,
    Emitter emit,
  ) {
    emit(
      state.copyWith(userDetailsInputStatus: UserDetailsInputStatus.inProgress),
    );
  }

  void hideAllLoadingsAndShowError() {
    add(PhoneNumLoginLoadingEvent(isLoading: false));
    add(EmailLoginLoadingEvent(isLoading: false));
    add(
      AuthenticationExceptionEvent(
        errorMessage: localizations.opps_something_went_wrong,
      ),
    );
  }

  Future<void> _firebaseVerifyAndOpenOtpScreenOnCodeSent({
    required bool isFromVerificationScreen,
  }) async {
    add(PhoneNumLoginLoadingEvent(isLoading: !isFromVerificationScreen));

    final requestOtp = _requestOtp;
    if (requestOtp == null) {
      add(
        PhoneNumErrorEvent(
          errorMessage: localizations.opps_something_went_wrong,
        ),
      );
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      return;
    }

    try {
      final result = await requestOtp(
        RequestOtpParams(
          phone: state.phoneNumberLoginState?.phoneNumber ?? '',
          channel: state.phoneNumberLoginState?.channel ?? 'telegram',
        ),
      );

      result.fold(
        (failure) => add(
          PhoneNumErrorEvent(
            errorMessage: failure.message.isNotEmpty
                ? failure.message
                : localizations.opps_something_went_wrong,
          ),
        ),
        (_) {
          if (!isFromVerificationScreen) {
            add(NavigateToOtpEvent());
          }
        },
      );
    } catch (error) {
      add(PhoneNumErrorEvent(errorMessage: error.toString()));
    } finally {
      add(PhoneNumLoginLoadingEvent(isLoading: false));
    }
  }

  Future<void> _firebaseOTPVerification() async {
    _performanceService.startTrace(kTraceLoginPhone);
    add(PhoneNumLoginLoadingEvent(isLoading: true));

    final verifyOtp = _verifyOtp;
    if (verifyOtp == null) {
      add(
        PhoneOtpErrorEvent(
          errorMessage: localizations.opps_something_went_wrong,
        ),
      );
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      _performanceService.stopTrace(kTraceLoginPhone);
      return;
    }

    try {
      final result = await verifyOtp(
        VerifyOtpParams(
          phone: state.phoneNumberLoginState?.phoneNumber ?? '',
          code: state.phoneNumberLoginState?.phoneOTPText ?? '',
        ),
      );

      await result.fold(
        (failure) async {
          _performanceService.putAttribute(
            kTraceLoginPhone,
            kTraceAttrError,
            failure.message.truncate(100),
          );
          add(
            PhoneOtpErrorEvent(
              errorMessage: failure.message.isNotEmpty
                  ? failure.message
                  : localizations.opps_something_went_wrong,
            ),
          );
        },
        (authTokens) async {
          _performanceService.putAttribute(
            kTraceLoginPhone,
            kTraceAttrSuccess,
            true,
          );
          await handleUserDetails(
            null,
            authTokens: authTokens,
            onError: (error) {
              add(PhoneOtpErrorEvent(errorMessage: error));
            },
          );
          await HapticFeedbackUtil.success();
        },
      );
    } catch (error) {
      _performanceService.putAttribute(
        kTraceLoginPhone,
        kTraceAttrError,
        error.toString().truncate(100),
      );
      add(PhoneOtpErrorEvent(errorMessage: error.toString()));
    } finally {
      add(PhoneNumLoginLoadingEvent(isLoading: false));
      _performanceService.stopTrace(kTraceLoginPhone);
    }
  }

  Future<void> _loginUsingEmailAndPassword() async {
    _performanceService.startTrace(kTraceLoginEmailPassword);
    add(EmailLoginLoadingEvent(isLoading: true));
    final email = state.emailPasswordLoginState?.email ?? '';
    final password = state.emailPasswordLoginState?.password ?? '';

    final userCredential = await _firebaseAuthService
        .signInWithEmailAndPassword(
          email,
          password,
          onError: (error, {stackTrace}) {
            _performanceService.putAttribute(
              kTraceLoginEmailPassword,
              kTraceAttrError,
              error.truncate(100),
            );
            add(EmailLoginLoadingEvent(isLoading: false));
            add(AuthenticationExceptionEvent(errorMessage: error));
          },
        );

    if (userCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginEmailPassword,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        userCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    add(EmailLoginLoadingEvent(isLoading: false));
    _performanceService.stopTrace(kTraceLoginEmailPassword);
  }

  Future<void> _loginWithGoogle() async {
    _performanceService.startTrace(kTraceLoginGoogle);
    final userCredential = await _firebaseAuthService.loginWithGoogle(
      onError: (error, {stackTrace}) {
        _performanceService.putAttribute(
          kTraceLoginGoogle,
          kTraceAttrError,
          error.truncate(100),
        );
        add(AuthenticationExceptionEvent(errorMessage: error));
      },
    );

    if (userCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginGoogle,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        userCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    _performanceService.stopTrace(kTraceLoginGoogle);
  }

  Future<void> _loginWithApple() async {
    _performanceService.startTrace(kTraceLoginApple);
    final userCredential = await _firebaseAuthService.loginWithApple(
      onError: (error, {stackTrace}) {
        _performanceService.putAttribute(
          kTraceLoginApple,
          kTraceAttrError,
          error.truncate(100),
        );
        add(AuthenticationExceptionEvent(errorMessage: error));
      },
    );
    if (userCredential != null) {
      _performanceService.putAttribute(
        kTraceLoginApple,
        kTraceAttrSuccess,
        true,
      );
      await handleUserDetails(
        userCredential.user,
        onError: (error) =>
            add(AuthenticationExceptionEvent(errorMessage: error)),
      );
    }
    _performanceService.stopTrace(kTraceLoginApple);
  }

  Future<void> _sendPasswordResetLink() async {
    add(EmailLoginLoadingEvent(isLoading: true));
    await _firebaseAuthService.sendFBAuthPasswordResetEmail(
      state.emailPasswordLoginState?.email ?? '',
      onError: (error, {stackTrace}) =>
          add(EmailErrorEvent(errorMessage: error)),
    );
    add(EmailLoginLoadingEvent(isLoading: false));
    add(ResetPasswordLinkSentEvent());
  }

  Future<void> handleUserDetails(
    User? firebaseUser, {
    required Function(String) onError,
    AuthTokens? authTokens,
  }) async {
    final loginType = state.selectedLoginType;
    if (loginType == .PHONE) {
      if (authTokens == null) {
        onError('Authentication tokens could not be retrieved.');
        return;
      }

      try {
        await _storeLoginDetailsInPrefs(
          null,
          authTokens: authTokens,
          phoneNumber: state.phoneNumberLoginState?.phoneNumber,
        );
      } catch (error) {
        onError(error.toString());
        return;
      }

      try {
        await _initializeNotifications();
      } catch (error) {
        debugPrint('Notification initialization failed after login: $error');
      }

      if (state.isSignup) {
        add(NavigateToVerifiedScreenEvent());
      } else {
        add(NavigateToHomeScreenEvent());
      }
      return;
    }

    if (firebaseUser == null) {
      debugPrint('firebaseUser is null');
      onError('User information could not be retrieved.');
      return;
    } else if (loginType == .EMAIL) {
      if (firebaseUser.email.isNullOrEmpty()) {
        onError('Error retrieving your email');
        return;
      }
      add(EmailLoginLoadingEvent(isLoading: false));
      if (!firebaseUser.emailVerified) {
        add(SendEmailVerificationLinkEvent());
        add(NavigateToEmailVerifyScreenEvent());
        return;
      }

      await _storeLoginDetailsInPrefs(firebaseUser);
      add(NavigateToHomeScreenEvent());
    } else if (loginType == .GOOGLE) {
      await _storeLoginDetailsInPrefs(firebaseUser);
      add(NavigateToHomeScreenEvent());
    } else if (loginType == .APPLE) {
      await _storeLoginDetailsInPrefs(firebaseUser);
      add(NavigateToHomeScreenEvent());
    } else {
      debugPrint('Login/Signup type not specified');
      hideAllLoadingsAndShowError();
    }
  }

  Future<void> _storeLoginDetailsInPrefs(
    User? firebaseUser, {
    AuthTokens? authTokens,
    String? phoneNumber,
  }) async {
    late final LoginDetails loginDetails;
    if (authTokens != null) {
      final secureStorageService = _secureStorageService;
      if (secureStorageService == null) {
        throw StateError('Secure storage is not configured.');
      }

      await secureStorageService.writeAuthTokens(
        accessToken: authTokens.accessToken,
        refreshToken: authTokens.refreshToken,
      );
      loginDetails = LoginDetails(
        uid: null,
        phoneNumber: phoneNumber,
        accessToken: authTokens.accessToken,
        refreshToken: authTokens.refreshToken,
      );
    } else {
      if (firebaseUser == null) {
        throw StateError('User information could not be retrieved.');
      }

      loginDetails = LoginDetails(
        uid: firebaseUser.uid,
        token: await firebaseUser.getIdToken(),
        phoneNumber: firebaseUser.phoneNumber,
        email: firebaseUser.email,
      );
    }

    await Prefs.setString(
      PrefKeys.kUserDetails,
      json.encode(loginDetails.toJson()),
    );
    await Prefs.remove(PrefKeys.kSkippedLogin);
  }

  void _onNavigateToEmailVerifyScreenEvent(
    NavigateToEmailVerifyScreenEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(NavigateToEmailVerifyScreenState(state));
  }
}
