import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatEmptyView extends StatelessWidget {
  const ChatEmptyView({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TablerIcons.messages,
              size: 72,
              color: context.currentTheme.iconBrandHover,
            ),
            const SizedBox(height: 20),
            Text(
              title ?? context.localization.chats_empty_title,
              textAlign: TextAlign.center,
              style: AppTextStyles.p1SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? context.localization.chats_empty_subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
