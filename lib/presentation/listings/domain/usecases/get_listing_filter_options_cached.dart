import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListingFilterOptionsCached {
  const GetListingFilterOptionsCached(this._repository);

  final ListingsRepository _repository;

  Stream<Result<PublicCacheResult<ListingFilterOptions>>> call() =>
      _repository.getFilterOptionsCached();
}
