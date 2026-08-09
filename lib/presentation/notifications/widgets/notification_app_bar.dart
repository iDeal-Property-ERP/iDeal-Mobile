import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_bloc.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_event.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const NotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationBloc, bool>(
      (bloc) => bloc.state.items.any((notification) => !notification.isRead),
    );
    return AppBar(
      title: Text(
        context.localization.notifications,
        style: AppTextStyles.h6SemiBold.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      centerTitle: true,
      leading: AppButton.icon(
        iconData: TablerIcons.arrow_left,
        iconOrTextColorOverride: context.currentTheme.iconNeutralDefault,
        size: AppButtonSize.extraLarge,
        onPressed: () => context.router.maybePop(),
      ),
      actions: [
        if (hasUnread)
          TextButton(
            onPressed: () => context.read<NotificationBloc>().add(
              const MarkAllNotificationsReadEvent(),
            ),
            child: Text(context.localization.notifications_mark_all_read),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(54);
}
