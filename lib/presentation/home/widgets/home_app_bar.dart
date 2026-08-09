import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(14),
        child: Image.asset(
          context.themeAsset(
            light: Assets.icons.companyLogoLt.path,
            dark: Assets.icons.companyLogoDt.path,
          ),
        ),
      ),
      title: Text(
        context.localization.home,
        style: AppTextStyles.h6SemiBold.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      actions: [
        BlocProvider.value(
          value: sl<NotificationBadgeCubit>()..initialize(),
          child: const _NotificationBell(),
        ),
        AppButton.icon(
          iconData: TablerIcons.message,
          iconOrTextColorOverride: context.currentTheme.iconNeutralDefault,
          size: AppButtonSize.extraLarge,
          onPressed: () => context.pushRoute(const ChatRoute()),
        ),
        AppButton.icon(
          iconData: TablerIcons.info_circle,
          iconOrTextColorOverride: context.currentTheme.iconNeutralDefault,
          size: AppButtonSize.extraLarge,
          onPressed: () => context.pushRoute(const EmptyViewsRoute()),
        ),
      ],
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBadgeCubit, int>(
      builder: (context, unreadCount) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AppButton.icon(
              onPressed: () => context.pushRoute(NotificationsRoute()),
              size: AppButtonSize.extraLarge,
              iconData: TablerIcons.bell,
              iconOrTextColorOverride: context.currentTheme.iconNeutralDefault,
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  padding: unreadCount > 9
                      ? const EdgeInsets.symmetric(horizontal: 3)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: context.currentTheme.bgBrandHover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: unreadCount > 9
                      ? const Text(
                          '9+',
                          style: TextStyle(fontSize: 9, color: Colors.white),
                        )
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
