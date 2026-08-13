import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/repositories/listing_detail_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListingDetailCached {
  const GetListingDetailCached(this._repository);

  final ListingDetailRepository _repository;

  Stream<Result<PublicCacheResult<ListingDetail>>> call({required int id}) =>
      _repository.getListingDetailCached(id: id);
}
