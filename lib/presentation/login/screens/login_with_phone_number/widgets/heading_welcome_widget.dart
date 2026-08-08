import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class HeadingWelcomeWidget extends StatelessWidget {
  const HeadingWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(Assets.icons.loginLogo.path, width: 88, height: 88),
            const SizedBox(width: 12),
            Text(
              'iDeal',
              style: AppTextStyles.h1.copyWith(
                color: context.currentTheme.textNeutralPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          context.localization.log_in,
          style: AppTextStyles.h2Bold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
          textAlign: .center,
        ),
      ],
    );
  }
}
