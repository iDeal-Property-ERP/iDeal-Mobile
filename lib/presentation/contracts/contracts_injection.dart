import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_bloc.dart';
import 'package:ideal_mobile/presentation/contracts/data/datasources/contracts_remote_data_source.dart';
import 'package:ideal_mobile/presentation/contracts/data/repositories/contracts_repository_impl.dart';
import 'package:ideal_mobile/presentation/contracts/domain/repositories/contracts_repository.dart';
import 'package:ideal_mobile/presentation/contracts/domain/usecases/get_contracts.dart';

void registerContractsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ContractsRemoteDataSource>(
      () => ContractsRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<ContractsRepository>(
      () => ContractsRepositoryImpl(sl<ContractsRemoteDataSource>()),
    )
    ..registerLazySingleton<GetContracts>(
      () => GetContracts(sl<ContractsRepository>()),
    )
    ..registerFactory<ContractsBloc>(ContractsBloc.new);
}
