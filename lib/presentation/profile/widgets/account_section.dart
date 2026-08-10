import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/widgets/personal_details.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          context.localization.account,
          style: AppTextStyles.h6SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.currentTheme.strokeNeutralLight200,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(children: const [PersonalDetails()]),
        ),
      ],
    );
  }
}
