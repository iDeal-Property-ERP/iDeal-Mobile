import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { local, dev, prod }

class AppConfig {
  static const _app_flavor = 'APP_FLAVOR';
  static const _local = 'local';
  static const _dev = 'dev';
  static const _prod = 'prod';

  /// Fetch app flavor from environment variables (`dart-define`)
  static AppFlavor get appFlavor {
    const flavor = String.fromEnvironment(_app_flavor, defaultValue: _local);
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
    switch (appFlavor) {
      case AppFlavor.local:
        return dotenv.env['LOCAL_FRONTEND_BASE_URL'] ?? '';
      case AppFlavor.dev:
        return dotenv.env['DEV_FRONTEND_BASE_URL'] ?? '';
      case AppFlavor.prod:
        return dotenv.env['PROD_FRONTEND_BASE_URL'] ?? '';
    }
  }

  static String get supportTelegramUrl =>
      dotenv.env['SUPPORT_TELEGRAM_URL']?.trim() ?? '';

  static String get supportWhatsAppUrl =>
      dotenv.env['SUPPORT_WHATSAPP_URL']?.trim() ?? '';

  static String getDioCertHash() {
    switch (appFlavor) {
      case AppFlavor.local:
        return '';
      case AppFlavor.dev:
        return dotenv.env['CERT_HASH_DEV']?.trim() ?? '';
      case AppFlavor.prod:
        return dotenv.env['CERT_HASH_PROD']?.trim() ?? '';
    }
  }

  static String get yandexMapKitApiKey => dotenv.isInitialized
      ? dotenv.env['YANDEX_MAPKIT_API_KEY']?.trim() ?? ''
      : '';

  static String get googleMapsApiKey => dotenv.isInitialized
      ? dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? ''
      : '';

  static String get mapObfuscationSecret => dotenv.isInitialized
      ? dotenv.env['MAP_OBFUSCATION_SECRET']?.trim() ??
            'iDeal-Secret-Map-Seed-2025'
      : 'iDeal-Secret-Map-Seed-2025';

  static String getClarityProjectId() {
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
