import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/get_property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/submit_property_upload.dart';
import 'package:ideal_mobile/services/locale_service.dart';

class ListPropertyWizardBloc
    extends Bloc<ListPropertyWizardEvent, ListPropertyWizardState> {
  ListPropertyWizardBloc({
    required GetPropertyUploadConfig getConfig,
    required SubmitPropertyUpload submitProperty,
  }) : _getConfig = getConfig,
       _submitProperty = submitProperty,
       super(const ListPropertyWizardState()) {
    on<ListPropertyWizardStarted>(_onStarted);
    on<ListPropertyStepChanged>(_onStepChanged);
    on<ListPropertyDetailsUpdated>(_onDetailsUpdated);
    on<ListPropertyAmenityToggled>(_onAmenityToggled);
    on<ListPropertyPhotosAdded>(_onPhotosAdded);
    on<ListPropertyPhotoRemoved>(_onPhotoRemoved);
    on<ListPropertyPhotoSetPrimary>(_onPhotoSetPrimary);
    on<ListPropertyPricingUpdated>(_onPricingUpdated);
    on<ListPropertyPriceIncludeToggled>(_onPriceIncludeToggled);
    on<ListPropertyContactUpdated>(_onContactUpdated);
    on<ListPropertyAcceptOfferToggled>(_onAcceptOfferToggled);
    on<ListPropertyStepAdvanceRequested>(_onStepAdvanceRequested);
    on<ListPropertySubmitted>(_onSubmitted);
  }

  final GetPropertyUploadConfig _getConfig;
  final SubmitPropertyUpload _submitProperty;

  Future<void> _onStarted(
    ListPropertyWizardStarted event,
    Emitter<ListPropertyWizardState> emit,
  ) async {
    emit(state.copyWith(status: WizardStatus.loadingConfig));
    final result = await _getConfig();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WizardStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (config) {
        final profile = config.userProfile;
        emit(
          state.copyWith(
            status: WizardStatus.configReady,
            config: config,
            firstName: state.firstName.isNotEmpty
                ? state.firstName
                : (profile?.firstName ?? ''),
            lastName: state.lastName ?? profile?.lastName,
            email: state.email ?? profile?.email,
            phone: state.phone ?? profile?.phone,
          ),
        );
      },
    );
  }

  void _onStepChanged(
    ListPropertyStepChanged event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    emit(
      state.copyWith(
        currentStep: event.step,
        showValidationErrors: false,
        clearErrorMessage: true,
      ),
    );
  }

  void _onDetailsUpdated(
    ListPropertyDetailsUpdated event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    emit(
      state.copyWith(
        propertyType: event.propertyType ?? state.propertyType,
        name: event.name ?? state.name,
        districtId: event.districtId ?? state.districtId,
        rooms: event.rooms ?? state.rooms,
        floor: event.floor ?? state.floor,
        totalFloors: event.totalFloors ?? state.totalFloors,
        areaSqm: event.areaSqm ?? state.areaSqm,
        furnishing: event.furnishing ?? state.furnishing,
        description: event.description ?? state.description,
        clearErrorMessage: true,
      ),
    );
  }

  void _onAmenityToggled(
    ListPropertyAmenityToggled event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    final updated = Set<String>.from(state.amenities);
    if (updated.contains(event.slug)) {
      updated.remove(event.slug);
    } else {
      updated.add(event.slug);
    }
    emit(state.copyWith(amenities: updated, clearErrorMessage: true));
  }

  void _onPhotosAdded(
    ListPropertyPhotosAdded event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    final updated = List<String>.from(state.imagePaths);
    for (final path in event.paths) {
      if (!updated.contains(path)) {
        updated.add(path);
      }
    }
    emit(state.copyWith(imagePaths: updated, clearErrorMessage: true));
  }

  void _onPhotoRemoved(
    ListPropertyPhotoRemoved event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    if (event.index < 0 || event.index >= state.imagePaths.length) return;
    final updated = List<String>.from(state.imagePaths)..removeAt(event.index);
    emit(state.copyWith(imagePaths: updated, clearErrorMessage: true));
  }

  void _onPhotoSetPrimary(
    ListPropertyPhotoSetPrimary event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    if (event.index < 0 || event.index >= state.imagePaths.length) return;
    final updated = List<String>.from(state.imagePaths);
    final selected = updated.removeAt(event.index);
    updated.insert(0, selected);
    emit(state.copyWith(imagePaths: updated, clearErrorMessage: true));
  }

  void _onPricingUpdated(
    ListPropertyPricingUpdated event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    emit(
      state.copyWith(
        monthlyPrice: event.monthlyPrice ?? state.monthlyPrice,
        depositAmount: event.depositAmount ?? state.depositAmount,
        currency: event.currency ?? state.currency,
        minimumStay: event.minimumStay ?? state.minimumStay,
        clearErrorMessage: true,
      ),
    );
  }

  void _onPriceIncludeToggled(
    ListPropertyPriceIncludeToggled event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    final updated = Set<String>.from(state.priceIncludes);
    if (updated.contains(event.slug)) {
      updated.remove(event.slug);
    } else {
      updated.add(event.slug);
    }
    emit(state.copyWith(priceIncludes: updated, clearErrorMessage: true));
  }

  void _onContactUpdated(
    ListPropertyContactUpdated event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    emit(
      state.copyWith(
        firstName: event.firstName ?? state.firstName,
        lastName: event.lastName ?? state.lastName,
        email: event.email ?? state.email,
        phone: event.phone ?? state.phone,
        clearErrorMessage: true,
      ),
    );
  }

  void _onAcceptOfferToggled(
    ListPropertyAcceptOfferToggled event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    emit(state.copyWith(acceptOffer: event.accepted, clearErrorMessage: true));
  }

  void _onStepAdvanceRequested(
    ListPropertyStepAdvanceRequested event,
    Emitter<ListPropertyWizardState> emit,
  ) {
    switch (state.currentStep) {
      case 0:
        if (!state.isDetailsValid) {
          emit(
            state.copyWith(
              showValidationErrors: true,
              errorMessage: 'Please fill in all required property details.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            currentStep: 1,
            showValidationErrors: false,
            clearErrorMessage: true,
          ),
        );
      case 1:
        if (!state.isPhotosValid) {
          emit(
            state.copyWith(
              showValidationErrors: true,
              errorMessage: 'At least 5 photos are required to continue.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            currentStep: 2,
            showValidationErrors: false,
            clearErrorMessage: true,
          ),
        );
      case 2:
        if (!state.isPricingValid) {
          emit(
            state.copyWith(
              showValidationErrors: true,
              errorMessage: 'Please specify monthly rent price.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            currentStep: 3,
            showValidationErrors: false,
            clearErrorMessage: true,
          ),
        );
      case 3:
        if (!state.isContactValid) {
          emit(
            state.copyWith(
              showValidationErrors: true,
              errorMessage: 'Please provide your name and contact info.',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            currentStep: 4,
            showValidationErrors: false,
            clearErrorMessage: true,
          ),
        );
      case 4:
        add(const ListPropertySubmitted());
      default:
        break;
    }
  }

  Future<void> _onSubmitted(
    ListPropertySubmitted event,
    Emitter<ListPropertyWizardState> emit,
  ) async {
    if (!state.acceptOffer) {
      emit(
        state.copyWith(
          showValidationErrors: true,
          errorMessage: 'Please accept the public offer to publish.',
        ),
      );
      return;
    }
    if (!state.isPhotosValid) {
      emit(
        state.copyWith(
          showValidationErrors: true,
          errorMessage: 'At least 5 photos are required.',
        ),
      );
      return;
    }
    if (!state.isDetailsValid || !state.isPricingValid) {
      emit(
        state.copyWith(
          showValidationErrors: true,
          errorMessage: 'Please complete all required steps.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: WizardStatus.submitting, clearErrorMessage: true),
    );

    final payload = PropertyUploadPayload(
      name: state.name?.trim(),
      contentLocale: LocaleService.locale.value?.languageCode ?? 'uz',
      propertyType: state.propertyType!,
      districtId: state.districtId!,
      rooms: state.rooms!,
      floor: state.floor!,
      totalFloors: state.totalFloors,
      areaSqm: state.areaSqm!,
      furnishing: state.furnishing!,
      description: state.description?.trim(),
      amenities: state.amenities.toList(),
      monthlyPrice: state.monthlyPrice!,
      depositAmount: state.depositAmount,
      currency: state.currency,
      minimumStay: state.minimumStay,
      priceIncludes: state.priceIncludes.toList(),
      acceptOffer: state.acceptOffer,
      contact: PropertyContact(
        firstName: state.firstName.trim(),
        lastName: state.lastName?.trim(),
        email: state.email?.trim(),
        phone: state.phone?.trim(),
      ),
      imagePaths: state.imagePaths,
    );

    final result = await _submitProperty(payload);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WizardStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (res) => emit(
        state.copyWith(
          status: WizardStatus.submitted,
          currentStep: 5,
          createdListingId: res.id,
          showValidationErrors: false,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
