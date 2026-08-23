import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetPhoneChangeOtpMethods with UseCaseWithoutParams<List<String>> {
  const GetPhoneChangeOtpMethods(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<List<String>> call() => _repository.getPhoneChangeOtpMethods();
}
