import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatDateSeparator extends StatelessWidget {
  const ChatDateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = date.isSameDay(now)
        ? context.localization.chat_today
        : date.isSameDay(now.subtract(const Duration(days: 1)))
        ? context.localization.chat_yesterday
        : date.format(pattern: 'MMM d');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.p4Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      ),
    );
  }
}
