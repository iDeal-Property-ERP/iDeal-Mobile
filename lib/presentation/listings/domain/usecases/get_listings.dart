import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListings with UseCaseWithParams<ListingsPage, GetListingsParams> {
  const GetListings(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<ListingsPage> call(GetListingsParams params) {
    return _repository.getListings(
      filters: params.filters,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

class GetListingsParams extends Equatable {
  const GetListingsParams({
    required this.filters,
    required this.page,
    this.perPage = 20,
  });

  final ListingFilters filters;
  final int page;
  final int perPage;

  @override
  List<Object> get props => [filters, page, perPage];
}
