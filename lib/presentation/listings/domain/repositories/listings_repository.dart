import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingsRepository {
  ResultFuture<ListingsPage> getListings({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  });

  ResultFuture<ListingFilterOptions> getFilterOptions();
}
