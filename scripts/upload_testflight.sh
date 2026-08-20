#!/usr/bin/env bash
set -euo pipefail

# TestFlight upload config (dev flavor)
API_KEY="${APP_STORE_CONNECT_API_KEY:-38H8YDNBA8}"
API_ISSUER="${APP_STORE_CONNECT_API_ISSUER:-c85394ea-ada2-476e-81c1-136397f411b4}"
IPA_PATH="build/ios/ipa/iDeal Mobile Dev.ipa"

if [[ ! -f "$IPA_PATH" ]]; then
  echo "IPA not found at ${IPA_PATH}"
  echo "Run: ./scripts/build_ios.sh dev"
  exit 1
fi

echo "Uploading to TestFlight..."
echo "IPA: ${IPA_PATH}"
echo ""

xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  --apiKey "$API_KEY" \
  --apiIssuer "$API_ISSUER"

echo ""
echo "Upload complete. Processing takes ~5-30 min."
echo "Check: https://appstoreconnect.apple.com → TestFlight tab"
