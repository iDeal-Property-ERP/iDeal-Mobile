import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/datasources/listing_detail_remote_data_source.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/repositories/listing_detail_repository_impl.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/repositories/listing_detail_repository.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail_cached.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

void registerListingDetailDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ListingDetailRepository>(
      () => ListingDetailRepositoryImpl(sl<ListingDetailRemoteDataSource>()),
    )
    ..registerLazySingleton<ListingDetailRemoteDataSource>(
      () => ListingDetailRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton(() => GetListingDetail(sl()))
    ..registerLazySingleton(() => GetListingDetailCached(sl()));
}
