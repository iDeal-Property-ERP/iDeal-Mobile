import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/presentation/notifications/widgets/notification_card.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_loadMoreWhenNeeded);
  }

  void _loadMoreWhenNeeded() {
    if (_controller.position.extentAfter > 240) return;
    context.read<NotificationBloc>().add(const LoadMoreNotificationsEvent());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_loadMoreWhenNeeded)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationBloc>().state;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(const RefreshNotificationsEvent());
        await context.read<NotificationBloc>().stream.firstWhere(
          (state) => !state.isLoading,
        );
      },
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) =>
            Divider(color: context.currentTheme.strokeNeutralLight200),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final notification = state.items[index];
          return NotificationCard(
            notification: notification,
            onOpen: () {
              context.read<NotificationBloc>().add(
                MarkNotificationReadEvent(notification.id),
              );
              sl<NotificationBadgeCubit>().refresh();
            },
          );
        },
      ),
    );
  }
}
