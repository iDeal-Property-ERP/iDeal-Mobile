import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/data/models/phone_change_otp_challenge.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class RequestPhoneChangeOtp
    with
        UseCaseWithParams<
          PhoneChangeOtpChallenge,
          RequestPhoneChangeOtpParams
        > {
  const RequestPhoneChangeOtp(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<PhoneChangeOtpChallenge> call(
    RequestPhoneChangeOtpParams params,
  ) => _repository.requestPhoneChangeOtp(
    phone: params.phone,
    channel: params.channel,
  );
}

class RequestPhoneChangeOtpParams extends Equatable {
  const RequestPhoneChangeOtpParams({
    required this.phone,
    required this.channel,
  });

  final String phone;
  final String channel;

  @override
  List<Object?> get props => [phone, channel];
}
