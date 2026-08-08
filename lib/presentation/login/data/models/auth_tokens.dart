import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'];
    final refreshToken = json['refresh_token'];

    if (accessToken is! String || accessToken.trim().isEmpty) {
      throw const FormatException('Access token is missing.');
    }
    if (refreshToken is! String || refreshToken.trim().isEmpty) {
      throw const FormatException('Refresh token is missing.');
    }

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  Map<String, String> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
