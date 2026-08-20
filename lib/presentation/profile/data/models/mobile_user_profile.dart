import 'package:equatable/equatable.dart';

class MobileUserProfile extends Equatable {
  const MobileUserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patronymic,
    this.email,
    required this.phone,
    required this.nationality,
    required this.avatarUrl,
  });

  final int id;
  final String firstName;
  final String? lastName;
  final String? patronymic;
  final String? email;
  final String? phone;
  final String? nationality;
  final String? avatarUrl;

  String get displayName => [
    firstName,
    lastName,
  ].whereType<String>().where((value) => value.isNotEmpty).join(' ');

  factory MobileUserProfile.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final firstName = json['first_name'];

    if (id is! int || firstName is! String) {
      throw const FormatException('Profile details are incomplete.');
    }

    return MobileUserProfile(
      id: id,
      firstName: firstName,
      lastName: _nullableString(json, 'last_name'),
      patronymic: _nullableString(json, 'patronymic'),
      email: _nullableString(json, 'email'),
      phone: _nullableString(json, 'phone'),
      nationality: _nullableString(json, 'nationality'),
      avatarUrl: _nullableString(json, 'avatar_url'),
    );
  }

  static String? _nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$key must be a string or null.');
    }
    return value;
  }

  Map<String, dynamic> toUpdateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'patronymic': patronymic,
    'email': email,
    'nationality': nationality,
  };

  MobileUserProfile copyWith({
    String? firstName,
    String? lastName,
    bool clearLastName = false,
    String? patronymic,
    bool clearPatronymic = false,
    String? email,
    bool clearEmail = false,
    String? nationality,
    bool clearNationality = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return MobileUserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: clearLastName ? null : lastName ?? this.lastName,
      patronymic: clearPatronymic ? null : patronymic ?? this.patronymic,
      email: clearEmail ? null : email ?? this.email,
      phone: phone,
      nationality: clearNationality ? null : nationality ?? this.nationality,
      avatarUrl: clearAvatarUrl ? null : avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    patronymic,
    email,
    phone,
    nationality,
    avatarUrl,
  ];
}
