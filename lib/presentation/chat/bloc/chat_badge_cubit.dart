import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/get_chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/services/chat_realtime_service.dart';
import 'package:ideal_mobile/services/notification_service.dart';

class ChatBadgeCubit extends Cubit<int> with WidgetsBindingObserver {
  ChatBadgeCubit({
    GetChatSummary? getChatSummary,
    ChatRealtimeService? realtime,
  }) : _getChatSummary = getChatSummary ?? sl<GetChatSummary>(),
       _realtime =
           realtime ??
           (sl.isRegistered<ChatRealtimeService>()
               ? sl<ChatRealtimeService>()
               : null),
       super(0);

  final GetChatSummary _getChatSummary;
  final ChatRealtimeService? _realtime;
  StreamSubscription? _pushSubscription;
  StreamSubscription? _realtimeSubscription;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _pushSubscription = NotificationService.instance.onNotificationReceived
        .listen((event) {
          if (event.type == 'chat_message') unawaited(refresh());
        });
    _realtimeSubscription = _realtime?.events.listen(
      (_) => unawaited(refresh()),
    );
    unawaited(_realtime?.connect() ?? Future<void>.value());
    unawaited(refresh());
  }

  Future<void> refresh() async {
    final result = await _getChatSummary(const GetChatSummaryParams());
    if (isClosed) return;
    result.fold((_) {}, (summary) => emit(summary.totalUnread));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    final pushSubscription = _pushSubscription;
    if (pushSubscription != null) unawaited(pushSubscription.cancel());
    final realtimeSubscription = _realtimeSubscription;
    if (realtimeSubscription != null) unawaited(realtimeSubscription.cancel());
    return super.close();
  }
}
