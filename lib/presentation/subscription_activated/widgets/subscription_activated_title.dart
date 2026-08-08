import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class SubscriptionActivatedTitle extends StatelessWidget {
  const SubscriptionActivatedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.localization.subscription_activated_title,
      style: AppTextStyles.h4SemiBold.copyWith(
        color: context.currentTheme.textNeutralPrimary,
      ),
      textAlign: .center,
    );
  }
}
