import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/repositories/profile_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ConfirmPhoneChange
    with UseCaseWithParams<MobileUserProfile, ConfirmPhoneChangeParams> {
  const ConfirmPhoneChange(this._repository);

  final ProfileRepository _repository;

  @override
  ResultFuture<MobileUserProfile> call(ConfirmPhoneChangeParams params) =>
      _repository.confirmPhoneChange(phone: params.phone, code: params.code);
}

class ConfirmPhoneChangeParams extends Equatable {
  const ConfirmPhoneChangeParams({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}
