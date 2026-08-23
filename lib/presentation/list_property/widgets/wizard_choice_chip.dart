import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class WizardChoiceChip extends StatelessWidget {
  const WizardChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hasError = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final backgroundColor = selected
        ? theme.bgBrandLight100
        : theme.bgSurfaceBase2;
    final borderColor = hasError
        ? theme.strokeErrorDefault
        : (selected ? theme.strokeBrandDefault : theme.strokeNeutralLight200);
    final textColor = selected
        ? theme.textBrandPrimary
        : theme.textNeutralPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: borderColor,
              width: (selected || hasError) ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.p3Medium.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
