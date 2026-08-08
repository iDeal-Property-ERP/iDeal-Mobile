import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class UpdateProfileAvatar
    with UseCaseWithParams<MobileUserProfile, UpdateProfileAvatarParams> {
  const UpdateProfileAvatar(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<MobileUserProfile> call(UpdateProfileAvatarParams params) =>
      _repository.updateAvatar(params.image);
}

class UpdateProfileAvatarParams extends Equatable {
  const UpdateProfileAvatarParams(this.image);

  final File image;

  @override
  List<Object?> get props => [image];
}
