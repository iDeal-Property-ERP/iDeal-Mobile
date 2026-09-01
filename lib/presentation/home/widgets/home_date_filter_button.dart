import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

/// 48px calendar action shown beside the Home "All filters" button. Opens the
/// availability date-filter sheet and shows an active indicator while a date
/// range is selected.
class HomeDateFilterButton extends StatelessWidget {
  const HomeDateFilterButton({
    required this.onTap,
    this.isActive = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        clipBehavior: Clip.none,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isActive
                ? theme.strokeBrandHover
                : theme.strokeNeutralLight200,
          ),
          backgroundColor: isActive
              ? theme.bgBrandLight100
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          foregroundColor: theme.textNeutralPrimary,
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              TablerIcons.calendar,
              size: 20,
              color: isActive
                  ? theme.iconBrandPrimary
                  : theme.iconNeutralDefault,
            ),
            if (isActive)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.bgBrandDefault,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
