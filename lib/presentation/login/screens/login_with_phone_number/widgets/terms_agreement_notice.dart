import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/settings/terms_and_conditions_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class TermsAgreementNotice extends StatelessWidget {
  const TermsAgreementNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.p4Regular.copyWith(
      color: context.currentTheme.textNeutralSecondary,
    );
    final linkStyle = baseStyle.copyWith(
      color: context.currentTheme.textBrandSecondary,
      decoration: TextDecoration.underline,
      decorationColor: context.currentTheme.textBrandSecondary,
    );

    return Text.rich(
      TextSpan(
        text: '${context.localization.login_terms_notice} ',
        style: baseStyle,
        children: [
          TextSpan(
            text: context.localization.terms_and_conditions,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TermsAndConditionsScreen(),
                ),
              ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
