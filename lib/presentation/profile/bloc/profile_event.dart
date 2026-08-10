import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent({required this.profile});

  final MobileUserProfile profile;

  @override
  List<Object> get props => [profile];
}

class UpdateProfileAvatarEvent extends ProfileEvent {
  const UpdateProfileAvatarEvent({required this.image});

  final File image;

  @override
  List<Object> get props => [image];
}

class RemoveProfileAvatarEvent extends ProfileEvent {
  const RemoveProfileAvatarEvent();

  @override
  List<Object> get props => [];
}

class SignOutEvent extends ProfileEvent {
  const SignOutEvent();

  @override
  List<Object> get props => [];
}
