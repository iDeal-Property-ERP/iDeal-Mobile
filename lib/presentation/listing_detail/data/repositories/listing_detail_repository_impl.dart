import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/datasources/listing_detail_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/repositories/listing_detail_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingDetailRepositoryImpl implements ListingDetailRepository {
  const ListingDetailRepositoryImpl(this._remote);

  final ListingDetailRemoteDataSource _remote;

  @override
  ResultFuture<ListingDetail> getListingDetail({required int id}) async {
    try {
      return Right(await _remote.getListingDetail(id: id));
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
