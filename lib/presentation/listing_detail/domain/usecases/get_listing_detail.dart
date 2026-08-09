import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/repositories/listing_detail_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetListingDetail
    with UseCaseWithParams<ListingDetail, GetListingDetailParams> {
  const GetListingDetail(this._repository);

  final ListingDetailRepository _repository;

  @override
  ResultFuture<ListingDetail> call(GetListingDetailParams params) {
    return _repository.getListingDetail(id: params.id);
  }
}

class GetListingDetailParams extends Equatable {
  const GetListingDetailParams({required this.id});

  final int id;

  @override
  List<Object> get props => [id];
}
