import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/chat/model/chat_message_model.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class TimeAgo extends StatelessWidget {
  const TimeAgo({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final time = message.date.to12HourFormat();
    final showStatusSuffix =
        message.isSentByMe && message.status.trim().isNotEmpty;
    return Column(
      children: [
        const SizedBox(height: 5),
        Text(
          showStatusSuffix ? '$time • ${message.status}' : time,
          style: AppTextStyles.c2Medium.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ],
    );
  }
}
