import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListingFilterOptions with UseCaseWithoutParams<ListingFilterOptions> {
  const GetListingFilterOptions(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<ListingFilterOptions> call() {
    return _repository.getFilterOptions();
  }
}
