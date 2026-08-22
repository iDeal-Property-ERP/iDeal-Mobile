import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingsFilterDropdownOption<T> {
  const ListingsFilterDropdownOption({
    required this.value,
    required this.label,
  });

  final T? value;
  final String label;
}

class ListingsFilterPillChip extends StatelessWidget {
  const ListingsFilterPillChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.leadingIcon,
    this.badge,
    this.trailingIcon,
    this.compact = false,
    this.borderless = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final IconData? leadingIcon;
  final int? badge;
  final IconData? trailingIcon;
  final bool compact;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = borderless
        ? context.currentTheme.textNeutralSecondary
        : (selected
              ? context.currentTheme.textBrandPrimary
              : context.currentTheme.textNeutralPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: BoxConstraints(
            minHeight: compact ? 36 : (borderless ? 32 : 44),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: borderless ? 6 : (compact ? 11 : 14),
            vertical: borderless ? 4 : (compact ? 6 : 8),
          ),
          decoration: borderless
              ? null
              : BoxDecoration(
                  color: selected
                      ? context.currentTheme.bgBrandLight100
                      : context.currentTheme.bgSurfaceBase2,
                  border: Border.all(
                    color: selected
                        ? context.currentTheme.iconBrandPrimary
                        : context.currentTheme.bgNeutralLight100,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: foregroundColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style:
                    (borderless
                            ? AppTextStyles.p3Medium
                            : AppTextStyles.p3Medium)
                        .copyWith(color: foregroundColor),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.currentTheme.iconBrandPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: AppTextStyles.c2SemiBold.copyWith(
                      color: context.currentTheme.textNeutralWhite,
                    ),
                  ),
                ),
              ],
              if (trailingIcon != null) ...[
                const SizedBox(width: 4),
                Icon(trailingIcon, size: 16, color: foregroundColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ListingsFilterDropdownChip<T> extends StatelessWidget {
  const ListingsFilterDropdownChip({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.selectedLabel,
    this.compact = false,
    this.borderless = false,
  });

  final String label;
  final List<ListingsFilterDropdownOption<T>> options;
  final T? selected;
  final String? selectedLabel;
  final bool compact;
  final bool borderless;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          context.currentTheme.bgSurfaceBase2,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: context.currentTheme.strokeNeutralLight100),
        ),
        elevation: const WidgetStatePropertyAll(6),
        shadowColor: WidgetStatePropertyAll(
          context.currentTheme.strokeShadesBlack.withValues(alpha: 0.12),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
      ),
      menuChildren: [
        for (final option in options) _buildMenuItem(context, option),
      ],
      builder: (context, controller, child) {
        return ListingsFilterPillChip(
          label: _visibleLabel(),
          selected: selected != null || selectedLabel != null,
          trailingIcon: TablerIcons.chevron_down,
          compact: compact,
          borderless: borderless,
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ListingsFilterDropdownOption<T> option,
  ) {
    final isSelected = selected == null
        ? selectedLabel == null && option.value == null
        : option.value == selected;
    final textColor = isSelected
        ? context.currentTheme.textBrandPrimary
        : context.currentTheme.textNeutralPrimary;

    return MenuItemButton(
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isSelected
            ? context.currentTheme.bgBrandLight100
            : Colors.transparent,
      ),
      onPressed: () => onSelected(option.value),
      leadingIcon: isSelected
          ? Icon(
              TablerIcons.check,
              size: 18,
              color: context.currentTheme.iconBrandPrimary,
            )
          : const SizedBox(width: 18),
      child: Text(
        option.label,
        style: (isSelected ? AppTextStyles.p3SemiBold : AppTextStyles.p3Medium)
            .copyWith(color: textColor),
      ),
    );
  }

  String _visibleLabel() {
    if (selected == null) return selectedLabel ?? label;

    for (final option in options) {
      if (option.value == selected) return option.label;
    }
    return selectedLabel ?? label;
  }
}
