import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/domain/usecases/get_unread_count.dart';
import 'package:ideal_mobile/services/notification_service.dart';

class NotificationBadgeCubit extends Cubit<int> with WidgetsBindingObserver {
  NotificationBadgeCubit(this._getUnreadCount) : super(0);

  final GetUnreadCount _getUnreadCount;
  StreamSubscription? _pushSubscription;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _pushSubscription = NotificationService.instance.onNotificationReceived
        .listen((_) => unawaited(refresh()));
    unawaited(refresh());
  }

  Future<void> refresh() async {
    final result = await _getUnreadCount();
    result.fold((_) {}, emit);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _pushSubscription?.cancel();
    return super.close();
  }
}
