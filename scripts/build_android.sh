#!/usr/bin/env bash
set -euo pipefail

FLAVOR="${1:-prod}"
FORMAT="${2:-aab}"

if [[ "$FLAVOR" != "dev" && "$FLAVOR" != "prod" ]]; then
  echo "Usage: $0 <dev|prod> [aab|apk] [--bump]"
  exit 1
fi

if [[ "$FORMAT" != "aab" && "$FORMAT" != "apk" ]]; then
  echo "Usage: $0 <dev|prod> [aab|apk] [--bump]"
  exit 1
fi

BUMP=false
for arg in "$@"; do
  if [[ "$arg" == "--bump" ]]; then
    BUMP=true
  fi
done

# Increment build number in pubspec.yaml if --bump passed
if [[ "$BUMP" == "true" ]]; then
  CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
  VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
  BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)
  NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
  sed -i "s/^version: .*/version: ${VERSION_NAME}+${NEW_BUILD_NUMBER}/" pubspec.yaml
  echo "Bumped version in pubspec.yaml to ${VERSION_NAME}+${NEW_BUILD_NUMBER}"
fi

CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [[ -f "android/local.properties" ]]; then
  sed -i "s/^flutter.versionCode=.*/flutter.versionCode=${BUILD_NUMBER}/" android/local.properties || true
  sed -i "s/^flutter.versionName=.*/flutter.versionName=${VERSION_NAME}/" android/local.properties || true
fi

export JAVA_HOME="${JAVA_HOME:-/opt/android-studio/jbr}"

echo "=================================================="
echo " Building Android ${FORMAT^^} for ${FLAVOR} flavor"
echo " Version: ${VERSION_NAME} (code: ${BUILD_NUMBER})"
echo " Target Base URL Flavor: ${FLAVOR}"
echo "=================================================="

if [[ "$FORMAT" == "aab" ]]; then
  DART_DEF_B64=$(printf "APP_FLAVOR=%s" "$FLAVOR" | base64 | tr -d '\n')
  GRADLE_TASK="bundle${FLAVOR^}Release"
  echo "Packaging bundle with Gradle task: ${GRADLE_TASK}..."
  (cd android && JAVA_HOME="$JAVA_HOME" ./gradlew "$GRADLE_TASK" \
    -Pdart-defines="$DART_DEF_B64" \
    -Pbuild-name="$VERSION_NAME" \
    -Pbuild-number="$BUILD_NUMBER")

  AAB_PATH="build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab"
  echo ""
  echo "=================================================="
  echo " Build succeeded!"
  echo " Artifact: ${AAB_PATH}"
  ls -lh "$AAB_PATH"
  echo "=================================================="
else
  JAVA_HOME="$JAVA_HOME" flutter build apk \
    --flavor "$FLAVOR" \
    --release \
    --dart-define="APP_FLAVOR=${FLAVOR}" \
    --build-name="$VERSION_NAME" \
    --build-number="$BUILD_NUMBER" \
    --split-per-abi

  echo ""
  echo "=================================================="
  echo " Build succeeded!"
  ls -lh build/app/outputs/flutter-apk/app-*-${FLAVOR}-release.apk
  echo "=================================================="
fi
