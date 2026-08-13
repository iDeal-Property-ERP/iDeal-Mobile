import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/data/datasources/booking_remote_data_source.dart';
import 'package:ideal_mobile/presentation/booking/data/repositories/booking_repository_impl.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';

void registerBookingDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(sl<Dio>()),
    )
    ..registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(sl<BookingRemoteDataSource>()),
    )
    ..registerLazySingleton<ActiveCheckoutStore>(ActiveCheckoutStore.new);
}
