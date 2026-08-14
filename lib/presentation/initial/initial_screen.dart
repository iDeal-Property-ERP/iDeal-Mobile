import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/initialize_app.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

@RoutePage()
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  static const _minimumSplashDuration = Duration(milliseconds: 280);

  late final Future<void> _minimumSplashDurationFuture;
  bool _hasStartedStartupRouting = false;
  bool _hasRedirected = false;

  Future<void> _waitForStartupAndRoute(Future<void> startupFuture) async {
    await startupFuture;

    if (!mounted) return;
    await _checkAuthAndHandleDeepLink();
  }

  Future<void> _checkAuthAndHandleDeepLink() async {
    final userDetails = await LoginDetails.fromPrefs();
    final secureAccessToken = sl.isRegistered<SecureStorageService>()
        ? await sl<SecureStorageService>().getAccessToken()
        : null;
    final hasBackendAccessToken =
        secureAccessToken.haveContent() ||
        userDetails.accessToken.haveContent();

    if (!mounted) return;

    if (hasBackendAccessToken) {
      await _replace(const HomeRoute());
    } else {
      final skippedLogin = await Prefs.getBool(PrefKeys.kSkippedLogin) ?? false;
      await _replace(
        skippedLogin ? const HomeRoute() : LoginWithPhoneNumberRoute(),
      );
    }
  }

  Future<bool> _beginRedirect() async {
    if (_hasRedirected || !mounted) return false;

    await _minimumSplashDurationFuture;

    if (_hasRedirected || !mounted) return false;

    _hasRedirected = true;
    return true;
  }

  Future<void> _replace(PageRouteInfo route) async {
    if (!await _beginRedirect()) return;

    await context.router.replace(route);
  }

  @override
  void initState() {
    super.initState();
    _minimumSplashDurationFuture = Future<void>.delayed(_minimumSplashDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStartedStartupRouting) return;

    _hasStartedStartupRouting = true;
    unawaited(_waitForStartupAndRoute(AppStartupScope.of(context)));
  }

  @override
  Widget build(BuildContext context) {
    return const InitialScreenBody();
  }
}

class InitialScreenBody extends StatelessWidget {
  const InitialScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.96, end: 1),
                  builder: (context, scale, child) {
                    return Opacity(
                      opacity: ((scale - 0.96) / 0.04)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Assets.icons.loginLogo.path,
                        width: 104,
                        height: 104,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'iDeal',
                        style: AppTextStyles.h1.copyWith(
                          color: theme.textNeutralWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: theme.bgBrandDefault,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
