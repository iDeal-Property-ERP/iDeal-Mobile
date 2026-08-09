import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_bloc.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';

class MockListingDetailBloc
    extends MockBloc<ListingDetailEvent, ListingDetailState>
    implements ListingDetailBloc {}

MockListingDetailBloc mockListingDetailBloc(ListingDetailState state) {
  final bloc = MockListingDetailBloc();
  when(() => bloc.state).thenReturn(state);
  return bloc;
}

ListingDetail buildListingDetail({
  List<ListingAmenity>? amenities,
  List<VerificationItem>? verificationChecklist,
  String? description =
      'A bright, carefully maintained home with a quiet outlook and everything needed for a comfortable long-term stay near the park and local services.',
  String? district = 'Yunusobod',
  double? price = 520,
  double score = 9.2,
}) {
  return ListingDetail(
    id: 12,
    propertyId: 34,
    title: 'Sunny apartment near the park',
    district: district,
    address: '12-kvartal, Tashkent',
    propertyType: 'apartment',
    rooms: 2,
    areaSqm: 68,
    floor: 4,
    totalFloors: 9,
    furnishing: 'furnished',
    price: price,
    currency: 'USD',
    tariff: 'comfort',
    isVerified: true,
    isFeatured: false,
    score: score,
    reviewCount: 48,
    mapLat: 41.36,
    mapLon: 69.28,
    description: description,
    depositAmount: 520,
    minimumStay: 3,
    priceIncludes: const ['Water', 'Wi-Fi'],
    responseTime: 'Usually within an hour',
    createdAt: DateTime(2026, 1, 1),
    photos: List<ListingPhoto>.generate(
      5,
      (index) => ListingPhoto(
        id: index + 1,
        imageUrl: 'https://example.com/photo-${index + 1}.jpg',
        caption: null,
        isPrimary: index == 0,
        sortOrder: index,
      ),
    ),
    amenities:
        amenities ??
        const [
          ListingAmenity(slug: 'wifi', name: 'Wi-Fi', icon: 'wifi'),
          ListingAmenity(slug: 'furnished', name: 'Furnished', icon: 'sofa'),
          ListingAmenity(slug: 'parking', name: 'Parking', icon: 'parking'),
          ListingAmenity(slug: 'elevator', name: 'Elevator', icon: 'elevator'),
        ],
    verificationIsVerified: true,
    verificationChecklist:
        verificationChecklist ??
        const [
          VerificationItem(key: 'identity', label: 'Owner identity checked'),
          VerificationItem(key: 'address', label: 'Address confirmed'),
        ],
  );
}
