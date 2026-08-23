import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

/// Localized motto lookup by index (0-9).
String homeMottoText(BuildContext context, int index) {
  final loc = context.localization;
  return switch (index % 10) {
    0 => loc.home_motto_1,
    1 => loc.home_motto_2,
    2 => loc.home_motto_3,
    3 => loc.home_motto_4,
    4 => loc.home_motto_5,
    5 => loc.home_motto_6,
    6 => loc.home_motto_7,
    7 => loc.home_motto_8,
    8 => loc.home_motto_9,
    9 => loc.home_motto_10,
    _ => loc.home_motto_1,
  };
}

/// Personalized sliver top bar for the home screen.
class HomeSliverTopBar extends StatelessWidget {
  const HomeSliverTopBar({
    super.key,
    required this.mottoIndex,
    required this.unreadCount,
    this.onNotificationTap,
  });

  static const double height = 68;
  static const double controlSize = 48;
  static const double controlRadius = 15;

  final int mottoIndex;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surface = isDark
        ? AppColors.bgSurfaceBaseDark
        : AppColors.bgSurfaceBase;
    final topInset = MediaQuery.paddingOf(context).top;
    final extent = height + topInset;

    return SliverAppBar(
      primary: false,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: extent,
      collapsedHeight: extent,
      toolbarHeight: extent,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const _HomeLogoBadge(),
                const SizedBox(width: 12),
                Expanded(child: _HomeGreetingAndMotto(mottoIndex: mottoIndex)),
                const SizedBox(width: 8),
                _HomeNotificationButton(
                  unreadCount: unreadCount,
                  onPressed: onNotificationTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeLogoBadge extends StatelessWidget {
  const _HomeLogoBadge();

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final isDark = context.isDark;

    return Semantics(
      image: true,
      label: 'iDeal',
      child: ExcludeSemantics(
        child: Container(
          width: HomeSliverTopBar.controlSize,
          height: HomeSliverTopBar.controlSize,
          decoration: BoxDecoration(
            color: theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(HomeSliverTopBar.controlRadius),
            border: Border.all(color: theme.strokeNeutralLight200),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            isDark
                ? Assets.icons.companyLogoDt.path
                : Assets.icons.companyLogoLt.path,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _HomeGreetingAndMotto extends StatelessWidget {
  const _HomeGreetingAndMotto({required this.mottoIndex});

  final int mottoIndex;

  @override
  Widget build(BuildContext context) {
    ProfileBloc? profileBloc;
    try {
      profileBloc = context.watch<ProfileBloc>();
    } catch (_) {}

    final firstName = profileBloc?.state.profile?.firstName;
    final String greeting;
    if (firstName != null && firstName.trim().isNotEmpty) {
      greeting = context.localization.home_greeting_user(firstName.trim());
    } else {
      greeting = context.localization.home_greeting_guest;
    }

    final motto = homeMottoText(context, mottoIndex);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.p2SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          motto,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.p4Medium.copyWith(
            color: context.currentTheme.textNeutralSecondary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _HomeNotificationButton extends StatelessWidget {
  const _HomeNotificationButton({required this.unreadCount, this.onPressed});

  final int unreadCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final isDark = context.isDark;
    final tooltip = context.localization.notifications;

    final badgeColor = isDark ? AppColors.brand400 : AppColors.brand600;
    final badgeTextColor = isDark ? AppColors.neutral900 : AppColors.white;

    final badgeLabel = unreadCount > 99
        ? '99+'
        : unreadCount > 0
        ? unreadCount.toString()
        : null;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Container(
          width: HomeSliverTopBar.controlSize,
          height: HomeSliverTopBar.controlSize,
          decoration: BoxDecoration(
            color: theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(HomeSliverTopBar.controlRadius),
            border: Border.all(color: theme.strokeNeutralLight200),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(
                HomeSliverTopBar.controlRadius,
              ),
              onTap: onPressed,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(
                    TablerIcons.bell,
                    size: 22,
                    color: theme.iconNeutralDefault,
                  ),
                  if (badgeLabel != null)
                    Positioned(
                      top: -4,
                      right: -3,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
