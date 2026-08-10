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
  late final ChatsBloc _chatsBloc;
  late final ChatBadgeCubit _chatBadgeCubit;
  bool _ownsChatsBloc = false;
  bool _chatPollingActive = false;

  @override
  void initState() {
    super.initState();
    final chatsBloc = widget.chatsBloc;
    if (chatsBloc == null) {
      _chatsBloc = ChatsBloc();
      _ownsChatsBloc = true;
    } else {
      _chatsBloc = chatsBloc;
    }
    _chatBadgeCubit = widget.chatBadgeCubit ?? sl<ChatBadgeCubit>();
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
    _chatsBloc.add(shouldPoll ? const ChatsStarted() : const ChatsStopped());
  }

  @override
  void dispose() {
    if (_chatPollingActive) {
      _chatsBloc.add(const ChatsStopped());
    }
    if (_ownsChatsBloc) unawaited(_chatsBloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreenBody(bottomNavKey: bottomNavKey),
      ChatsScreen(bloc: _chatsBloc),
      const ProfileScreen(),
    ];

    final int currentIndex = context.select<HomeBloc, int>(
      (bloc) => bloc.state.currentBottomNavIndex,
    );
    _syncChatPolling(currentIndex);
    final String screenName = pages[currentIndex].runtimeType.toString();
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
          child: IndexedStack(index: currentIndex, children: pages),
        ),
      ),
    );
  }
}
