# iDeal Mobile

Mobile application for the iDeal marketplace.

## Stack

- Flutter and Dart
- BLoC state management
- Auto Route navigation
- Firebase Auth, Analytics, Crashlytics, Messaging, and Performance
- Flutter localization, code generation, widget tests, and Patrol integration tests

## Setup

1. Copy `.env.example` to `.env` and fill in environment-specific values.
2. Configure Firebase for each flavor. The native
   `google-services.json` and `GoogleService-Info.plist` files are intentionally
   ignored and must be supplied locally.
3. Install dependencies and generate code:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Run

```bash
# Local mode uses the local backend. For a USB-connected Android device, forward
# the host port first; Android emulators can use 10.0.2.2 instead of localhost.
adb reverse tcp:8000 tcp:8000
flutter run --flavor dev --dart-define=APP_FLAVOR=LOCAL
# Dev mode uses https://dev.i-deal.uz/api/v1 without certificate pinning.
flutter run --flavor dev --dart-define=APP_FLAVOR=DEV
# Prod mode uses https://i-deal.uz/api/v1 with certificate pinning.
flutter run --flavor prod --dart-define=APP_FLAVOR=PROD
```

The backend repository runs locally with `just run` on port `8000`. The local
health endpoint is `/api/v1/health/`. For an iOS Simulator, change
`LOCAL_API_BASE_URL` to `http://127.0.0.1:8000/api/v1`; for a physical device,
use the host machine's LAN IP and bind Django to an accessible interface.
Production requires its API host and certificate hash to be configured.

Android application IDs are `com.ideal.mobile.dev`, `com.ideal.mobile.stage`,
and `com.ideal.mobile`. Replace the placeholder deep-link host
`ideal.example.com` in the native manifests and
`lib/presentation/product_detail/constant/product_detail_constants.dart` when
the production domain is available.

## Validate

```bash
dart format lib test integration_test
flutter analyze
flutter test
```
