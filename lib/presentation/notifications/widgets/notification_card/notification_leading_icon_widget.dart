import 'package:flutter/material.dart';
import 'package:ideal_mobile/presentation/notifications/model/notification_model.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class NotificationLeadingIconWidget extends StatelessWidget {
  const NotificationLeadingIconWidget({
    super.key,
    required this.notificationModel,
  });

  final NotificationModel notificationModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16.0,
          backgroundColor: notificationModel.notificationType.getBgColor,
          foregroundColor: context.currentTheme.bgShadesWhite,
          child: notificationModel.notificationType.getIcon,
        ),
        if (!notificationModel.isSeen) ...[
          const SizedBox(height: 8.0),
          Container(
            height: 8.0,
            width: 8.0,
            decoration: BoxDecoration(
              color: context.currentTheme.bgBrandHover,
              shape: .circle,
            ),
          ),
        ],
      ],
    );
  }
}
