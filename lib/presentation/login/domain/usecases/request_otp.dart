import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/login/domain/repositories/auth_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class RequestOtp with UseCaseWithParams<void, RequestOtpParams> {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  @override
  ResultVoid call(RequestOtpParams params) =>
      _repository.requestOtp(phone: params.phone, channel: params.channel);
}

class RequestOtpParams extends Equatable {
  const RequestOtpParams({required this.phone, required this.channel});

  final String phone;
  final String channel;

  @override
  List<Object?> get props => [phone, channel];
}
