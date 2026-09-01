import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';

enum WizardStatus {
  initial,
  loadingConfig,
  configReady,
  submitting,
  submitted,
  error,
}

class ListPropertyWizardState extends Equatable {
  const ListPropertyWizardState({
    this.status = WizardStatus.initial,
    this.currentStep = 0,
    this.config,
    this.propertyType,
    this.name,
    this.districtId,
    this.landmark,
    this.rooms,
    this.floor,
    this.totalFloors,
    this.areaSqm,
    this.furnishing,
    this.description,
    this.amenities = const {},
    this.imagePaths = const [],
    this.monthlyPrice,
    this.depositAmount,
    this.currency = 'USD',
    this.minimumStay,
    this.priceIncludes = const {},
    this.firstName = '',
    this.lastName,
    this.email,
    this.phone,
    this.acceptOffer = false,
    this.showValidationErrors = false,
    this.errorMessage,
    this.createdListingId,
  });

  final WizardStatus status;
  final int currentStep;
  final PropertyUploadConfig? config;

  // Details Step (No defaults - all start null)
  final String? propertyType;
  final String? name;
  final int? districtId;
  final String? landmark;
  final int? rooms;
  final int? floor;
  final int? totalFloors;
  final int? areaSqm;
  final String? furnishing;
  final String? description;
  final Set<String> amenities;

  // Photos Step
  final List<String> imagePaths;

  // Pricing Step (No defaults - start null)
  final double? monthlyPrice;
  final double? depositAmount;
  final String currency;
  final int? minimumStay;
  final Set<String> priceIncludes;

  // Contact Step
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  // Review Step
  final bool acceptOffer;

  // Validation
  final bool showValidationErrors;
  final String? errorMessage;
  final int? createdListingId;

  bool get isDetailsValid =>
      propertyType != null &&
      propertyType!.isNotEmpty &&
      districtId != null &&
      (landmark == null ||
          (landmark!
                      .trim()
                      .split(RegExp(r'\s+'))
                      .where((w) => w.isNotEmpty)
                      .length <=
                  5 &&
              landmark!.trim().length <= 100)) &&
      rooms != null &&
      rooms! > 0 &&
      floor != null &&
      floor! >= 0 &&
      (totalFloors == null || totalFloors! >= floor!) &&
      areaSqm != null &&
      areaSqm! > 0 &&
      furnishing != null &&
      furnishing!.isNotEmpty;

  bool get isPhotosValid => imagePaths.length >= 5;

  bool get isPricingValid => monthlyPrice != null && monthlyPrice! > 0;

  bool get isContactValid =>
      firstName.trim().isNotEmpty &&
      ((phone != null && phone!.trim().isNotEmpty) ||
          (email != null && email!.trim().isNotEmpty));

  bool get isReviewValid => acceptOffer;

  ListPropertyWizardState copyWith({
    WizardStatus? status,
    int? currentStep,
    PropertyUploadConfig? config,
    String? propertyType,
    String? name,
    int? districtId,
    String? landmark,
    int? rooms,
    int? floor,
    int? totalFloors,
    int? areaSqm,
    String? furnishing,
    String? description,
    Set<String>? amenities,
    List<String>? imagePaths,
    double? monthlyPrice,
    double? depositAmount,
    String? currency,
    int? minimumStay,
    Set<String>? priceIncludes,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? acceptOffer,
    bool? showValidationErrors,
    String? errorMessage,
    int? createdListingId,
    bool clearErrorMessage = false,
  }) {
    return ListPropertyWizardState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      config: config ?? this.config,
      propertyType: propertyType ?? this.propertyType,
      name: name ?? this.name,
      districtId: districtId ?? this.districtId,
      landmark: landmark ?? this.landmark,
      rooms: rooms ?? this.rooms,
      floor: floor ?? this.floor,
      totalFloors: totalFloors ?? this.totalFloors,
      areaSqm: areaSqm ?? this.areaSqm,
      furnishing: furnishing ?? this.furnishing,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      imagePaths: imagePaths ?? this.imagePaths,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      currency: currency ?? this.currency,
      minimumStay: minimumStay ?? this.minimumStay,
      priceIncludes: priceIncludes ?? this.priceIncludes,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      acceptOffer: acceptOffer ?? this.acceptOffer,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      createdListingId: createdListingId ?? this.createdListingId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStep,
    config,
    propertyType,
    name,
    districtId,
    landmark,
    rooms,
    floor,
    totalFloors,
    areaSqm,
    furnishing,
    description,
    amenities,
    imagePaths,
    monthlyPrice,
    depositAmount,
    currency,
    minimumStay,
    priceIncludes,
    firstName,
    lastName,
    email,
    phone,
    acceptOffer,
    showValidationErrors,
    errorMessage,
    createdListingId,
  ];
}
