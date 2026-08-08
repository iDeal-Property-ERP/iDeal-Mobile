import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class UpdateProfile
    with UseCaseWithParams<MobileUserProfile, UpdateProfileParams> {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<MobileUserProfile> call(UpdateProfileParams params) =>
      _repository.updateProfile(params.profile);
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams(this.profile);

  final MobileUserProfile profile;

  @override
  List<Object?> get props => [profile];
}
