import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/contracts/data/datasources/contracts_remote_data_source.dart';
import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';
import 'package:ideal_mobile/presentation/contracts/domain/repositories/contracts_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  const ContractsRepositoryImpl(this._remoteDataSource);

  final ContractsRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<MobileContract>> getContracts() async {
    try {
      return Right(await _remoteDataSource.getContracts());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    } catch (error) {
      return Left(APIFailure(message: error.toString(), statusCode: 500));
    }
  }
}
