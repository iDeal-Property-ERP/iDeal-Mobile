import 'dart:io';

import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/data/models/phone_change_otp_challenge.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ProfileRepository {
  ResultFuture<MobileUserProfile> getProfile();

  ResultFuture<MobileUserProfile> updateProfile(MobileUserProfile profile);

  ResultFuture<MobileUserProfile> updateAvatar(File image);

  ResultFuture<MobileUserProfile> removeAvatar();

  ResultFuture<List<String>> getPhoneChangeOtpMethods();

  ResultFuture<PhoneChangeOtpChallenge> requestPhoneChangeOtp({
    required String phone,
    required String channel,
  });

  ResultFuture<MobileUserProfile> confirmPhoneChange({
    required String phone,
    required String code,
  });
}
