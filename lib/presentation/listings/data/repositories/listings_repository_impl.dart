import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/listings/data/datasources/listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  const ListingsRepositoryImpl(this._remoteDataSource);

  final ListingsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<ListingsPage> getListings({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  }) async {
    try {
      return Right(
        await _remoteDataSource.getListings(
          filters: filters,
          page: page,
          perPage: perPage,
        ),
      );
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultFuture<ListingFilterOptions> getFilterOptions() async {
    try {
      return Right(await _remoteDataSource.getFilterOptions());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  Stream<Result<PublicCacheResult<ListingsPage>>> getListingsCached({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  }) async* {
    try {
      await for (final event in _remoteDataSource.getListingsCached(
        filters: filters,
        page: page,
        perPage: perPage,
      )) {
        yield Right(event);
      }
    } on APIException catch (error) {
      yield Left(APIFailure.fromException(error));
    }
  }

  @override
  Stream<Result<PublicCacheResult<ListingFilterOptions>>>
  getFilterOptionsCached() async* {
    try {
      await for (final event in _remoteDataSource.getFilterOptionsCached()) {
        yield Right(event);
      }
    } on APIException catch (error) {
      yield Left(APIFailure.fromException(error));
    }
  }
}
