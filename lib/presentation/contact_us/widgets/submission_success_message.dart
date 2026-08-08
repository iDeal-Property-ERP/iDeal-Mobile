import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class SubmissionSuccessMessage extends StatelessWidget {
  const SubmissionSuccessMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.localization.alright,
          style: AppTextStyles.h4SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          context.localization.response_received,
          style: AppTextStyles.p2Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
          textAlign: .center,
        ),
      ],
    );
  }
}
