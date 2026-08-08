import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class FeedbackDescription extends StatelessWidget {
  const FeedbackDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.localization.feedback_description,
      style: AppTextStyles.p2Medium.copyWith(
        color: context.currentTheme.textNeutralPrimary,
      ),
    );
  }
}
