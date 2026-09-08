import 'package:equatable/equatable.dart';

class PropertyContact extends Equatable {
  const PropertyContact({
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
  });

  final String firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    if (lastName != null && lastName!.isNotEmpty) 'last_name': lastName,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (phone != null && phone!.isNotEmpty) 'phone': phone,
  };

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}

class PropertyUploadPayload extends Equatable {
  const PropertyUploadPayload({
    this.name,
    this.contentLocale,
    required this.propertyType,
    required this.districtId,
    this.address,
    this.landmark,
    required this.latitude,
    required this.longitude,
    required this.rooms,
    required this.floor,
    this.totalFloors,
    required this.areaSqm,
    required this.furnishing,
    this.description,
    required this.amenities,
    required this.monthlyPrice,
    this.depositAmount,
    required this.currency,
    this.minimumStay,
    required this.priceIncludes,
    required this.acceptOffer,
    this.contact,
    required this.imagePaths,
  });

  final String? name;
  final String? contentLocale;
  final String propertyType;
  final int districtId;
  final String? address;
  final String? landmark;
  final double latitude;
  final double longitude;
  final int rooms;
  final int floor;
  final int? totalFloors;
  final int areaSqm;
  final String furnishing;
  final String? description;
  final List<String> amenities;
  final double monthlyPrice;
  final double? depositAmount;
  final String currency;
  final int? minimumStay;
  final List<String> priceIncludes;
  final bool acceptOffer;
  final PropertyContact? contact;
  final List<String> imagePaths;

  Map<String, dynamic> toJson() => {
    if (name != null && name!.isNotEmpty) 'name': name,
    if (contentLocale != null && contentLocale!.isNotEmpty)
      'content_locale': contentLocale,
    'property_type': propertyType,
    'district_id': districtId,
    if (address != null && address!.isNotEmpty) 'address': address,
    if (landmark != null && landmark!.isNotEmpty) 'landmark': landmark,
    'map_lat': latitude,
    'map_lon': longitude,
    'rooms': rooms,
    'floor': floor,
    if (totalFloors != null) 'total_floors': totalFloors,
    'area_sqm': areaSqm,
    'furnishing': furnishing,
    if (description != null && description!.isNotEmpty)
      'description': description,
    'amenities': amenities,
    'monthly_price': monthlyPrice,
    if (depositAmount != null) 'deposit_amount': depositAmount,
    'currency': currency,
    if (minimumStay != null) 'minimum_stay': minimumStay,
    'price_includes': priceIncludes,
    'accept_offer': acceptOffer,
    if (contact != null) 'contact': contact!.toJson(),
  };

  @override
  List<Object?> get props => [
    name,
    contentLocale,
    propertyType,
    districtId,
    address,
    landmark,
    latitude,
    longitude,
    rooms,
    floor,
    totalFloors,
    areaSqm,
    furnishing,
    description,
    amenities,
    monthlyPrice,
    depositAmount,
    currency,
    minimumStay,
    priceIncludes,
    acceptOffer,
    contact,
    imagePaths,
  ];
}

class PropertyUploadResult extends Equatable {
  const PropertyUploadResult({
    required this.id,
    required this.propertyId,
    required this.status,
    required this.message,
  });

  final int id;
  final int propertyId;
  final String status;
  final String message;

  @override
  List<Object?> get props => [id, propertyId, status, message];
}
