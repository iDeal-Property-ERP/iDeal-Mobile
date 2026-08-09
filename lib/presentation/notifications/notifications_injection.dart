import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notification_settings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:ideal_mobile/presentation/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notifications_repository.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notifications.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_unread_count.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/mark_notification_read.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/update_notification_settings.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

void registerNotificationsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(sl<NotificationsRemoteDataSource>()),
    )
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(sl<Dio>(), sl<CacheManager>()),
    )
    ..registerLazySingleton(() => GetNotifications(sl()))
    ..registerLazySingleton(() => GetUnreadCount(sl()))
    ..registerLazySingleton(() => MarkNotificationRead(sl()))
    ..registerLazySingleton(() => MarkAllNotificationsRead(sl()))
    ..registerLazySingleton<NotificationSettingsRepository>(
      () => NotificationSettingsRepositoryImpl(
        sl<NotificationSettingsRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<NotificationSettingsRemoteDataSource>(
      () => NotificationSettingsRemoteDataSourceImpl(
        sl<Dio>(),
        sl<CacheManager>(),
      ),
    )
    ..registerLazySingleton(() => GetNotificationSettings(sl()))
    ..registerLazySingleton(() => UpdateNotificationSettings(sl()))
    ..registerLazySingleton(() => NotificationBadgeCubit(sl<GetUnreadCount>()));
}
