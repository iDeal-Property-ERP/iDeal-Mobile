import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/repositories/notification_settings_repository.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_notification_settings.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/update_notification_settings.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/push/notification_permission_status.dart';
import 'package:open_settings_plus/open_settings_plus.dart';

@RoutePage()
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final GetNotificationSettings _getSettings = sl<GetNotificationSettings>();
  final UpdateNotificationSettings _updateSettings =
      sl<UpdateNotificationSettings>();
  NotificationSettings? _settings;
  NotificationPermissionStatus _permission =
      NotificationPermissionStatus.notDetermined;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final permission = await NotificationService.instance.checkPermission();
    final result = await _getSettings();
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _permission = permission;
        _loading = false;
      }),
      (settings) => setState(() {
        _permission = permission;
        _settings = settings;
        _loading = false;
      }),
    );
  }

  Future<void> _update(
    NotificationSettingsUpdate update,
    NotificationSettings optimistic,
  ) async {
    final previous = _settings;
    if (_saving || previous == null) return;
    setState(() {
      _settings = optimistic;
      _saving = true;
    });
    final result = await _updateSettings(
      UpdateNotificationSettingsParams(update: update),
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _settings = previous;
        _saving = false;
      }),
      (persisted) async {
        setState(() {
          _settings = persisted;
          _saving = false;
        });
        switch (update.pushEnabled) {
          case false:
            await NotificationService.instance.unregisterDevice();
          case true:
            await NotificationService.instance.initialize();
          case null:
            break;
        }
      },
    );
  }

  Future<void> _openSystemSettings() async {
    switch (OpenSettingsPlus.shared) {
      case OpenSettingsPlusAndroid(:final notification):
        await notification();
      case OpenSettingsPlusIOS(:final appSettings):
        await appSettings();
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(title: Text(context.localization.notification_settings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : settings == null
          ? Center(child: Text(context.localization.opps_something_went_wrong))
          : ListView(
              children: [
                if (_permission != NotificationPermissionStatus.granted)
                  MaterialBanner(
                    content: Text(
                      context.localization.notifications_permission_denied,
                    ),
                    actions: [
                      TextButton(
                        onPressed: _openSystemSettings,
                        child: Text(
                          context.localization.notifications_open_settings,
                        ),
                      ),
                    ],
                  ),
                SwitchListTile(
                  title: Text(context.localization.notifications_push_enabled),
                  subtitle: Text(
                    context.localization.notifications_push_description,
                  ),
                  value: settings.pushEnabled,
                  onChanged: _saving
                      ? null
                      : (value) => _update(
                          NotificationSettingsUpdate(pushEnabled: value),
                          settings.copyWith(pushEnabled: value),
                        ),
                ),
                const Divider(),
                _categorySwitch(
                  context,
                  context.localization.notifications_payments,
                  settings.paymentsEnabled,
                  settings.pushEnabled,
                  (value) => _update(
                    NotificationSettingsUpdate(paymentsEnabled: value),
                    settings.copyWith(paymentsEnabled: value),
                  ),
                ),
                _categorySwitch(
                  context,
                  context.localization.notifications_bookings,
                  settings.bookingsEnabled,
                  settings.pushEnabled,
                  (value) => _update(
                    NotificationSettingsUpdate(bookingsEnabled: value),
                    settings.copyWith(bookingsEnabled: value),
                  ),
                ),
                _categorySwitch(
                  context,
                  context.localization.notifications_maintenance,
                  settings.maintenanceEnabled,
                  settings.pushEnabled,
                  (value) => _update(
                    NotificationSettingsUpdate(maintenanceEnabled: value),
                    settings.copyWith(maintenanceEnabled: value),
                  ),
                ),
                _categorySwitch(
                  context,
                  context.localization.notifications_leases,
                  settings.leasesEnabled,
                  settings.pushEnabled,
                  (value) => _update(
                    NotificationSettingsUpdate(leasesEnabled: value),
                    settings.copyWith(leasesEnabled: value),
                  ),
                ),
                _categorySwitch(
                  context,
                  context.localization.notifications_general,
                  settings.generalEnabled,
                  settings.pushEnabled,
                  (value) => _update(
                    NotificationSettingsUpdate(generalEnabled: value),
                    settings.copyWith(generalEnabled: value),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _categorySwitch(
    BuildContext context,
    String title,
    bool value,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: enabled && !_saving ? onChanged : null,
      ),
    );
  }
}
