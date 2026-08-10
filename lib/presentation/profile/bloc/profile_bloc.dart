import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/services/firebase_auth_services.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    GetProfile? getProfile,
    UpdateProfile? updateProfile,
    UpdateProfileAvatar? updateProfileAvatar,
    RemoveProfileAvatar? removeProfileAvatar,
    PerformanceMonitoringService? performanceService,
  }) : _getProfile = getProfile ?? sl<GetProfile>(),
       _updateProfile = updateProfile ?? sl<UpdateProfile>(),
       _updateProfileAvatar = updateProfileAvatar ?? sl<UpdateProfileAvatar>(),
       _removeProfileAvatar = removeProfileAvatar ?? sl<RemoveProfileAvatar>(),
       _performanceService =
           performanceService ?? sl<PerformanceMonitoringService>(),
       super(const ProfileState.initial()) {
    _setupEventListener();
  }

  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UpdateProfileAvatar _updateProfileAvatar;
  final RemoveProfileAvatar _removeProfileAvatar;
  final PerformanceMonitoringService _performanceService;

  @override
  void onTransition(Transition<ProfileEvent, ProfileState> transition) {
    super.onTransition(transition);
    debugPrint('Transition: $transition');
  }

  void _setupEventListener() {
    on<LoadProfileEvent>(_onLoadProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<UpdateProfileAvatarEvent>(_onUpdateProfileAvatarEvent);
    on<RemoveProfileAvatarEvent>(_onRemoveProfileAvatarEvent);
    on<SignOutEvent>(_onSignOutEvent);
  }

  Future<void> _onUpdateProfileAvatarEvent(
    UpdateProfileAvatarEvent event,
    Emitter<ProfileState> emit,
  ) => _updateAvatar(event.image, emit);

  Future<void> _onRemoveProfileAvatarEvent(
    RemoveProfileAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isAvatarUpdating: true, clearProfileError: true));
    final result = await _removeProfileAvatar();
    _emitAvatarResult(result, emit);
  }

  Future<void> _updateAvatar(File image, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isAvatarUpdating: true, clearProfileError: true));
    final result = await _updateProfileAvatar(UpdateProfileAvatarParams(image));
    _emitAvatarResult(result, emit);
  }

  void _emitAvatarResult(
    Either<Failure, MobileUserProfile> result,
    Emitter<ProfileState> emit,
  ) {
    result.fold(
      (failure) => emit(
        state.copyWith(isAvatarUpdating: false, profileError: failure.message),
      ),
      (profile) => emit(
        state.copyWith(
          profile: profile,
          isAvatarUpdating: false,
          clearProfileError: true,
        ),
      ),
    );
  }

  Future<void> _onLoadProfileEvent(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isProfileLoading: true, clearProfileError: true));

    final result = await _getProfile();
    result.fold(
      (failure) => emit(
        state.copyWith(isProfileLoading: false, profileError: failure.message),
      ),
      (profile) => emit(
        state.copyWith(
          profile: profile,
          isProfileLoading: false,
          clearProfileError: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isProfileUpdating: true, clearProfileError: true));

    final result = await _updateProfile(UpdateProfileParams(event.profile));
    result.fold(
      (failure) => emit(
        state.copyWith(isProfileUpdating: false, profileError: failure.message),
      ),
      (profile) => emit(
        state.copyWith(
          profile: profile,
          isProfileUpdating: false,
          clearProfileError: true,
        ),
      ),
    );
  }

  void _onSignOutEvent(SignOutEvent event, Emitter<ProfileState> emit) async {
    try {
      await NotificationService.instance.unregisterDevice();
      await Prefs.clear();
      if (sl.isRegistered<SecureStorageService>()) {
        await sl<SecureStorageService>().clearAuthTokens();
      }
      await sl<CacheManager>().clearCachedApiResponse();
      await FirebaseAuthService().signOut();
      _performanceService.putAttribute(kTraceSignOut, kTraceAttrSuccess, true);
      await HapticFeedbackUtil.light();
      emit(SignOutState());
    } catch (e) {
      debugPrint('Error signing out: $e');
      _performanceService.putAttribute(
        kTraceSignOut,
        kTraceAttrError,
        e.toString().truncate(100),
      );
      await HapticFeedbackUtil.error();
      emit(SignOutErrorState(errorMessage: e.toString()));
    } finally {
      _performanceService.stopTrace(kTraceSignOut);
    }
  }
}
