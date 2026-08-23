import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/my_listings/data/datasources/my_listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_data.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/repositories/my_listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class MyListingsRepositoryImpl implements MyListingsRepository {
  const MyListingsRepositoryImpl(this._remoteDataSource);

  final MyListingsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<MyListingsStats> getMyListingsStats() async {
    try {
      final stats = await _remoteDataSource.getMyListingsStats();
      return Right(stats);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    } catch (error) {
      return Left(APIFailure(message: error.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<MyListingsData> getMyListings({String status = 'all'}) async {
    try {
      final data = await _remoteDataSource.getMyListings(status: status);
      return Right(data);
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    } catch (error) {
      return Left(APIFailure(message: error.toString(), statusCode: 500));
    }
  }
}
