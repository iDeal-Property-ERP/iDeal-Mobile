import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_state.dart';
import 'package:ideal_mobile/presentation/notifications/widgets/empty_notifications_view.dart';
import 'package:ideal_mobile/presentation/notifications/widgets/notification_list.dart';
import 'package:ideal_mobile/presentation/notifications/widgets/notification_loading_shimmer_list.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({this.bloc, super.key});

  final NotificationBloc? bloc;

  @override
  Widget build(BuildContext context) {
    final suppliedBloc = bloc;
    if (suppliedBloc != null) {
      return BlocProvider.value(
        value: suppliedBloc,
        child: const _NotificationsScaffold(),
      );
    }
    return BlocProvider(
      create: (_) => NotificationBloc()..add(const LoadNotificationsEvent()),
      child: const _NotificationsScaffold(),
    );
  }
}

class _NotificationsScaffold extends StatelessWidget {
  const _NotificationsScaffold();

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationBloc, bool>(
      (bloc) => bloc.state.items.any((notification) => !notification.isRead),
    );
    return Scaffold(
      appBar: AppTopBar.page(
        title: context.localization.notifications,
        actions: [
          if (hasUnread)
            AppTopBarAction(
              icon: TablerIcons.checks,
              tooltip: context.localization.notifications_mark_all_read,
              onPressed: () => context.read<NotificationBloc>().add(
                const MarkAllNotificationsReadEvent(),
              ),
            ),
        ],
      ),
      body: const NotificationScreenBody(),
    );
  }
}

class NotificationScreenBody extends StatelessWidget {
  const NotificationScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null) context.showSnackBar(message);
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const NotificationLoadigShimmerList();
          }
          if (state.items.isEmpty) return const EmptyNotificationsView();
          return const NotificationList();
        },
      ),
    );
  }
}
