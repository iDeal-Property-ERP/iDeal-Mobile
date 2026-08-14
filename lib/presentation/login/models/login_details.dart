import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';

class LoginDetails extends Equatable {
  const LoginDetails({this.phoneNumber, this.accessToken, this.refreshToken});

  final String? phoneNumber;
  final String? accessToken;
  final String? refreshToken;

  static Future<LoginDetails> fromPrefs() async {
    final value = await Prefs.getString(PrefKeys.kUserDetails);
    if (value == null || value.isEmpty) return const LoginDetails();

    try {
      return LoginDetails.fromJson(json.decode(value) as Map<String, dynamic>);
    } on FormatException {
      return const LoginDetails();
    }
  }

  factory LoginDetails.fromJson(Map<String, dynamic> json) => LoginDetails(
    phoneNumber: json['phoneNumber'] as String?,
    accessToken: json['accessToken'] as String?,
    refreshToken: json['refreshToken'] as String?,
  );

  Map<String, String?> toJson() => {
    'phoneNumber': phoneNumber,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  @override
  List<Object?> get props => [phoneNumber, accessToken, refreshToken];
}
