import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatMessageTicks extends StatelessWidget {
  const ChatMessageTicks({super.key, required this.status});

  final ChatMessageStatus status;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    switch (status) {
      case ChatMessageStatus.sending:
        icon = TablerIcons.clock;
        color = context.currentTheme.iconNeutralDisabled;
      case ChatMessageStatus.sent:
        icon = TablerIcons.check;
        color = context.currentTheme.iconNeutralDisabled;
      case ChatMessageStatus.read:
        icon = TablerIcons.checks;
        color = context.currentTheme.iconBrandHover;
      case ChatMessageStatus.failed:
        icon = TablerIcons.alert_circle;
        color = context.currentTheme.iconErrorDefault;
    }
    return Icon(icon, size: 14, color: color);
  }
}
