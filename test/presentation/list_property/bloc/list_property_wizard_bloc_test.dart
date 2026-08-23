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

  test('initial state has step 0 and initial status', () {
    expect(bloc.state.status, WizardStatus.initial);
    expect(bloc.state.currentStep, 0);
  });

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'emits [loadingConfig, configReady] when started succeeds',
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
        districtId: 1,
        firstName: 'Ali',
        lastName: 'Valiyev',
        email: 'ali@example.com',
        phone: '+998901234567',
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
      b.add(
        const ListPropertyPhotoSetPrimary(1),
      ); // moves /path/2.png to index 0
      b.add(const ListPropertyPhotoRemoved(2)); // removes index 2
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
    'validates details step before advancing',
    build: () => bloc,
    act: (b) {
      b.add(const ListPropertyStepAdvanceRequested());
    },
    expect: () => [
      const ListPropertyWizardState(
        errorMessage: 'Please fill in all required property details.',
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'advances step when details valid',
    build: () => bloc,
    seed: () => const ListPropertyWizardState(
      name: 'Nice Apartment',
      districtId: 1,
      rooms: 2,
      floor: 3,
      areaSqm: 65,
    ),
    act: (b) => b.add(const ListPropertyStepAdvanceRequested()),
    expect: () => [
      const ListPropertyWizardState(
        name: 'Nice Apartment',
        districtId: 1,
        rooms: 2,
        floor: 3,
        areaSqm: 65,
        currentStep: 1,
      ),
    ],
  );

  blocTest<ListPropertyWizardBloc, ListPropertyWizardState>(
    'submits successfully when review valid',
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
      currentStep: 4,
      name: 'Modern Flat',
      districtId: 1,
      rooms: 2,
      floor: 2,
      areaSqm: 70,
      monthlyPrice: 600,
      depositAmount: 600,
      minimumStay: 3,
      firstName: 'Ali',
      phone: '+998901234567',
      imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
      acceptOffer: true,
    ),
    act: (b) => b.add(const ListPropertySubmitted()),
    expect: () => [
      const ListPropertyWizardState(
        currentStep: 4,
        status: WizardStatus.submitting,
        name: 'Modern Flat',
        districtId: 1,
        rooms: 2,
        floor: 2,
        areaSqm: 70,
        monthlyPrice: 600,
        depositAmount: 600,
        minimumStay: 3,
        firstName: 'Ali',
        phone: '+998901234567',
        imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
        acceptOffer: true,
      ),
      const ListPropertyWizardState(
        currentStep: 5,
        status: WizardStatus.submitted,
        createdListingId: 42,
        name: 'Modern Flat',
        districtId: 1,
        rooms: 2,
        floor: 2,
        areaSqm: 70,
        monthlyPrice: 600,
        depositAmount: 600,
        minimumStay: 3,
        firstName: 'Ali',
        phone: '+998901234567',
        imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
        acceptOffer: true,
      ),
    ],
  );
}
