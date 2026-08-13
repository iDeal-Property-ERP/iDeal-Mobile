import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListingsCached {
  const GetListingsCached(this._repository);

  final ListingsRepository _repository;

  Stream<Result<PublicCacheResult<ListingsPage>>> call({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  }) => _repository.getListingsCached(
    filters: filters,
    page: page,
    perPage: perPage,
  );
}
