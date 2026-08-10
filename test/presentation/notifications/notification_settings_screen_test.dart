import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/notification_settings/notification_settings_screen.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/update_notification_settings.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class MockGetNotificationSettings extends Mock
    implements GetNotificationSettings {}

class MockUpdateNotificationSettings extends Mock
    implements UpdateNotificationSettings {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetNotificationSettings getSettings;
  late MockUpdateNotificationSettings updateSettings;
  late MockAppLocalizations localizations;

  const settings = NotificationSettings(
    pushEnabled: true,
    paymentsEnabled: true,
    bookingsEnabled: true,
    maintenanceEnabled: true,
    leasesEnabled: true,
    messagesEnabled: true,
    generalEnabled: true,
  );

  setUpAll(() {
    registerFallbackValue(
      const UpdateNotificationSettingsParams(
        update: NotificationSettingsUpdate(messagesEnabled: false),
      ),
    );
  });

  setUp(() {
    getSettings = MockGetNotificationSettings();
    updateSettings = MockUpdateNotificationSettings();
    localizations = MockAppLocalizations();
    _registerDependencies(getSettings, updateSettings);
    _stubLocalizations(localizations);
  });

  tearDown(() async {
    await _unregister<GetNotificationSettings>();
    await _unregister<UpdateNotificationSettings>();
  });

  testWidgets('renders and toggles the messages switch', (tester) async {
    when(() => getSettings()).thenAnswer(
      (_) async => const Right<Failure, NotificationSettings>(settings),
    );
    when(() => updateSettings(any())).thenAnswer(
      (_) async => Right<Failure, NotificationSettings>(
        settings.copyWith(messagesEnabled: false),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [MockLocalizationsDelegate(localizations)],
        home: const NotificationSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final messagesSwitch = find.widgetWithText(SwitchListTile, 'Messages');
    expect(messagesSwitch, findsOneWidget);

    await tester.tap(messagesSwitch);
    await tester.pumpAndSettle();

    verify(
      () => updateSettings(
        const UpdateNotificationSettingsParams(
          update: NotificationSettingsUpdate(messagesEnabled: false),
        ),
      ),
    ).called(1);
  });
}

void _registerDependencies(
  MockGetNotificationSettings getSettings,
  MockUpdateNotificationSettings updateSettings,
) {
  sl.allowReassignment = true;
  sl.registerSingleton<GetNotificationSettings>(getSettings);
  sl.registerSingleton<UpdateNotificationSettings>(updateSettings);
}

Future<void> _unregister<T extends Object>() async {
  final locator = GetIt.instance;
  if (locator.isRegistered<T>()) await locator.unregister<T>();
}

void _stubLocalizations(MockAppLocalizations localizations) {
  when(
    () => localizations.notification_settings,
  ).thenReturn('Notification Settings');
  when(
    () => localizations.notifications_permission_denied,
  ).thenReturn('Notifications are disabled');
  when(
    () => localizations.notifications_open_settings,
  ).thenReturn('Open settings');
  when(
    () => localizations.notifications_push_enabled,
  ).thenReturn('Push notifications');
  when(
    () => localizations.notifications_push_description,
  ).thenReturn('Receive notifications');
  when(() => localizations.notifications_messages).thenReturn('Messages');
  when(() => localizations.notifications_payments).thenReturn('Payments');
  when(() => localizations.notifications_bookings).thenReturn('Bookings');
  when(() => localizations.notifications_maintenance).thenReturn('Maintenance');
  when(() => localizations.notifications_leases).thenReturn('Leases');
  when(() => localizations.notifications_general).thenReturn('General');
  when(
    () => localizations.opps_something_went_wrong,
  ).thenReturn('Something went wrong');
}
