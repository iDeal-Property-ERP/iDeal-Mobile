import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class SuccessStepView extends StatelessWidget {
  const SuccessStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.bgSuccessLight100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              TablerIcons.check,
              color: theme.textSuccessPrimary,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Listing is in Review',
            textAlign: TextAlign.center,
            style: AppTextStyles.h6SemiBold.copyWith(
              color: theme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our team will verify your property details and photos, and '
            'publish your listing shortly.',
            textAlign: TextAlign.center,
            style: AppTextStyles.p3Regular.copyWith(
              color: theme.textNeutralSecondary,
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Done',
            size: AppButtonSize.large,
            shouldSetFullWidth: true,
            onPressed: () => context.router.maybePop(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
