import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/favorites/domain/repositories/favorites_repository.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listings_page.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._remoteDataSource);

  final FavoritesRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<ListingsPage> getFavorites({
    required int page,
    int perPage = 20,
    ListingFilters? filters,
    SelectedSort? sort,
  }) async {
    try {
      return Right(
        await _remoteDataSource.getFavorites(
          page: page,
          perPage: perPage,
          filters: filters,
          sort: sort,
        ),
      );
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }

  @override
  ResultVoid setFavorite({
    required int listingId,
    required bool isFavorite,
  }) async {
    try {
      await _remoteDataSource.setFavorite(
        listingId: listingId,
        isFavorite: isFavorite,
      );
      return const Right(null);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
