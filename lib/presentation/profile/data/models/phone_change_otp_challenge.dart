import 'package:equatable/equatable.dart';

class PhoneChangeOtpChallenge extends Equatable {
  const PhoneChangeOtpChallenge({
    required this.channel,
    required this.expiresIn,
    required this.resendAfter,
  });

  final String channel;
  final int expiresIn;
  final int resendAfter;

  factory PhoneChangeOtpChallenge.fromJson(Map<String, dynamic> json) {
    final channel = json['channel'];
    final expiresIn = json['expires_in'];
    final resendAfter = json['resend_after'];
    if (channel is! String || expiresIn is! int || resendAfter is! int) {
      throw const FormatException('Phone-change OTP details are incomplete.');
    }
    return PhoneChangeOtpChallenge(
      channel: channel,
      expiresIn: expiresIn,
      resendAfter: resendAfter,
    );
  }

  @override
  List<Object?> get props => [channel, expiresIn, resendAfter];
}
