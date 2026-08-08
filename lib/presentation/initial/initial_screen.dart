import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/deep_link/app_deep_link_manager.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/initialize_app.dart';
import 'package:ideal_mobile/presentation/biometric_auth/widgets/biometric_auth_enrollment_bottom_sheet.dart';
import 'package:ideal_mobile/presentation/force_update/constants/force_update_constants.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/local_auth_services.dart';
import 'package:ideal_mobile/services/remote_config_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/app_version_helper.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    await _checkForceUpdateAndAuthStatus();
  }

  Future<void> _checkForceUpdateAndAuthStatus() async {
    final remoteConfig = RemoteConfigService();

    final appCurrentVersion = (await PackageInfo.fromPlatform()).version;

    if (!mounted) return;

    final currentAppVersion = getExtendedVersionNumber(appCurrentVersion);
    final latestAppVersion = getExtendedVersionNumber(
      remoteConfig.getString(kRemoteConfigAppLatestVersionKey),
    );
    final minimumRequiredVersion = getExtendedVersionNumber(
      remoteConfig.getString(kRemoteConfigMandatoryAppVersionKey),
    );

    final isMandatoryUpdateRequired =
        currentAppVersion < minimumRequiredVersion;
    final isOptionalUpdateAvailable = currentAppVersion < latestAppVersion;

    if (isMandatoryUpdateRequired) {
      await _replaceAll([ForceUpdateRoute(isMandatoryUpdate: true)]);
      return;
    }

    if (isOptionalUpdateAvailable) {
      await showOptionalUpdate(context: context);
    }

    await _checkAuthAndHandleDeepLink();
  }

  Future<void> _checkAuthAndHandleDeepLink() async {
    final userDetailsJson = await Prefs.getString(PrefKeys.kUserDetails);
    final userDetails = LoginDetails.fromJson(
      json.decode(userDetailsJson ?? '{}'),
    );
    final secureAccessToken = sl.isRegistered<SecureStorageService>()
        ? await sl<SecureStorageService>().getAccessToken()
        : null;
    final hasBackendAccessToken =
        secureAccessToken.haveContent() ||
        userDetails.accessToken.haveContent();
    final hasExistingFirebaseSession = userDetails.token.haveContent();

    if (!mounted) return;

    final deepLinkManager = sl<AppDeepLinkManager>();

    if (hasBackendAccessToken || hasExistingFirebaseSession) {
      // Authenticate with biometrics if enabled
      // This will exit app if auth fails, or return if succeeds/not enabled
      await authenticateWithBiometrics(context);

      if (!mounted) return;

      if (deepLinkManager.hasPendingDeepLink) {
        final isDeepLinkHandled = await deepLinkManager.handlePendingDeepLink(
          context,
        );

        // Case 1: Deep link exists -> try handling it; if invalid,
        // navigate to Home.
        if (!isDeepLinkHandled) {
          await _replace(const HomeRoute());
        } else {
          _hasRedirected = true;
        }
      } else {
        // Case 2: No deep link -> navigate directly to Home.
        await _replace(const HomeRoute());
      }
    } else {
      final skippedLogin = await Prefs.getBool(PrefKeys.kSkippedLogin) ?? false;
      await _replace(
        skippedLogin ? const HomeRoute() : LoginWithPhoneNumberRoute(),
      );
    }
  }

  Future<void> showOptionalUpdate({required BuildContext context}) async {
    final dateTimeNow = DateTime.now();

    final lastShownUpdatePromptTimeStamp = await Prefs.getInt(
      kLastShownUpdatePromptTimestamp,
    );

    final lastShownUpdateTime = lastShownUpdatePromptTimeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(lastShownUpdatePromptTimeStamp)
        : null;

    final hasNeverBeenShown = lastShownUpdateTime == null;
    final cooldownTimePassed =
        lastShownUpdateTime != null &&
        dateTimeNow.difference(lastShownUpdateTime) >=
            kOptionalUpdateCooldownTime;

    final shouldShowUpdatePrompt = hasNeverBeenShown || cooldownTimePassed;

    if (shouldShowUpdatePrompt) {
      await Prefs.setInt(
        kLastShownUpdatePromptTimestamp,
        dateTimeNow.millisecondsSinceEpoch,
      );

      await _minimumSplashDurationFuture;
      if (!mounted) return;

      await context.router.push(ForceUpdateRoute(isMandatoryUpdate: false));
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

  Future<void> _replaceAll(List<PageRouteInfo> routes) async {
    if (!await _beginRedirect()) return;

    await context.router.replaceAll(routes);
  }

  Future<void> authenticateWithBiometrics(BuildContext context) async {
    final localAuthService = sl<LocalAuthService>();

    final isBiometricEnabled =
        await Prefs.getBool(PrefKeys.kIsBiometricEnabled) ?? false;

    if (!isBiometricEnabled) {
      // User hasn't enabled biometric auth, proceed to home
      return;
    }

    final biometricAuthStatus = await localAuthService.authenticate(
      context.localization,
    );

    switch (biometricAuthStatus) {
      case BiometricAuthStatus.success:
        // Authentication successful, continue to home
        break;

      case BiometricAuthStatus.notSupported:
        // Device doesn't support biometrics, continue to home
        break;

      case BiometricAuthStatus.notEnrolled:
        await _showBiometricEnrollmentBottomSheet(context);

      case BiometricAuthStatus.cancelled:
        _exitApp();

      case BiometricAuthStatus.error:
        _exitApp();

      case BiometricAuthStatus.tooManyAttempts:
        _exitApp();
    }
  }

  Future<void> _showBiometricEnrollmentBottomSheet(BuildContext context) async {
    final result = await showBiometricSetupEnrollmentBottomSheet(context);

    // If user cancelled, dismissed, or after going to settings, exit the app
    if (result == null || result == .cancel || result == .settings) {
      _exitApp();
    }
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      FlutterExitApp.exitApp();
    } else if (Platform.isIOS) {
      FlutterExitApp.exitApp(iosForceExit: true);
    }
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
