import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingDetailRepository {
  ResultFuture<ListingDetail> getListingDetail({required int id});

  Stream<Result<PublicCacheResult<ListingDetail>>> getListingDetailCached({
    required int id,
  });
}
