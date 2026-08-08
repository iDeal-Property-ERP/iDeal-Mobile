import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/biometric_auth/bloc/biometric_auth_event.dart';
import 'package:ideal_mobile/presentation/biometric_auth/bloc/biometric_auth_state.dart';
import 'package:ideal_mobile/services/local_auth_services.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';

class BiometricAuthBloc extends Bloc<BiometricAuthEvent, BiometricAuthState> {
  final LocalAuthService _localAuthService = sl();
  final AppLocalizations localizations;

  BiometricAuthBloc({required this.localizations})
    : super(const BiometricAuthState.initial()) {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    on<BiometricAuthToggleEvent>(_onBiometricAuthToggleEvent);
    on<GetBiometricEnrolledStatusEvent>(_onGetBiometricEnrolledStatusEvent);
  }

  Future<void> _onGetBiometricEnrolledStatusEvent(
    GetBiometricEnrolledStatusEvent event,
    Emitter<BiometricAuthState> emit,
  ) async {
    final isBiometricEnabled =
        await Prefs.getBool(PrefKeys.kIsBiometricEnabled) ?? false;
    final isBiometricSupported = await _localAuthService.isBiometricSupported;
    emit(
      state.copyWith(
        isBiometricEnrolled: isBiometricEnabled,
        isBiometricSupported: isBiometricSupported,
      ),
    );
  }

  Future<void> _onBiometricAuthToggleEvent(
    BiometricAuthToggleEvent event,
    Emitter<BiometricAuthState> emit,
  ) async {
    try {
      if (event.isBiometricEnabled) {
        final biometricAuthStatus = await _localAuthService.authenticate(
          localizations,
        );

        if (biometricAuthStatus == BiometricAuthStatus.notSupported) {
          await HapticFeedbackUtil.error();
          emit(
            IsBiometricAuthNotSupportedState(
              state,
              isBiometricSupported: false,
            ),
          );
          return;
        }

        if (biometricAuthStatus == BiometricAuthStatus.tooManyAttempts) {
          await HapticFeedbackUtil.error();
          emit(BioMetricsTooManyAttemptState(state));
          return;
        }

        if (biometricAuthStatus == BiometricAuthStatus.notEnrolled) {
          emit(BiometricAuthNotEnrolledState(state));
          return;
        }

        if (biometricAuthStatus == BiometricAuthStatus.success) {
          await HapticFeedbackUtil.success();
          await Prefs.setBool(PrefKeys.kIsBiometricEnabled, value: true);
          emit(IsBiometricAuthEnabledState(state, isBiometricEnrolled: true));
          emit(BiometricAuthSuccessState(state));
        } else {
          await HapticFeedbackUtil.error();
          emit(IsBiometricAuthEnabledState(state, isBiometricEnrolled: false));
          emit(BiometricAuthFailureState(state));
        }
      } else {
        final biometricAuthStatus = await _localAuthService.authenticate(
          localizations,
        );

        if (biometricAuthStatus == BiometricAuthStatus.tooManyAttempts) {
          await HapticFeedbackUtil.error();
          emit(BioMetricsTooManyAttemptState(state));
          return;
        }

        if (biometricAuthStatus == BiometricAuthStatus.success) {
          await HapticFeedbackUtil.warning();
          await Prefs.setBool(PrefKeys.kIsBiometricEnabled, value: false);
          emit(IsBiometricAuthEnabledState(state, isBiometricEnrolled: false));
        } else {
          await HapticFeedbackUtil.error();
          emit(BiometricAuthFailureState(state));
        }
      }
    } catch (e) {
      await HapticFeedbackUtil.error();
      emit(
        state.copyWith(isBiometricEnrolled: false, errorMessage: e.toString()),
      );
      emit(BiometricAuthFailureState(state));
    }
  }
}
