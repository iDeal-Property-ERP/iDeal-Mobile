import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_banner_carousel.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

/// Use case for fetching active promotional home banners from the backend.
class GetHomeBanners with UseCaseWithoutParams<List<HomeBannerItem>> {
  const GetHomeBanners(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<List<HomeBannerItem>> call() {
    return _repository.getHomeBanners();
  }
}
