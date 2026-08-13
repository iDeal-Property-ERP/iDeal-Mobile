import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/ai_chat/widgets/ai_chat_fab.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/chats_screen.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/widgets/bottom_nav_bar.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_screen_body.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/profile/profile_screen.dart';
import 'package:ideal_mobile/services/in_app_review_service.dart';
import 'package:ideal_mobile/utils/app_environment.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<ListingsBloc>(
          create: (_) => ListingsBloc()
            ..add(const LoadFavoritesEvent())
            ..add(const LoadFilterOptionsEvent())
            ..add(const LoadListingsEvent()),
        ),
      ],
      child: const HomeScreenWrapper(),
    );
  }
}

class HomeScreenWrapper extends StatefulWidget {
  const HomeScreenWrapper({this.chatsBloc, this.chatBadgeCubit, super.key});

  final ChatsBloc? chatsBloc;
  final ChatBadgeCubit? chatBadgeCubit;

  @override
  State<HomeScreenWrapper> createState() => HomeScreenWrapperState();
}

class HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final GlobalKey bottomNavKey = GlobalKey();
  ChatsBloc? _chatsBloc;
  late final ChatBadgeCubit _chatBadgeCubit;
  bool _ownsChatsBloc = false;
  bool _chatPollingActive = false;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _chatsBloc = widget.chatsBloc;
    _chatBadgeCubit = widget.chatBadgeCubit ?? sl<ChatBadgeCubit>();
    _pages = [HomeScreenBody(bottomNavKey: bottomNavKey), null, null];
    if (!AppEnvironment.isTestEnvironment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sl<InAppReviewService>().requestReviewIfEligible();
      });
    }
  }

  void _syncChatPolling(int currentIndex) {
    final shouldPoll = currentIndex == 1;
    if (shouldPoll == _chatPollingActive) return;

    _chatPollingActive = shouldPoll;
    final bloc = _chatsBloc;
    if (bloc == null) return;
    bloc.add(shouldPoll ? const ChatsStarted() : const ChatsStopped());
  }

  ChatsBloc _chatBloc() {
    final existing = _chatsBloc;
    if (existing != null) return existing;
    final created = ChatsBloc();
    _chatsBloc = created;
    _ownsChatsBloc = true;
    return created;
  }

  @override
  void dispose() {
    if (_chatPollingActive) {
      _chatsBloc?.add(const ChatsStopped());
    }
    if (_ownsChatsBloc) unawaited(_chatsBloc?.close() ?? Future.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = context.select<HomeBloc, int>(
      (bloc) => bloc.state.currentBottomNavIndex,
    );
    _pages[currentIndex] ??= switch (currentIndex) {
      1 => ChatsScreen(bloc: _chatBloc()),
      2 => const ProfileScreen(),
      _ => HomeScreenBody(bottomNavKey: bottomNavKey),
    };
    _syncChatPolling(currentIndex);
    final String screenName = _pages[currentIndex]!.runtimeType.toString();
    Clarity.setCurrentScreenName(screenName);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          context.read<HomeBloc>().add(
            const BottomNavBarIndexChangedEvent(index: 0),
          );
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          key: bottomNavKey,
          chatBadgeCubit: _chatBadgeCubit,
        ),
        floatingActionButton: const AiChatFab(),
        body: SafeArea(
          child: IndexedStack(
            index: currentIndex,
            children: _pages.map((page) => page ?? const SizedBox()).toList(),
          ),
        ),
      ),
    );
  }
}
