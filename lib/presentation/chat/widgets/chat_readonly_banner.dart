import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatReadonlyBanner extends StatelessWidget {
  const ChatReadonlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: context.currentTheme.bgWarningLight50,
      child: Row(
        children: [
          Icon(
            TablerIcons.lock,
            size: 18,
            color: context.currentTheme.iconWarningDefault,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.localization.chat_read_only_blocked,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textWarningPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
