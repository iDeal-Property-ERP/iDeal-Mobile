import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:ideal_mobile/presentation/chat/chat_conversation_screen.dart';
import 'package:ideal_mobile/services/push/active_chat_conversation_tracker.dart';

/// Keeps foreground chat alerts scoped to the route the user can currently see.
class PushRouteObserver extends AutoRouterObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _sync(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _sync(previousRoute);
  }

  void _sync(Route<dynamic>? route) {
    final settings = route?.settings;
    if (settings is! AutoRoutePage<Object?>) {
      ActiveChatConversationTracker.instance.setConversationId(null);
      return;
    }

    final child = settings.child;
    ActiveChatConversationTracker.instance.setConversationId(
      child is ChatConversationScreen ? child.conversationId : null,
    );
  }
}
