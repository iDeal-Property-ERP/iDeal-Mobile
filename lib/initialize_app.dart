import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/firebase_options_dev.dart' as dev;
import 'package:ideal_mobile/firebase_options_prod.dart' as prod;
import 'package:ideal_mobile/services/notification_service.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';

Future<void> initializeApp({Dio? dio}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = switch (AppConfig.appFlavor) {
    // The local API uses the dev native flavor (`--flavor dev`).
    AppFlavor.local ||
    AppFlavor.dev => dev.DefaultFirebaseOptions.currentPlatform,
    AppFlavor.prod => prod.DefaultFirebaseOptions.currentPlatform,
  };

  await Firebase.initializeApp(options: firebaseOptions);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  final bool isTestEnvironment = AppEnvironment.isTestEnvironment;

  if (!isTestEnvironment && !kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await SystemChrome.setPreferredOrientations([.portraitUp, .portraitDown]);

  await dotenv.load();

  await configureDependencies(dio: dio);
}

class AppStartupScope extends InheritedWidget {
  const AppStartupScope({
    required this.startupFuture,
    required super.child,
    super.key,
  });

  final Future<void> startupFuture;

  static Future<void> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStartupScope>();
    assert(scope != null, 'No AppStartupScope found in context.');
    return scope!.startupFuture;
  }

  @override
  bool updateShouldNotify(AppStartupScope oldWidget) {
    return startupFuture != oldWidget.startupFuture;
  }
}
