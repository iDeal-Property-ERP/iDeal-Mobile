import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as services;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { local, dev, prod }

class AppConfig {
  static const _app_flavor = 'APP_FLAVOR';
  static const _local = 'local';
  static const _dev = 'dev';
  static const _prod = 'prod';

  /// Fetch app flavor from environment (`dart-define`),
  /// native flavor (`services.appFlavor`), or build mode
  static AppFlavor get appFlavor {
    // 1. Explicit dart-define --dart-define=APP_FLAVOR=prod|dev|local
    const dartDefineFlavor = String.fromEnvironment(_app_flavor);
    if (dartDefineFlavor.isNotEmpty) {
      return _parseFlavor(dartDefineFlavor);
    }

    // 2. Native flavor from Gradle / Xcode (--flavor prod|dev)
    const nativeFlavor = services.appFlavor;
    if (nativeFlavor != null && nativeFlavor.isNotEmpty) {
      return _parseFlavor(nativeFlavor);
    }

    // 3. Fallback: Release builds must NEVER default to local/ngrok
    if (kReleaseMode) {
      return AppFlavor.prod;
    }

    return AppFlavor.local;
  }

  static AppFlavor _parseFlavor(String flavor) {
    switch (flavor.toLowerCase()) {
      case _local:
        return AppFlavor.local;
      case _dev:
        return AppFlavor.dev;
      case _prod:
        return AppFlavor.prod;
      default:
        return AppFlavor.prod;
    }
  }

  static String get baseUrl {
    if (!dotenv.isInitialized) return '';
    switch (appFlavor) {
      case AppFlavor.local:
        return dotenv.env['LOCAL_API_BASE_URL'] ?? '';
      case AppFlavor.dev:
        return dotenv.env['DEV_API_BASE_URL'] ?? '';
      case AppFlavor.prod:
        return dotenv.env['PROD_API_BASE_URL'] ?? '';
    }
  }

  static String get frontendBaseUrl {
    if (!dotenv.isInitialized) return '';
    switch (appFlavor) {
      case AppFlavor.local:
        return dotenv.env['LOCAL_FRONTEND_BASE_URL'] ?? '';
      case AppFlavor.dev:
        return dotenv.env['DEV_FRONTEND_BASE_URL'] ?? '';
      case AppFlavor.prod:
        return dotenv.env['PROD_FRONTEND_BASE_URL'] ?? '';
    }
  }

  static String get supportTelegramUrl => dotenv.isInitialized
      ? dotenv.env['SUPPORT_TELEGRAM_URL']?.trim() ?? ''
      : '';

  static String get supportWhatsAppUrl => dotenv.isInitialized
      ? dotenv.env['SUPPORT_WHATSAPP_URL']?.trim() ?? ''
      : '';

  static String _stripEnvQuotes(String value) {
    var v = value.trim();
    if (v.length >= 2) {
      final first = v[0];
      final last = v[v.length - 1];
      if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
        v = v.substring(1, v.length - 1).trim();
      }
    }
    return v;
  }

  static String get yandexMapKitApiKey => dotenv.isInitialized
      ? _stripEnvQuotes(dotenv.env['YANDEX_MAPKIT_API_KEY'] ?? '')
      : '';

  static String get googleMapsApiKey => dotenv.isInitialized
      ? _stripEnvQuotes(dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '')
      : '';

  static String get mapObfuscationSecret {
    if (!dotenv.isInitialized) return '';
    return _stripEnvQuotes(dotenv.env['MAP_OBFUSCATION_SECRET'] ?? '');
  }

  static String getClarityProjectId() {
    if (!dotenv.isInitialized) return '';
    switch (appFlavor) {
      case AppFlavor.local:
        return '';
      case AppFlavor.prod:
        return dotenv.env['CLARITY_PROJECT_ID_PROD']?.trim() ?? '';
      case AppFlavor.dev:
        // Note: Dev flavor — Clarity analytics excluded
        return '';
    }
  }
}
