import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/guest_access_service.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({this.chatBadgeCubit, super.key});

  final ChatBadgeCubit? chatBadgeCubit;

  @override
  Widget build(BuildContext context) {
    final badgeCubit = chatBadgeCubit ?? sl<ChatBadgeCubit>();
    badgeCubit.initialize();
    final int pageIndex = context.select<HomeBloc, int>(
      (bloc) => bloc.state.currentBottomNavIndex,
    );
    final int barIndex = switch (pageIndex) {
      1 => 1,
      2 => 3,
      3 => 4,
      _ => 0,
    };

    return BottomNavigationBar(
      currentIndex: barIndex,
      onTap: (navIndex) async {
        if (navIndex != 0 &&
            !await GuestAccessService.requireAuthentication(context)) {
          return;
        }
        if (!context.mounted) return;

        if (navIndex == 2) {
          unawaited(context.router.push(const ListPropertyWizardRoute()));
          return;
        }

        final targetPageIndex = switch (navIndex) {
          1 => 1,
          3 => 2,
          4 => 3,
          _ => 0,
        };

        context.read<HomeBloc>().add(
          BottomNavBarIndexChangedEvent(index: targetPageIndex),
        );
      },
      selectedItemColor: context.currentTheme.iconBrandHover,
      unselectedItemColor: context.currentTheme.strokeNeutralDefault,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyles.p4Medium,
      unselectedLabelStyle: AppTextStyles.p4Medium,
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.currentTheme.bgSurfaceBase,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(TablerIcons.home),
          label: context.localization.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(TablerIcons.heart),
          label: context.localization.selected,
        ),
        BottomNavigationBarItem(
          icon: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: context.currentTheme.bgBrandDefault,
              shape: BoxShape.circle,
            ),
            child: const Icon(TablerIcons.plus, color: Colors.white, size: 16),
          ),
          label: context.localization.list_property,
        ),
        BottomNavigationBarItem(
          icon: BlocProvider.value(
            value: badgeCubit,
            child: const _ChatBadgeIcon(),
          ),
          label: context.localization.chats,
        ),
        BottomNavigationBarItem(
          icon: const Icon(TablerIcons.user),
          label: context.localization.profile,
        ),
      ],
    );
  }
}

class _ChatBadgeIcon extends StatelessWidget {
  const _ChatBadgeIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBadgeCubit, int>(
      builder: (context, unreadCount) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(TablerIcons.message_circle),
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
