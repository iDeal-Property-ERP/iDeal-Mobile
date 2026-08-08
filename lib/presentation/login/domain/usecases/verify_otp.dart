import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/login/data/models/auth_tokens.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class VerifyOtp with UseCaseWithParams<AuthTokens, VerifyOtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<AuthTokens> call(VerifyOtpParams params) =>
      _repository.verifyOtp(phone: params.phone, code: params.code);
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}
