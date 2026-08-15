import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/listing_map/data/datasources/listing_map_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/entities/listing_map_result.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/repositories/listing_map_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingMapRepositoryImpl implements ListingMapRepository {
  const ListingMapRepositoryImpl(this._remoteDataSource);

  final ListingMapRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<ListingMapResult> getListings({
    required PropertyMapBounds bounds,
    required ListingFilters filters,
    CancelToken? cancelToken,
  }) async {
    try {
      return Right(
        await _remoteDataSource.getListings(
          bounds: bounds,
          filters: filters,
          cancelToken: cancelToken,
        ),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      return Left(
        APIFailure(
          message: error.message ?? 'Map listings request failed.',
          statusCode: error.response?.statusCode ?? 505,
        ),
      );
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
