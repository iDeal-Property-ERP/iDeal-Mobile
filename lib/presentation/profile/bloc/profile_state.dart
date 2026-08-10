import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';

class ProfileState with EquatableMixin {
  const ProfileState({
    required this.profile,
    required this.isProfileLoading,
    required this.isProfileUpdating,
    required this.isAvatarUpdating,
    required this.profileError,
  });

  const ProfileState.initial({
    this.profile,
    this.isProfileLoading = false,
    this.isProfileUpdating = false,
    this.isAvatarUpdating = false,
    this.profileError,
  });

  final MobileUserProfile? profile;
  final bool isProfileLoading;
  final bool isProfileUpdating;
  final bool isAvatarUpdating;
  final String? profileError;

  String get name => profile?.displayName ?? '';
  String get email => profile?.email ?? '';

  ProfileState copyWith({
    MobileUserProfile? profile,
    bool? isProfileLoading,
    bool? isProfileUpdating,
    bool? isAvatarUpdating,
    String? profileError,
    bool clearProfileError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
      isAvatarUpdating: isAvatarUpdating ?? this.isAvatarUpdating,
      profileError: clearProfileError
          ? null
          : profileError ?? this.profileError,
    );
  }

  @visibleForTesting
  const ProfileState.test({
    this.profile,
    this.isProfileLoading = false,
    this.isProfileUpdating = false,
    this.isAvatarUpdating = false,
    this.profileError,
  });

  @override
  List<Object?> get props => [
    profile,
    isProfileLoading,
    isProfileUpdating,
    isAvatarUpdating,
    profileError,
  ];
}

class SignOutState extends ProfileState {
  SignOutState() : super.initial();
}

class SignOutErrorState extends ProfileState {
  final String errorMessage;

  SignOutErrorState({this.errorMessage = ''}) : super.initial();
}
