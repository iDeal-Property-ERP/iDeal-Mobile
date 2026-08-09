import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ideal_mobile/core/clarity_analytics/clarity_route_observer.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/i18n/i18n.dart';
import 'package:ideal_mobile/initialize_app.dart';
import 'package:ideal_mobile/routes.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/dynamic_icon_service.dart';
import 'package:ideal_mobile/services/locale_service.dart';
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/services/subscription_service.dart';
import 'package:ideal_mobile/services/theme_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/internet_connectivity_helper.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_bloc.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_event.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_state.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:sizer/sizer.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      Prefs.init();
      final startupFuture = initializeApp();
      runApp(MainApp(startupFuture: startupFuture));
    },
    (error, stack) {
      if (!AppEnvironment.isTestEnvironment && !kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}

class MainApp extends StatefulWidget {
  const MainApp({required this.startupFuture, super.key});

  final Future<void> startupFuture;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final AppRouter appRouter = AppRouter();
  final InternetConnectivityHelper _connectivityHelper =
      InternetConnectivityHelper();

  late ThemeBloc themeBloc;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(LocaleService.load());
    _connectivityHelper.onConnectivityChange.addListener(
      handleConnectivityStatusChange,
    );
    final themeService = ThemeService();
    themeBloc = ThemeBloc(service: themeService)..add(const LoadTheme());

    unawaited(_initializeServicesAfterStartup());
  }

  Future<void> _initializeServicesAfterStartup() async {
    try {
      await widget.startupFuture;
    } catch (_) {
      return;
    }

    if (!mounted) return;

    _initializeClarity();
    unawaited(sl<DynamicIconService>().syncIconFromRemoteConfig());

    _notificationSubscription = NotificationService.instance.onNotificationTap
        .listen(_handleNotificationTap);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      // Firebase's session is independent from the backend JWT used by the
      // phone OTP flow. A Firebase signed-out state must not unregister a
      // backend device or clear the current backend session.
      unawaited(_initializeNotificationsForBackendSession());
    });
    unawaited(_initializeNotificationsForBackendSession());
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.instance.initialize();
  }

  Future<void> _initializeNotificationsForBackendSession() async {
    try {
      if (await _hasBackendSession()) {
        await _initializeNotifications();
      }
    } catch (error) {
      debugPrint('Failed to initialize notifications: $error');
    }
  }

  Future<bool> _hasBackendSession() async {
    if (!sl.isRegistered<SecureStorageService>()) return false;
    final accessToken = await sl<SecureStorageService>().getAccessToken();
    return accessToken != null && accessToken.trim().isNotEmpty;
  }

  void _handleNotificationTap(Map<String, dynamic> payload) {
    debugPrint('Notification tapped with payload: $payload');
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigation context not available');
      return;
    }

    final notificationType = _stringPayloadValue(payload['type']);
    final relatedObjectType = _stringPayloadValue(
      payload['related_object_type'],
    );
    final relatedObjectId = _stringPayloadValue(payload['related_object_id']);

    switch (notificationType) {
      case 'service_order_status':
        if (relatedObjectType == 'order' && relatedObjectId != null) {
          debugPrint('Navigating to order details: $relatedObjectId');
          context.pushRoute(OrderDetailRoute(productId: relatedObjectId));
          return;
        }
        // TODO: Add a dedicated service-order detail route.
        _pushNotificationsRoute(context);
        return;
      case 'payment_due':
      case 'payment_paid':
        // TODO: Add an invoice/payment detail route.
        _pushNotificationsRoute(context);
        return;
      case 'payout_paid':
        // TODO: Add a payout detail route for owner notifications.
        _pushNotificationsRoute(context);
        return;
      case 'booking_status':
        // TODO: Add a booking detail route.
        _pushNotificationsRoute(context);
        return;
      case 'service_request_status':
        // TODO: Add a service-request detail route.
        _pushNotificationsRoute(context);
        return;
      case 'lease_renewal':
        // TODO: Add a lease detail route.
        _pushNotificationsRoute(context);
        return;
      case 'owner_onboarding':
        // TODO: Add an owner-onboarding route.
        _pushNotificationsRoute(context);
        return;
      case 'general':
      default:
        _pushNotificationsRoute(context);
        return;
    }
  }

  String? _stringPayloadValue(dynamic value) {
    if (value is! String) return null;
    final result = value.trim();
    return result.isEmpty ? null : result;
  }

  void _pushNotificationsRoute(BuildContext context) {
    context.pushRoute(NotificationsRoute());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_initializeNotificationsForBackendSession());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final notificationSubscription = _notificationSubscription;
    if (notificationSubscription != null) {
      unawaited(notificationSubscription.cancel());
    }

    final authSubscription = _authSubscription;
    if (authSubscription != null) {
      unawaited(authSubscription.cancel());
    }

    NotificationService.instance.dispose();
    super.dispose();
  }

  Future<void> handleConnectivityStatusChange() async {
    final isConnected = _connectivityHelper.onConnectivityChange.value;
    await Future.delayed(const Duration(milliseconds: 300));

    if (!isConnected) {
      final stillDisconnected = !_connectivityHelper.onConnectivityChange.value;
      if (!stillDisconnected) return;
      await rootNavigatorKey.currentContext!.pushRoute(const NoInternetRoute());
    } else {
      dismissConnectivityPopup();
    }
  }

  void dismissConnectivityPopup() {
    final navigator = Navigator.of(rootNavigatorKey.currentContext!);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _initializeClarity() {
    final projectId = AppConfig.getClarityProjectId();

    if (projectId.isEmpty ||
        AppEnvironment.isTestEnvironment ||
        AppConfig.appFlavor == AppFlavor.local ||
        AppConfig.appFlavor == AppFlavor.dev ||
        kIsWeb) {
      debugPrint(
        'Clarity not initialized for flavor: '
        '${AppConfig.appFlavor.name} or in test environment',
      );
      return;
    }

    final config = ClarityConfig(projectId: projectId);
    Clarity.initialize(context, config);
  }

  @override
  Widget build(BuildContext context) {
    return AppStartupScope(
      startupFuture: widget.startupFuture,
      child: BlocProvider.value(
        value: themeBloc,
        child: Sizer(
          builder: (context, orientation, screenType) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                // Speeds up `liquid_glass_widgets` rendering when multiple
                // glass widgets appear on screen. Safe even if none are used.
                return ValueListenableBuilder<Locale?>(
                  valueListenable: LocaleService.locale,
                  builder: (context, locale, _) {
                    return GlassBackdropScope(
                      child: MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        locale: locale,
                        supportedLocales: I18n.all,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          CountryLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                        ],
                        routerConfig: appRouter.config(
                          navigatorObservers: () => [ClarityRouteObserver()],
                        ),
                        theme:
                            AppThemesData.themeData[AppThemeEnum.LightTheme]!,
                        darkTheme:
                            AppThemesData.themeData[AppThemeEnum.DarkTheme]!,
                        themeMode: state.themeMode,
                        builder: (context, child) {
                          final localization = AppLocalizations.of(context)!;
                          SubscriptionService().setLocalization(localization);
                          return child!;
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
