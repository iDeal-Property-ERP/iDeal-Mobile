import 'package:equatable/equatable.dart';

class LoginDetails extends Equatable {
  final String? uid;
  final String? token;
  final String? email;
  final String? phoneNumber;
  final String? accessToken;
  final String? refreshToken;

  const LoginDetails({
    required this.uid,
    this.token,
    this.email,
    this.phoneNumber,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginDetails.fromJson(Map<String, dynamic> json) {
    return LoginDetails(
      uid: json['uid'],
      token: json['token'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'token': token,
      'email': email,
      'phoneNumber': phoneNumber,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  List<Object?> get props => [
    uid,
    token,
    email,
    phoneNumber,
    accessToken,
    refreshToken,
  ];
}
