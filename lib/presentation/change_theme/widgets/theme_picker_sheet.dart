import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_bloc.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_event.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) =>
          BlocProvider.value(value: themeBloc, child: const ThemePickerSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select<ThemeBloc, ThemeMode?>(
      (bloc) => bloc.state.themeMode,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                context.localization.choose_app_theme,
                style: AppTextStyles.h6Bold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ...ThemeMode.values.map(
              (themeMode) => _ThemeOptionCard(
                themeMode: themeMode,
                isSelected: selectedThemeMode == themeMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({required this.themeMode, required this.isSelected});

  final ThemeMode themeMode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? const Color(0xFF3B82F6)
        : context.currentTheme.textNeutralPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: isSelected
            ? (context.isDark
                  ? const Color(0xFF1E2E4A)
                  : const Color(0xFFEAF1FE))
            : (context.isDark
                  ? context.currentTheme.bgSurfaceBase2
                  : Colors.white),
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () async {
            await HapticFeedbackUtil.light();
            if (!context.mounted) return;
            context.read<ThemeBloc>().add(SetThemeModeEvent(mode: themeMode));
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : context.currentTheme.strokeNeutralLight200,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(_iconFor(themeMode), color: textColor, size: 22.0),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    themeMode.name.toLowerCase().capitalizeFirst,
                    style: AppTextStyles.p2SemiBold.copyWith(color: textColor),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    TablerIcons.check,
                    color: Color(0xFF3B82F6),
                    size: 20.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }
}
