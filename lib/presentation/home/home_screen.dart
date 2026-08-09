import 'package:auto_route/auto_route.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/ai_chat/widgets/ai_chat_fab.dart';
import 'package:ideal_mobile/presentation/checkout/initial_checkout_screen.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/widgets/bottom_nav_bar.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_screen_body.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/my_orders/my_orders_screen.dart';
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
  const HomeScreenWrapper({super.key});

  @override
  State<HomeScreenWrapper> createState() => HomeScreenWrapperState();
}

class HomeScreenWrapperState extends State<HomeScreenWrapper> {
  final GlobalKey bottomNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (AppEnvironment.isTestEnvironment) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<InAppReviewService>().requestReviewIfEligible();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreenBody(bottomNavKey: bottomNavKey),
      const MyOrdersScreen(),
      const InitialCheckoutScreen(),
      const ProfileScreen(),
    ];

    final int currentIndex = context.select<HomeBloc, int>(
      (bloc) => bloc.state.currentBottomNavIndex,
    );
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
        bottomNavigationBar: BottomNavBar(key: bottomNavKey),
        floatingActionButton: const AiChatFab(),
        body: SafeArea(
          child: IndexedStack(index: currentIndex, children: pages),
        ),
      ),
    );
  }
}
