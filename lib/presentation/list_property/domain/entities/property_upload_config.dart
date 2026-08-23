import 'package:equatable/equatable.dart';

class ChoiceOption extends Equatable {
  const ChoiceOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  List<Object?> get props => [value, label];
}

class DistrictOption extends Equatable {
  const DistrictOption({
    required this.id,
    required this.name,
    required this.city,
  });

  final int id;
  final String name;
  final String city;

  @override
  List<Object?> get props => [id, name, city];
}

class AmenityOption extends Equatable {
  const AmenityOption({
    required this.slug,
    required this.name,
    required this.icon,
  });

  final String slug;
  final String name;
  final String icon;

  @override
  List<Object?> get props => [slug, name, icon];
}

class PublicOfferDetail extends Equatable {
  const PublicOfferDetail({this.id, this.version, this.body});

  final int? id;
  final String? version;
  final String? body;

  @override
  List<Object?> get props => [id, version, body];
}

class UserContactProfile extends Equatable {
  const UserContactProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}

class PropertyUploadConfig extends Equatable {
  const PropertyUploadConfig({
    required this.propertyTypes,
    required this.districts,
    required this.furnishings,
    required this.amenities,
    required this.minimumStays,
    required this.priceIncludes,
    required this.currencies,
    required this.publicOffer,
    this.userProfile,
  });

  final List<ChoiceOption> propertyTypes;
  final List<DistrictOption> districts;
  final List<ChoiceOption> furnishings;
  final List<AmenityOption> amenities;
  final List<int> minimumStays;
  final List<ChoiceOption> priceIncludes;
  final List<String> currencies;
  final PublicOfferDetail publicOffer;
  final UserContactProfile? userProfile;

  @override
  List<Object?> get props => [
    propertyTypes,
    districts,
    furnishings,
    amenities,
    minimumStays,
    priceIncludes,
    currencies,
    publicOffer,
    userProfile,
  ];
}
