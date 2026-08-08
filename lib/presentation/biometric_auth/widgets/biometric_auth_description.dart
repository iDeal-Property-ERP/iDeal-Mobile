import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class BiometricAuthDescription extends StatelessWidget {
  const BiometricAuthDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.localization.biometric_auth_description,
      style: AppTextStyles.p2Regular.copyWith(
        color: context.currentTheme.textNeutralPrimary,
      ),
    );
  }
}
