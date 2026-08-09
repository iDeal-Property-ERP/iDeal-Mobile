import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/notifications/data/datasources/notification_settings_remote_data_source.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notification_settings_model.dart';
import 'package:ideal_mobile/presentation/notifications/data/repositories/notification_settings_repository_impl.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationSettingsRemoteDataSource extends Mock
    implements NotificationSettingsRemoteDataSource {}

void main() {
  late MockNotificationSettingsRemoteDataSource dataSource;
  late NotificationSettingsRepositoryImpl repository;

  const settings = NotificationSettingsModel(
    pushEnabled: true,
    paymentsEnabled: true,
    bookingsEnabled: false,
    maintenanceEnabled: true,
    leasesEnabled: false,
    generalEnabled: true,
  );
  const update = NotificationSettingsUpdate(pushEnabled: false);

  setUpAll(() {
    registerFallbackValue(update);
  });

  setUp(() {
    dataSource = MockNotificationSettingsRemoteDataSource();
    repository = NotificationSettingsRepositoryImpl(dataSource);
  });

  test('returns Right for settings success', () async {
    when(() => dataSource.getSettings()).thenAnswer((_) async => settings);

    final result = await repository.getSettings();

    expect(result, const Right<Failure, NotificationSettings>(settings));
  });

  test('returns Left APIFailure for settings failure', () async {
    when(
      () => dataSource.getSettings(),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));

    final result = await repository.getSettings();

    expect(
      result,
      const Left<Failure, NotificationSettings>(
        APIFailure(message: 'Unavailable', statusCode: 503),
      ),
    );
  });

  test('maps settings updates and their failures', () async {
    when(
      () => dataSource.updateSettings(any()),
    ).thenAnswer((_) async => settings);

    expect(
      await repository.updateSettings(update),
      const Right<Failure, NotificationSettings>(settings),
    );

    when(
      () => dataSource.updateSettings(any()),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));
    expect(
      await repository.updateSettings(update),
      const Left<Failure, NotificationSettings>(
        APIFailure(message: 'Unavailable', statusCode: 503),
      ),
    );
  });
}
