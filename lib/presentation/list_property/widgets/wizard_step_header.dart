import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class WizardStepHeader extends StatelessWidget {
  const WizardStepHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final progress = ((currentStep + 1) / totalSteps).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: AppTextStyles.p4Medium.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTextStyles.p4Medium.copyWith(
                  color: context.currentTheme.textBrandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.currentTheme.bgSurfaceBase2,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.currentTheme.bgBrandDefault,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h6SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
