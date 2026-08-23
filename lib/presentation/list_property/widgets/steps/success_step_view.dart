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
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color:
                  (context.isDark
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF16A34A))
                      .withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3322C55E),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                TablerIcons.check,
                color: Colors.white,
                size: 34,
              ),
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
