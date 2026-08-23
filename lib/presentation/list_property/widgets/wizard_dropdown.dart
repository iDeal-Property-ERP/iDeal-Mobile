import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class WizardDropdownOption<T> {
  const WizardDropdownOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class WizardDropdown<T> extends StatelessWidget {
  const WizardDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.options,
    required this.onChanged,
    this.title,
    this.hasError = false,
  });

  final T? value;
  final String hintText;
  final List<WizardDropdownOption<T>> options;
  final ValueChanged<T> onChanged;
  final String? title;
  final bool hasError;

  Future<void> _openPicker(BuildContext context) async {
    await HapticFeedbackUtil.light();
    if (!context.mounted) return;

    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => _WizardPickerSheet<T>(
        title: title ?? hintText,
        selectedValue: value,
        options: options,
      ),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final selectedOption = options.cast<WizardDropdownOption<T>?>().firstWhere(
      (opt) => opt?.value == value,
      orElse: () => null,
    );

    final borderColor = hasError
        ? theme.strokeErrorDefault
        : theme.strokeNeutralLight200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: hasError ? 1.5 : 1.0),
          ),
          child: Row(
            children: [
              if (selectedOption?.icon != null) ...[
                Icon(
                  selectedOption!.icon,
                  size: 20,
                  color: theme.textNeutralPrimary,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  selectedOption?.label ?? hintText,
                  style: selectedOption != null
                      ? AppTextStyles.p3Medium.copyWith(
                          color: theme.textNeutralPrimary,
                        )
                      : AppTextStyles.p3Regular.copyWith(
                          color: hasError
                              ? theme.textErrorPrimary
                              : theme.textNeutralSecondary,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                TablerIcons.chevron_down,
                size: 18,
                color: hasError
                    ? theme.textErrorPrimary
                    : theme.textNeutralSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WizardPickerSheet<T> extends StatelessWidget {
  const _WizardPickerSheet({
    required this.title,
    required this.selectedValue,
    required this.options,
  });

  final String title;
  final T? selectedValue;
  final List<WizardDropdownOption<T>> options;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                style: AppTextStyles.h6Bold.copyWith(
                  color: theme.textNeutralPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.value == selectedValue;

                  return Material(
                    color: isSelected
                        ? theme.bgBrandLight100
                        : theme.bgSurfaceBase2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await HapticFeedbackUtil.light();
                        if (context.mounted) {
                          Navigator.of(context).pop(option.value);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.strokeBrandDefault
                                : theme.strokeNeutralLight200,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (option.icon != null) ...[
                              Icon(
                                option.icon,
                                size: 20,
                                color: isSelected
                                    ? theme.textBrandPrimary
                                    : theme.textNeutralPrimary,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: AppTextStyles.p2Medium.copyWith(
                                      color: isSelected
                                          ? theme.textBrandPrimary
                                          : theme.textNeutralPrimary,
                                    ),
                                  ),
                                  if (option.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      option.subtitle!,
                                      style: AppTextStyles.p4Regular.copyWith(
                                        color: theme.textNeutralSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(
                                TablerIcons.check,
                                color: theme.textBrandPrimary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
