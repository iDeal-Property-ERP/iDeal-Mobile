import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/list_property/data/datasources/property_upload_remote_data_source.dart';
import 'package:ideal_mobile/presentation/list_property/data/repositories/property_upload_repository_impl.dart';
import 'package:ideal_mobile/presentation/list_property/domain/repositories/property_upload_repository.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/get_property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/usecases/submit_property_upload.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

void registerPropertyUploadDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<PropertyUploadRemoteDataSource>(
      () => PropertyUploadRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton<PropertyUploadRepository>(
      () => PropertyUploadRepositoryImpl(sl<PropertyUploadRemoteDataSource>()),
    )
    ..registerLazySingleton<GetPropertyUploadConfig>(
      () => GetPropertyUploadConfig(sl<PropertyUploadRepository>()),
    )
    ..registerLazySingleton<SubmitPropertyUpload>(
      () => SubmitPropertyUpload(sl<PropertyUploadRepository>()),
    );
}
