import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class NavigateToHomeScreenButton extends StatelessWidget {
  const NavigateToHomeScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.localization.go_to_home,
      style: AppButtonStyle.textOrIcon,
      foregroundColor: context.currentTheme.textBrandSecondary,
      shouldSetFullWidth: true,
      size: AppButtonSize.extraLarge,
      onPressed: () => context.router.pushAndPopUntil(
        const HomeRoute(),
        predicate: (_) => false,
      ),
    );
  }
}
