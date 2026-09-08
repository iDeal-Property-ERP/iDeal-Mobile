import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/get_property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/submit_property_upload.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPropertyUploadConfig extends Mock
    implements GetPropertyUploadConfig {}

class MockSubmitPropertyUpload extends Mock implements SubmitPropertyUpload {}

class FakePropertyUploadPayload extends Fake implements PropertyUploadPayload {}

void main() {
  late MockGetPropertyUploadConfig mockGetConfig;
  late MockSubmitPropertyUpload mockSubmit;
  late ListPropertyWizardBloc bloc;

  const sampleConfig = PropertyUploadConfig(
    propertyTypes: [
      ChoiceOption(value: 'apartment', label: 'Apartment'),
      ChoiceOption(value: 'house', label: 'House'),
    ],
    districts: [
      DistrictOption(id: 1, name: 'Chilanzar', city: 'Tashkent'),
      DistrictOption(id: 2, name: 'Yunusabad', city: 'Tashkent'),
    ],
    furnishings: [ChoiceOption(value: 'furnished', label: 'Furnished')],
    amenities: [
      AmenityOption(slug: 'wifi', name: 'Wi-Fi', icon: 'wifi'),
      AmenityOption(slug: 'ac', name: 'AC', icon: 'ac'),
    ],
    minimumStays: [1, 3, 6, 12],
    priceIncludes: [ChoiceOption(value: 'internet', label: 'Internet')],
    currencies: ['USD', 'UZS'],
    publicOffer: PublicOfferDetail(id: 1, version: '1.0', body: 'Terms'),
    userProfile: UserContactProfile(
      firstName: 'Ali',
      lastName: 'Valiyev',
      email: 'ali@example.com',
      phone: '+998901234567',
    ),
  );

  setUpAll(() {
    registerFallbackValue(FakePropertyUploadPayload());
  });

  setUp(() {
    mockGetConfig = MockGetPropertyUploadConfig();
    mockSubmit = MockSubmitPropertyUpload();
    bloc = ListPropertyWizardBloc(
      getConfig: mockGetConfig,
      submitProperty: mockSubmit,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state has step 0, initial status, and no prefilled specs', () {
    expect(bloc.state.status, WizardStatus.initial);
    expect(bloc.state.currentStep, 0);
    expect(bloc.state.propertyType, isNull);
    expect(bloc.state.districtId, isNull);
    expect(bloc.state.latitude, isNull);
    expect(bloc.state.longitude, isNull);
    expect(bloc.state.rooms, isNull);
    expect(bloc.state.floor, isNull);
    expect(bloc.state.areaSqm, isNull);
    expect(bloc.state.furnishing, isNull);
    expect(bloc.state.minimumStay, isNull);
    expect(bloc.state.showValidationErrors, isFalse);
  });

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'emits [loadingConfig, configReady] on started without defaults',
    build: () {
      when(
        () => mockGetConfig(),
      ).thenAnswer((_) async => const Right(sampleConfig));
      return bloc;
    },
    act: (b) => b.add(const ListPropertyWizardStarted()),
    expect: () => [
      const ListPropertyWizardState(status: WizardStatus.loadingConfig),
      const ListPropertyWizardState(
        status: WizardStatus.configReady,
        config: sampleConfig,
        firstName: 'Ali',
        lastName: 'Valiyev',
        email: 'ali@example.com',
        phone: '+998901234567',
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'updates details correctly',
    build: () => bloc,
    act: (b) {
      b.add(
        const ListPropertyDetailsUpdated(
          propertyType: 'apartment',
          rooms: 2,
          floor: 3,
          areaSqm: 65,
          furnishing: 'furnished',
        ),
      );
    },
    expect: () => [
      const ListPropertyWizardState(
        propertyType: 'apartment',
        rooms: 2,
        floor: 3,
        areaSqm: 65,
        furnishing: 'furnished',
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'updates location including coordinates, address, landmark, and district',
    build: () => bloc,
    act: (b) {
      b.add(
        const ListPropertyLocationUpdated(
          districtId: 1,
          address: 'Amir Temur 10',
          landmark: 'Near Grand Mir Hotel',
          latitude: 41.311081,
          longitude: 69.240562,
        ),
      );
    },
    expect: () => [
      const ListPropertyWizardState(
        districtId: 1,
        address: 'Amir Temur 10',
        landmark: 'Near Grand Mir Hotel',
        latitude: 41.311081,
        longitude: 69.240562,
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'toggles amenities correctly',
    build: () => bloc,
    act: (b) {
      b.add(const ListPropertyAmenityToggled('wifi'));
      b.add(const ListPropertyAmenityToggled('ac'));
      b.add(const ListPropertyAmenityToggled('wifi'));
    },
    expect: () => [
      const ListPropertyWizardState(amenities: {'wifi'}),
      const ListPropertyWizardState(amenities: {'wifi', 'ac'}),
      const ListPropertyWizardState(amenities: {'ac'}),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'updates photos, removes photo, and sets primary',
    build: () => bloc,
    act: (b) {
      b.add(const ListPropertyPhotosAdded(['/path/1.png', '/path/2.png']));
      b.add(const ListPropertyPhotosAdded(['/path/3.png']));
      b.add(const ListPropertyPhotoSetPrimary(1));
      b.add(const ListPropertyPhotoRemoved(2));
    },
    expect: () => [
      const ListPropertyWizardState(imagePaths: ['/path/1.png', '/path/2.png']),
      const ListPropertyWizardState(
        imagePaths: ['/path/1.png', '/path/2.png', '/path/3.png'],
      ),
      const ListPropertyWizardState(
        imagePaths: ['/path/2.png', '/path/1.png', '/path/3.png'],
      ),
      const ListPropertyWizardState(imagePaths: ['/path/2.png', '/path/1.png']),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'shows validation errors when advancing on empty details step',
    build: () => bloc,
    act: (b) {
      b.add(const ListPropertyStepAdvanceRequested());
    },
    expect: () => [
      const ListPropertyWizardState(
        showValidationErrors: true,
        errorMessage: 'Please fill in all required property details.',
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'advances from Step 0 to Step 1 when details valid',
    build: () => bloc,
    seed: () => const ListPropertyWizardState(
      propertyType: 'apartment',
      rooms: 2,
      floor: 3,
      areaSqm: 65,
      furnishing: 'furnished',
    ),
    act: (b) => b.add(const ListPropertyStepAdvanceRequested()),
    expect: () => [
      const ListPropertyWizardState(
        propertyType: 'apartment',
        rooms: 2,
        floor: 3,
        areaSqm: 65,
        furnishing: 'furnished',
        currentStep: 1,
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'shows validation errors when advancing from Step 1 without location '
    'coordinates',
    build: () => bloc,
    seed: () => const ListPropertyWizardState(
      currentStep: 1,
      propertyType: 'apartment',
      rooms: 2,
      floor: 3,
      areaSqm: 65,
      furnishing: 'furnished',
      districtId: 1,
      // latitude and longitude are null
    ),
    act: (b) => b.add(const ListPropertyStepAdvanceRequested()),
    expect: () => [
      const ListPropertyWizardState(
        currentStep: 1,
        propertyType: 'apartment',
        rooms: 2,
        floor: 3,
        areaSqm: 65,
        furnishing: 'furnished',
        districtId: 1,
        showValidationErrors: true,
        errorMessage: 'Please select district and map coordinates.',
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'advances from Step 1 to Step 2 when location valid',
    build: () => bloc,
    seed: () => const ListPropertyWizardState(
      currentStep: 1,
      propertyType: 'apartment',
      rooms: 2,
      floor: 3,
      areaSqm: 65,
      furnishing: 'furnished',
      districtId: 1,
      latitude: 41.311081,
      longitude: 69.240562,
    ),
    act: (b) => b.add(const ListPropertyStepAdvanceRequested()),
    expect: () => [
      const ListPropertyWizardState(
        currentStep: 2,
        propertyType: 'apartment',
        rooms: 2,
        floor: 3,
        areaSqm: 65,
        furnishing: 'furnished',
        districtId: 1,
        latitude: 41.311081,
        longitude: 69.240562,
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'submits successfully with specs and coordinates',
    build: () {
      when(() => mockSubmit(any())).thenAnswer(
        (_) async => const Right(
          PropertyUploadResult(
            id: 42,
            propertyId: 101,
            status: 'pending_review',
            message: 'Submitted',
          ),
        ),
      );
      return bloc;
    },
    seed: () => const ListPropertyWizardState(
      currentStep: 5,
      propertyType: 'apartment',
      districtId: 1,
      latitude: 41.311081,
      longitude: 69.240562,
      address: 'Amir Temur 10',
      rooms: 2,
      floor: 2,
      areaSqm: 70,
      furnishing: 'furnished',
      monthlyPrice: 600,
      firstName: 'Ali',
      phone: '+998901234567',
      imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
      acceptOffer: true,
    ),
    act: (b) => b.add(const ListPropertySubmitted()),
    expect: () => [
      const ListPropertyWizardState(
        currentStep: 5,
        status: WizardStatus.submitting,
        propertyType: 'apartment',
        districtId: 1,
        latitude: 41.311081,
        longitude: 69.240562,
        address: 'Amir Temur 10',
        rooms: 2,
        floor: 2,
        areaSqm: 70,
        furnishing: 'furnished',
        monthlyPrice: 600,
        firstName: 'Ali',
        phone: '+998901234567',
        imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
        acceptOffer: true,
      ),
      const ListPropertyWizardState(
        currentStep: 6,
        status: WizardStatus.submitted,
        createdListingId: 42,
        propertyType: 'apartment',
        districtId: 1,
        latitude: 41.311081,
        longitude: 69.240562,
        address: 'Amir Temur 10',
        rooms: 2,
        floor: 2,
        areaSqm: 70,
        furnishing: 'furnished',
        monthlyPrice: 600,
        firstName: 'Ali',
        phone: '+998901234567',
        imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
        acceptOffer: true,
      ),
    ],
  );
}
