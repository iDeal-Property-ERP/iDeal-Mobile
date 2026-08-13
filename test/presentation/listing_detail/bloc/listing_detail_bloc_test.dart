import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetListingDetail extends Mock implements GetListingDetail {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

ListingDetail _listingDetail() {
  return ListingDetail(
    id: 12,
    propertyId: 34,
    title: 'Yunusobod 12-kvartal',
    district: 'Yunusobod District',
    address: '12-kvartal',
    propertyType: 'apartment',
    rooms: 2,
    areaSqm: 65,
    floor: 4,
    totalFloors: 9,
    furnishing: 'furnished',
    price: 520.0,
    currency: 'USD',
    tariff: 'comfort',
    isVerified: true,
    isFeatured: false,
    score: 9.2,
    reviewCount: 48,
    mapLat: 41.36,
    mapLon: 69.28,
    description: 'A bright apartment.',
    depositAmount: 520.0,
    minimumStay: 6,
    priceIncludes: const ['wifi'],
    responseTime: 'Usually responds within 1 hour',
    createdAt: DateTime.utc(2026, 7, 1, 10),
    photos: const [],
    amenities: const [],
    verificationIsVerified: true,
    verificationChecklist: const [],
    canMessage: false,
    contactPhone: null,
    booking: const BookingEligibility.ineligible(),
  );
}

ListingCard _card({int id = 12}) => ListingCard(
  id: id,
  propertyId: 34,
  title: 'Feed preview',
  district: null,
  address: 'Address',
  propertyType: 'apartment',
  rooms: 2,
  areaSqm: 65,
  floor: 2,
  totalFloors: 9,
  furnishing: 'furnished',
  price: 500,
  currency: 'USD',
  tariff: 'comfort',
  isVerified: false,
  isFeatured: false,
  score: 0,
  reviewCount: 0,
  coverImageUrl: 'https://example.test/cover.jpg',
  mapLat: null,
  mapLon: null,
);

void main() {
  late MockGetListingDetail getListingDetail;
  late MockPerformanceMonitoringService performanceService;
  late ListingDetailBloc bloc;

  setUpAll(() {
    registerFallbackValue(const GetListingDetailParams(id: 12));
  });

  setUp(() {
    getListingDetail = MockGetListingDetail();
    performanceService = MockPerformanceMonitoringService();
    bloc = ListingDetailBloc(
      getListingDetail: getListingDetail,
      performanceService: performanceService,
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  blocTest<ListingDetailBloc, ListingDetailState>(
    'emits loading then loaded on a successful result',
    build: () {
      final detail = _listingDetail();
      when(
        () => getListingDetail(any()),
      ).thenAnswer((_) async => Right(detail));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadListingDetailEvent(12)),
    expect: () => [
      isA<ListingDetailLoadingState>().having(
        (state) => state.isLoading,
        'is loading',
        isTrue,
      ),
      isA<ListingDetailLoadedState>()
          .having((state) => state.detail?.id, 'listing id', 12)
          .having((state) => state.isLoading, 'is loading', isFalse),
    ],
  );

  blocTest<ListingDetailBloc, ListingDetailState>(
    'emits loading then error on a failed result',
    build: () {
      when(() => getListingDetail(any())).thenAnswer(
        (_) async =>
            const Left(APIFailure(message: 'Server error', statusCode: 500)),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadListingDetailEvent(12)),
    expect: () => [
      isA<ListingDetailLoadingState>(),
      isA<ListingDetailErrorState>()
          .having(
            (state) => state.errorMessage,
            'error',
            '500 Error: Server error',
          )
          .having((state) => state.isLoading, 'is loading', isFalse),
    ],
  );

  blocTest<ListingDetailBloc, ListingDetailState>(
    'retains a matching feed seed and gates it when refresh fails',
    build: () {
      when(() => getListingDetail(any())).thenAnswer(
        (_) async => const Left(APIFailure(message: 'offline', statusCode: 0)),
      );
      return bloc;
    },
    act: (bloc) =>
        bloc.add(LoadListingDetailEvent(12, initialListing: _card())),
    expect: () => [
      isA<ListingDetailState>()
          .having((state) => state.preview?.id, 'preview id', 12)
          .having((state) => state.isFreshDetail, 'fresh', isFalse),
      isA<ListingDetailLoadingState>().having(
        (state) => state.preview?.id,
        'preview retained while loading',
        12,
      ),
      isA<ListingDetailErrorState>()
          .having((state) => state.preview?.id, 'preview retained on error', 12)
          .having((state) => state.isFreshDetail, 'writes gated', isFalse),
    ],
  );

  blocTest<ListingDetailBloc, ListingDetailState>(
    'ignores a feed seed whose ID does not match the required route ID',
    build: () {
      when(
        () => getListingDetail(any()),
      ).thenAnswer((_) async => Right(_listingDetail()));
      return bloc;
    },
    act: (bloc) =>
        bloc.add(LoadListingDetailEvent(12, initialListing: _card(id: 99))),
    verify: (_) => verify(() => getListingDetail(any())).called(1),
    expect: () => [
      isA<ListingDetailLoadingState>().having(
        (state) => state.preview,
        'mismatched preview ignored',
        isNull,
      ),
      isA<ListingDetailLoadedState>(),
    ],
  );
}
