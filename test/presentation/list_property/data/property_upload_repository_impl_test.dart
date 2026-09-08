import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/list_property/data/datasources/property_upload_remote_data_source.dart';
import 'package:ideal_mobile/presentation/list_property/data/models/property_upload_config_model.dart';
import 'package:ideal_mobile/presentation/list_property/data/repositories/property_upload_repository_impl.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:mocktail/mocktail.dart';

class MockPropertyUploadRemoteDataSource extends Mock
    implements PropertyUploadRemoteDataSource {}

class FakePropertyUploadPayload extends Fake implements PropertyUploadPayload {}

void main() {
  late MockPropertyUploadRemoteDataSource mockRemoteDataSource;
  late PropertyUploadRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakePropertyUploadPayload());
  });

  setUp(() {
    mockRemoteDataSource = MockPropertyUploadRemoteDataSource();
    repository = PropertyUploadRepositoryImpl(mockRemoteDataSource);
  });

  group('getConfig', () {
    const sampleConfigModel = PropertyUploadConfigModel(
      propertyTypes: [ChoiceOption(value: 'apartment', label: 'Apartment')],
      districts: [DistrictOption(id: 1, name: 'Chilanzar', city: 'Tashkent')],
      furnishings: [ChoiceOption(value: 'furnished', label: 'Furnished')],
      amenities: [AmenityOption(slug: 'wifi', name: 'Wi-Fi', icon: 'wifi')],
      minimumStays: [1, 3, 6, 12],
      priceIncludes: [ChoiceOption(value: 'internet', label: 'Internet')],
      currencies: ['USD'],
      publicOffer: PublicOfferDetail(id: 1, version: '1.0', body: 'Terms'),
    );

    test('returns Right(config) on success', () async {
      when(
        () => mockRemoteDataSource.getConfig(),
      ).thenAnswer((_) async => sampleConfigModel);

      final result = await repository.getConfig();

      expect(result, const Right(sampleConfigModel));
      verify(() => mockRemoteDataSource.getConfig()).called(1);
    });

    test('returns Left(APIFailure) on APIException', () async {
      when(
        () => mockRemoteDataSource.getConfig(),
      ).thenThrow(const APIException(message: 'Server error', statusCode: 500));

      final result = await repository.getConfig();

      expect(
        result,
        const Left(APIFailure(message: 'Server error', statusCode: 500)),
      );
      verify(() => mockRemoteDataSource.getConfig()).called(1);
    });
  });

  group('submitProperty', () {
    const payload = PropertyUploadPayload(
      name: 'Nice Apartment',
      propertyType: 'apartment',
      districtId: 1,
      latitude: 41.311081,
      longitude: 69.240562,
      rooms: 2,
      floor: 3,
      areaSqm: 65,
      furnishing: 'furnished',
      amenities: ['wifi'],
      monthlyPrice: 500,
      currency: 'USD',
      priceIncludes: ['internet'],
      acceptOffer: true,
      imagePaths: ['p1', 'p2', 'p3', 'p4', 'p5'],
    );

    const resultModel = PropertyUploadResultModel(
      id: 1,
      propertyId: 10,
      status: 'pending_review',
      message: 'Submitted',
    );

    test('returns Right(result) on success', () async {
      when(
        () => mockRemoteDataSource.submitProperty(any()),
      ).thenAnswer((_) async => resultModel);

      final result = await repository.submitProperty(payload);

      expect(result, const Right(resultModel));
      verify(() => mockRemoteDataSource.submitProperty(payload)).called(1);
    });

    test('returns Left(APIFailure) on APIException', () async {
      when(() => mockRemoteDataSource.submitProperty(any())).thenThrow(
        const APIException(
          message: 'At least 5 photos required',
          statusCode: 400,
        ),
      );

      final result = await repository.submitProperty(payload);

      expect(
        result,
        const Left(
          APIFailure(message: 'At least 5 photos required', statusCode: 400),
        ),
      );
    });
  });
}
