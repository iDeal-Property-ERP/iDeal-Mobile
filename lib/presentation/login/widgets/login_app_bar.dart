import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

class LoginAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoginAppBar({
    super.key,
    this.removeLeading = true,
    this.showAppIcon = true,
    this.rightAction,
  });

  final bool removeLeading;
  final bool showAppIcon;
  final Widget? rightAction;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQueryData.fromView(View.of(context)).padding.top;
    final bar = AppTopBar.page(
      title: '',
      showBackButton: !removeLeading,
      onBack: removeLeading ? null : () => context.router.maybePop(),
    );

    return PreferredSize(
      preferredSize: bar.preferredSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          bar,
          if (showAppIcon)
            Positioned(
              top: topInset,
              left: 0,
              right: 0,
              height: AppTopBar.height,
              child: IgnorePointer(
                child: Center(
                  child: AppButton.icon(
                    appIcon: context.themeAsset(
                      light: Assets.icons.companyLogoLt.path,
                      dark: Assets.icons.companyLogoDt.path,
                    ),
                    size: AppButtonSize.extraLarge,
                    iconOrTextColorOverride:
                        context.currentTheme.bgBrandDefault,
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          if (rightAction != null)
            Positioned(top: topInset + 10, right: 8, child: rightAction!),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppTopBar.height);
}
