import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class LoginSignUpButtonDivider extends StatelessWidget {
  const LoginSignUpButtonDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LoginWithPhoneNumberScreen.kHorizontalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: 1,
              color: context.currentTheme.strokeNeutralLight100,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            context.localization.or,
            style: AppTextStyles.p2Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 1,
              color: context.currentTheme.strokeNeutralLight100,
            ),
          ),
        ],
      ),
    );
  }
}
