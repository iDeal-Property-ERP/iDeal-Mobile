import 'package:flutter/material.dart';
import 'package:ideal_mobile/widgets/app_button/app_button_color.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

extension AppButtonDecorationExtension on AppButtonStyle {
  BoxDecoration? toBoxDecoration(
    BuildContext context,
    AppButtonState buttonState, {
    Color? bgColorOverride,
    Color? borderColorOverride,
    double? borderRadiusOverride,
  }) {
    final radius = BorderRadius.circular(
      borderRadiusOverride ?? AppRadius.button,
    );

    switch (this) {
      case AppButtonStyle.primary:
        final backgroundColor =
            bgColorOverride ??
            AppButtonColor.resolvePrimaryBg(context, buttonState);
        return BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: backgroundColor),
          borderRadius: radius,
        );

      case AppButtonStyle.secondary:
        final backgroundColor =
            bgColorOverride ??
            AppButtonColor.resolveSecondaryBg(context, buttonState);
        return BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: backgroundColor),
          borderRadius: radius,
        );

      case AppButtonStyle.outline:
        return BoxDecoration(
          color:
              bgColorOverride ??
              AppButtonColor.resolveOutlineBg(context, buttonState),
          border: Border.all(
            color:
                borderColorOverride ??
                AppButtonColor.resolveOutlineBorder(context, buttonState),
          ),
          borderRadius: radius,
        );

      case AppButtonStyle.link:
      case AppButtonStyle.textOrIcon:
        return null;
    }
  }
}
