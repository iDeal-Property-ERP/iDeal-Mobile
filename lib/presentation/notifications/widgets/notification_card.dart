import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/notification_kind.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:timeago/timeago.dart' as time_ago;

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    required this.notification,
    required this.onOpen,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onOpen;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    final hasBody = notification.body != null && notification.body!.isNotEmpty;
    final visuals = _visualsFor(notification);
    return InkWell(
      onTap: widget.onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: visuals.$2,
                  foregroundColor: Colors.white,
                  child: Icon(visuals.$1, size: 20),
                ),
                if (!notification.isRead)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      height: 9,
                      width: 9,
                      decoration: BoxDecoration(
                        color: context.currentTheme.bgBrandHover,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.p2Medium.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  if (hasBody) ...[
                    const SizedBox(height: 4),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        notification.body!,
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: AppTextStyles.p3Regular.copyWith(
                          color: context.currentTheme.textNeutralSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    time_ago.format(
                      notification.createdAt,
                      locale: context.localization.localeName,
                    ),
                    style: AppTextStyles.p4Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasBody)
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

(IconData, Color) _visualsFor(AppNotification notification) {
  switch (notification.category) {
    case NotificationCategory.payments:
      return (TablerIcons.credit_card, Colors.green.shade600);
    case NotificationCategory.bookings:
      return (TablerIcons.calendar_event, Colors.indigo.shade500);
    case NotificationCategory.maintenance:
      return (TablerIcons.tool, Colors.orange.shade700);
    case NotificationCategory.leases:
      return (TablerIcons.file_description, Colors.blue.shade600);
    case NotificationCategory.general:
      return (TablerIcons.bell, Colors.grey.shade700);
  }
}
