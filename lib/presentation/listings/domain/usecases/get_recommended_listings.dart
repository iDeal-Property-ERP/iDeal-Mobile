import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetRecommendedListings with UseCaseWithoutParams<List<ListingCard>> {
  const GetRecommendedListings(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<List<ListingCard>> call() {
    return _repository.getRecommendedListings();
  }
}
