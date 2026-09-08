import 'package:equatable/equatable.dart';

sealed class ListPropertyWizardEvent extends Equatable {
  const ListPropertyWizardEvent();

  @override
  List<Object?> get props => [];
}

class ListPropertyWizardStarted extends ListPropertyWizardEvent {
  const ListPropertyWizardStarted();
}

class ListPropertyStepChanged extends ListPropertyWizardEvent {
  const ListPropertyStepChanged(this.step);

  final int step;

  @override
  List<Object?> get props => [step];
}

class ListPropertyDetailsUpdated extends ListPropertyWizardEvent {
  const ListPropertyDetailsUpdated({
    this.propertyType,
    this.name,
    this.rooms,
    this.floor,
    this.totalFloors,
    this.areaSqm,
    this.furnishing,
    this.description,
    this.districtId,
    this.landmark,
  });

  final String? propertyType;
  final String? name;
  final int? rooms;
  final int? floor;
  final int? totalFloors;
  final int? areaSqm;
  final String? furnishing;
  final String? description;
  final int? districtId;
  final String? landmark;

  @override
  List<Object?> get props => [
    propertyType,
    name,
    rooms,
    floor,
    totalFloors,
    areaSqm,
    furnishing,
    description,
    districtId,
    landmark,
  ];
}

class ListPropertyLocationUpdated extends ListPropertyWizardEvent {
  const ListPropertyLocationUpdated({
    this.districtId,
    this.address,
    this.landmark,
    this.latitude,
    this.longitude,
  });

  final int? districtId;
  final String? address;
  final String? landmark;
  final double? latitude;
  final double? longitude;

  @override
  List<Object?> get props => [
    districtId,
    address,
    landmark,
    latitude,
    longitude,
  ];
}

class ListPropertyAmenityToggled extends ListPropertyWizardEvent {
  const ListPropertyAmenityToggled(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

class ListPropertyPhotosAdded extends ListPropertyWizardEvent {
  const ListPropertyPhotosAdded(this.paths);

  final List<String> paths;

  @override
  List<Object?> get props => [paths];
}

class ListPropertyPhotoRemoved extends ListPropertyWizardEvent {
  const ListPropertyPhotoRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class ListPropertyPhotoSetPrimary extends ListPropertyWizardEvent {
  const ListPropertyPhotoSetPrimary(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class ListPropertyPricingUpdated extends ListPropertyWizardEvent {
  const ListPropertyPricingUpdated({
    this.monthlyPrice,
    this.depositAmount,
    this.currency,
    this.minimumStay,
  });

  final double? monthlyPrice;
  final double? depositAmount;
  final String? currency;
  final int? minimumStay;

  @override
  List<Object?> get props => [
    monthlyPrice,
    depositAmount,
    currency,
    minimumStay,
  ];
}

class ListPropertyPriceIncludeToggled extends ListPropertyWizardEvent {
  const ListPropertyPriceIncludeToggled(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

class ListPropertyContactUpdated extends ListPropertyWizardEvent {
  const ListPropertyContactUpdated({
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

class ListPropertyAcceptOfferToggled extends ListPropertyWizardEvent {
  const ListPropertyAcceptOfferToggled({required this.accepted});

  final bool accepted;

  @override
  List<Object?> get props => [accepted];
}

class ListPropertyStepAdvanceRequested extends ListPropertyWizardEvent {
  const ListPropertyStepAdvanceRequested();
}

class ListPropertySubmitted extends ListPropertyWizardEvent {
  const ListPropertySubmitted();
}
