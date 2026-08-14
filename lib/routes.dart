import 'package:auto_route/auto_route.dart';
import 'package:ideal_mobile/main.dart';
import 'package:ideal_mobile/routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter() : super(navigatorKey: rootNavigatorKey);

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => _getRoutes();

  List<AutoRoute> _getRoutes() {
    final AutoRoute initialRoute = CustomRoute(
      page: InitialRoute.page,
      initial: true,
      transitionsBuilder: TransitionsBuilders.noTransition,
      durationInMilliseconds: 2,
    );

    final List<AutoRoute> routes = [
      // Login
      LoginWithPhoneNumberRoute.page,
      PhoneNumberOTPRoute.page,
      // Chat
      ChatsRoute.page,

      // Notifications
      NotificationsRoute.page,
      NotificationSettingsRoute.page,

      //Image view
      NetworkImageRoute.page,

      //Settings
      SettingsRoute.page,
      PersonalDetailsRoute.page,

      //Change Theme
      ChangeThemeRoute.page,
    ].map((page) => AutoRoute(page: page, path: '/${page.name}')).toList();

    final List<AutoRoute> noTransitionRoutes =
        [
              // Home page
              HomeRoute.page,
            ]
            .map(
              (page) => CustomRoute(
                page: page,
                transitionsBuilder: TransitionsBuilders.noTransition,
                durationInMilliseconds: 2,
              ),
            )
            .toList();

    // final List<AutoRoute> customRoutes = [
    //   CustomRoute(
    //     page: PostsFeedRoute.page,
    //     transitionsBuilder: TransitionsBuilders.noTransition,
    //     durationInMilliseconds: 500,
    //   ),
    // ];

    return [
      initialRoute,
      AutoRoute(page: PaymentReturnRoute.page, path: '/payment-return'),
      AutoRoute(
        page: ChatConversationRoute.page,
        path: '/chats/:conversationId',
      ),
      AutoRoute(page: ListingDetailRoute.page, path: '/listings/:listingId'),
      AutoRoute(page: BookingRoute.page, path: '/listings/:listingId/booking'),
      AutoRoute(
        page: BookingStatusRoute.page,
        path: '/bookings/:bookingId/status',
      ),
      ...routes,
      ...noTransitionRoutes,
      // ...fullScreenRoutes,
      // ...customRoutes,
    ];
  }
}
