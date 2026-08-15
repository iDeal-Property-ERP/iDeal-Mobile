import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_state.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/presentation/notifications/notifications_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class MockNotificationBloc
    extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

void main() {
  testWidgets('mark-all-read action dispatches its bloc event', (tester) async {
    final bloc = MockNotificationBloc();
    when(
      () => bloc.state,
    ).thenReturn(NotificationState(items: [_unreadNotification]));

    await tester.runWidgetTest(child: NotificationsScreen(bloc: bloc));

    await tester.tap(find.byTooltip('Mark all read'));
    await tester.pump();

    verify(() => bloc.add(const MarkAllNotificationsReadEvent())).called(1);
  });
}

final _unreadNotification = AppNotification(
  id: 1,
  kind: NotificationKind.general,
  category: NotificationCategory.general,
  title: 'Notice',
  body: null,
  relatedObjectType: null,
  relatedObjectId: null,
  isRead: false,
  readAt: null,
  createdAt: DateTime(2026),
);
