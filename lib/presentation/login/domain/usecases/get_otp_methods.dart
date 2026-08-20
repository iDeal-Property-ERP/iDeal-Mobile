import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetOtpMethods with UseCaseWithoutParams<List<String>> {
  const GetOtpMethods(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<List<String>> call() => _repository.getOtpMethods();
}
