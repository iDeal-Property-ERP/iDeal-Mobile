import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetProfile with UseCaseWithoutParams<MobileUserProfile> {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<MobileUserProfile> call() => _repository.getProfile();
}
