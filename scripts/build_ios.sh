#!/usr/bin/env bash
set -euo pipefail

FLAVOR="${1:-dev}"

if [[ "$FLAVOR" != "dev" && "$FLAVOR" != "prod" ]]; then
  echo "Usage: $0 <dev|prod>"
  exit 1
fi

if [[ "$FLAVOR" == "dev" ]]; then
  FLUTTER_DEFINE="APP_FLAVOR=DEV"
  IPA_NAME="iDeal Mobile Dev.ipa"
else
  FLUTTER_DEFINE="APP_FLAVOR=PROD"
  IPA_NAME="iDeal Mobile.ipa"
fi

echo "Building iOS IPA for ${FLAVOR}..."
flutter build ipa \
  --flavor "$FLAVOR" \
  --dart-define="$FLUTTER_DEFINE" \
  --release \
  --no-tree-shake-icons

IPA_PATH="build/ios/ipa/${IPA_NAME}"
if [[ -f "$IPA_PATH" ]]; then
  echo ""
  echo "Build succeeded: ${IPA_PATH}"
  ls -lh "$IPA_PATH"
else
  echo "ERROR: IPA not found at ${IPA_PATH}"
  exit 1
fi
