import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/chats_screen.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/selected_screen.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/widgets/bottom_nav_bar.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_screen_body.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/profile/profile_screen.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<SelectedBloc>(create: (_) => SelectedBloc()),
        BlocProvider<ListingsBloc>(
          create: (_) => ListingsBloc()
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
  int _lastBottomNavIndex = 0;
  late final List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _chatsBloc = widget.chatsBloc;
    _chatBadgeCubit = widget.chatBadgeCubit ?? sl<ChatBadgeCubit>();
    _pages = [const HomeScreenBody(), null, null, null];
  }

  void _syncChatPolling(int currentIndex) {
    final shouldPoll = currentIndex == 2;
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

    if (currentIndex == 1 && _lastBottomNavIndex != 1) {
      context.read<SelectedBloc>().add(const LoadSelectedEvent(refresh: true));
    }

    _pages[currentIndex] ??= switch (currentIndex) {
      1 => const SelectedScreen(),
      2 => ChatsScreen(bloc: _chatBloc()),
      3 => const ProfileScreen(),
      _ => const HomeScreenBody(),
    };
    _lastBottomNavIndex = currentIndex;

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
