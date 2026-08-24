# Release Guide — Build & Upload

This project ships via four small scripts, two per platform. All of them are
argument-driven, support `--dry-run`, and share one configuration file.

```
scripts/
├── lib/common.sh                  # shared helpers (versioning, logging, paths)
└── build/
    ├── .env.example               # config template → copy to .env
    ├── .env                       # your real config (gitignored)
    ├── .secrets/                  # keys & credentials (gitignored)
    │   ├── ios/AuthKey_<KEYID>.p8
    │   └── android/play-service-account.json
    ├── ios/{build.sh, upload.sh}
    └── android/{build.sh, upload.sh}
```

---

## 0. Platform support

| Script | macOS | Linux |
|---|---|---|
| `android/build.sh` | ✅ | ✅ |
| `android/upload.sh` | ✅ | ✅ |
| `ios/build.sh` | ✅ (Xcode required) | ❌ |
| `ios/upload.sh` | ✅ | ✅ |

Notes for Linux:

- The scripts are bash; ensure `bash` is on `PATH` (`#!/usr/bin/env bash`).
- Set `JAVA_HOME` if Gradle can't find a JDK — otherwise a JDK 17+ on `PATH`
  is used. Known Android Studio JBR locations are probed automatically.
- Install fastlane via Ruby: `gem install fastlane` (distro packages are
  usually outdated).
- iOS *uploads* work from Linux because authentication uses an App Store
  Connect API key (no Xcode/keychain involved) — build the IPA on macOS/CI,
  copy it over, then upload with `-i /path/to.ipa`.

---

## 1. Prerequisites

| Tool | Needed for | Install |
|---|---|---|
| Flutter SDK | both build scripts | https://docs.flutter.dev/get-started/install/macos |
| Xcode + command line tools | iOS | `xcode-select --install` |
| Android Studio JBR / JDK 17 | Android | auto-detected; or set `JAVA_HOME` |
| **fastlane** | both upload scripts | `brew install fastlane` (or `gem install fastlane`) |

Check everything: `flutter doctor && fastlane -v`

---

## 2. One-time setup

### 2a. Configure scripts

```bash
cp scripts/build/.env.example scripts/build/.env   # then edit it
mkdir -p scripts/build/.secrets/ios scripts/build/.secrets/android
```

`.env` is gitignored — safe for secrets. Every value in it can also be
overridden per invocation with script flags.

### 2b. App Store Connect API key (iOS uploads)

1. Go to https://appstoreconnect.apple.com → **Users and Access** → **Integrations** → **App Store Connect API**
2. Generate a key with the **App Manager** role.
3. Note down the **key id** and **issuer id** shown there.
4. Download the `.p8` file and move it to:
   `scripts/build/.secrets/ios/AuthKey_<KEYID>.p8`
5. Fill `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
   `APP_STORE_CONNECT_KEY_FILE` in `scripts/build/.env`.

### 2c. Google Play service account (Android uploads)

1. In [Google Cloud Console](https://console.cloud.google.com) enable the **Google Play Android Developer API**.
2. Create a **service account**, download its JSON key and save it as:
   `scripts/build/.secrets/android/play-service-account.json`
3. In Play Console → **Users and permissions**: invite that service account's
   email and grant it the **Release to testing tracks** / **Release apps** permissions.
4. Set `ANDROID_PLAY_SERVICE_ACCOUNT_JSON` in `scripts/build/.env`.

### 2d. Signing

- **iOS** — open `ios/Runner.xcworkspace`, set your Team for the `dev`/`prod`
  schemes, let Xcode manage provisioning (`flutter build ipa` uses those settings).
- **Android** — create `android/key.properties` pointing at your keystore
  (see `android/key.properties.example`). Without it, release builds fall back
  to debug signing and the build script will warn you.

---

## 3. Versioning

`pubspec.yaml` holds the single source of truth: `version: <name>+<build>`.

- `--bump` increments `<build>` in `pubspec.yaml` **before** building
  (commit the change afterwards).
- `--build-number N` / `--build-name X.Y.Z` override values without touching
  the file (handy for CI).

Both platforms read the same numbers, so an iOS and Android build with the
same flags always match versions.

---

## 4. Building

### Android

```bash
scripts/build/android/build.sh --help          # full reference

# Common recipes
scripts/build/android/build.sh                          # prod AAB
scripts/build/android/build.sh -f dev -t apk            # dev split APKs
scripts/build/android/build.sh --format both --bump     # AAB + APKs, bump first
scripts/build/android/build.sh --build-number 42        # fixed build code
```

Artifacts:

- AAB → `build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab`
- APK → `build/app/outputs/flutter-apk/app-<abi>-<flavor>-release.apk`

> Google Play requires an **AAB** for new releases; use APKs only for direct
> distribution/testing.

### iOS

```bash
scripts/build/ios/build.sh --help              # full reference

# Common recipes
scripts/build/ios/build.sh                     # prod IPA (app-store export)
scripts/build/ios/build.sh -f dev              # dev IPA for TestFlight
scripts/build/ios/build.sh --export-method ad-hoc
```

Artifact:

- prod → `build/ios/ipa/iDeal Mobile.ipa`
- dev  → `build/ios/ipa/iDeal Mobile Dev.ipa`

---

## 5. Uploading

### Android → Google Play

```bash
scripts/build/android/upload.sh --help         # full reference

# Common recipes
scripts/build/android/upload.sh                            # newest prod AAB → internal track
scripts/build/android/upload.sh -t beta                    # beta track
scripts/build/android/upload.sh -t production              # production rollout
scripts/build/android/upload.sh -t internal --release-status draft   # hold in console
scripts/build/android/upload.sh -a path/to/app.aab         # explicit artifact
```

Notes:

- Auto-detects the newest artifact for the chosen flavor (AAB preferred;
  multiple split APKs must be passed explicitly via `-a`).
- Default package ids come from `.env`: `com.ideal.uz` / `com.ideal.uz.dev`.
  The `dev` application id usually doesn't exist in Play Console — upload the
  `prod` flavor.
- `--release-status completed` publishes to the track immediately; `draft`
  keeps it for manual review in Play Console.

### iOS → TestFlight / App Store

```bash
scripts/build/ios/upload.sh --help             # full reference

# Common recipes
scripts/build/ios/upload.sh                                  # prod IPA → TestFlight, wait for processing
scripts/build/ios/upload.sh -f dev                           # dev IPA → TestFlight
scripts/build/ios/upload.sh -f dev --beta-groups "QA Team"   # distribute to testers group
scripts/build/ios/upload.sh -t appstore                      # upload App Store build
scripts/build/ios/upload.sh -t appstore --submit-for-review  # ...and submit for review
scripts/build/ios/upload.sh --skip-wait-processing           # fire-and-forget (CI friendly)
```

Notes:

- Authentication uses your ASC API key from `.env`; a temporary fastlane key
  file is generated per run with `0600` permissions and deleted afterwards.
- After a TestFlight upload the script waits for Apple processing (~5–30 min);
  skip waiting with `--skip-wait-processing`.
- App Store uploads pass `--skip_metadata --skip_screenshots`, i.e. store
  listing is managed in App Store Connect, not from these scripts.

---

## 6. End-to-end release recipe

```bash
# 0. once: cp scripts/build/.env.example scripts/build/.env (+ secrets)

# 1. Bump version & build both platforms
scripts/build/ios/build.sh      --bump --flavor prod
scripts/build/android/build.sh  --flavor prod --format aab

# 2. Ship
scripts/build/ios/upload.sh     --target testflight       # QA via TestFlight
scripts/build/android/upload.sh --track internal          # QA via internal testing

# 3. Promote after QA
scripts/build/ios/upload.sh     --target appstore --submit-for-review
scripts/build/android/upload.sh --track production
git add pubspec.yaml && git commit -m "chore: bump build number"
```

---

## 7. Troubleshooting

| Symptom | Fix |
|---|---|
| `fastlane is required but not found` | `brew install fastlane` |
| `Service account JSON not found` | Check `ANDROID_PLAY_SERVICE_ACCOUNT_JSON` path in `.env`; file must exist under `scripts/build/.secrets/` |
| Play: `403 accessNotConfigured` / permission denied | Enable *Android Publisher API* in Cloud Console and grant the service account app access in Play Console (§2c) |
| Play: artifact rejected | Ensure you upload the **AAB**, built with release signing (`android/key.properties` present) |
| iOS: `Missing App Store Connect configuration` | Fill `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_FILE` in `.env` |
| iOS: signing/provisioning errors during `flutter build ipa` | Open `ios/Runner.xcworkspace`, select the right team for scheme, enable automatic signing |
| iOS: upload hangs "waiting for processing" | That's normal (5–30 min). Use `--skip-wait-processing` and check App Store Connect manually |
| Release APK/AAB installed but shows wrong backend | Rebuild passing the correct `--flavor`; verify with `--dart-define=APP_FLAVOR=<flavor>` output in logs |

Preview any action without side effects:

```bash
scripts/build/android/build.sh  --dry-run
scripts/build/ios/upload.sh     --dry-run
```
