import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_bloc.dart';
import 'package:ideal_mobile/presentation/my_listings/data/datasources/my_listings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/my_listings/data/repositories/my_listings_repository_impl.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/repositories/my_listings_repository.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/usecases/get_my_listings.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/usecases/get_my_listings_stats.dart';

void registerMyListingsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<MyListingsRemoteDataSource>(
      () => MyListingsRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<MyListingsRepository>(
      () => MyListingsRepositoryImpl(sl<MyListingsRemoteDataSource>()),
    )
    ..registerLazySingleton<GetMyListingsStats>(
      () => GetMyListingsStats(sl<MyListingsRepository>()),
    )
    ..registerLazySingleton<GetMyListings>(
      () => GetMyListings(sl<MyListingsRepository>()),
    )
    ..registerFactory<MyListingsBloc>(
      () => MyListingsBloc(
        getMyListingsStats: sl<GetMyListingsStats>(),
        getMyListings: sl<GetMyListings>(),
      ),
    );
}
