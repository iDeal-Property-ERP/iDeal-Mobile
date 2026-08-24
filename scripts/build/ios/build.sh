#!/usr/bin/env bash
#
# build.sh — build an iOS IPA for a given flavor/scheme.
#
# Usage: scripts/build/ios/build.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

FLAVOR="$(cfg DEFAULT_FLAVOR prod)"
EXPORT_METHOD="app-store"
BUMP=false
BUILD_NAME=""
BUILD_NUMBER=""
CLEAN=false
DRY_RUN=0

VALID_METHODS="app-store ad-hoc app-store-connect development enterprise"

usage() {
  cat <<EOF
scripts/build/ios/build.sh — build the iOS app (.ipa)

USAGE
  scripts/build/ios/build.sh [OPTIONS]

OPTIONS
  -f, --flavor <dev|prod>       Flavor / Xcode scheme (default: ${FLAVOR})
  -m, --export-method <METHOD>  Distribution method (default: ${EXPORT_METHOD})
                                One of: ${VALID_METHODS}
      --bump                    Increment build number in pubspec.yaml first
      --build-number <N>        Use this build number without editing pubspec.yaml
      --build-name <X.Y.Z>      Use this version name without editing pubspec.yaml
  -c, --clean                   Run 'flutter clean' first
      --dry-run                 Print the command without executing it
  -h, --help                    Show this help

EXAMPLES
  scripts/build/ios/build.sh                        # prod IPA (App Store)
  scripts/build/ios/build.sh -f dev                 # dev IPA for TestFlight
  scripts/build/ios/build.sh --bump -f prod         # bump, then build prod
  scripts/build/ios/build.sh -m ad-hoc              # ad-hoc distribution IPA

ARTIFACT
  build/ios/ipa/iDeal Mobile.ipa        (prod)
  build/ios/ipa/iDeal Mobile Dev.ipa    (dev)

NOTES
  • Requires Xcode signing configured (team + provisioning) — see docs/release.md.
  • Upload afterwards with: scripts/build/ios/upload.sh --target testflight|appstore
EOF
}

need_value() { [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || die "Option $1 requires a value. See --help."; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--flavor)       need_value "$@"; FLAVOR="$2"; shift 2 ;;
    -f=*|--flavor=*)   FLAVOR="${1#*=}"; shift ;;
    -m|--export-method) need_value "$@"; EXPORT_METHOD="$2"; shift 2 ;;
    -m=*|--export-method=*) EXPORT_METHOD="${1#*=}"; shift ;;
    --bump)            BUMP=true; shift ;;
    --build-number)    need_value "$@"; BUILD_NUMBER="$2"; shift 2 ;;
    --build-number=*)  BUILD_NUMBER="${1#*=}"; shift ;;
    --build-name)      need_value "$@"; BUILD_NAME="$2"; shift 2 ;;
    --build-name=*)    BUILD_NAME="${1#*=}"; shift ;;
    -c|--clean)        CLEAN=true; shift ;;
    --dry-run)         DRY_RUN=1; export DRY_RUN; shift ;;
    -h|--help)         usage; exit 0 ;;
    *)                 die "Unknown option: $1 (see --help)" ;;
  esac
done

[[ "$FLAVOR" == "dev" || "$FLAVOR" == "prod" ]] || die "Invalid flavor '$FLAVOR' (expected dev or prod)."
[[ " $VALID_METHODS " == *" $EXPORT_METHOD "* ]] || die "Invalid export method '$EXPORT_METHOD' (expected one of: $VALID_METHODS)."
[[ -z "$BUILD_NUMBER" || "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || die "--build-number must be an integer."

load_build_env || warn "No scripts/build/.env found — using built-in defaults (fine for builds; required for uploads)."

if [[ "$BUMP" == true ]]; then
  is_dry_run && log "+ would bump build number in pubspec.yaml" || bump_build_number
fi

VERSION_NAME="${BUILD_NAME:-$(version_name)}"
VERSION_CODE="${BUILD_NUMBER:-$(version_code)}"

if [[ "$FLAVOR" == "dev" ]]; then
  IPA_PATH="$REPO_ROOT/build/ios/ipa/iDeal Mobile Dev.ipa"
else
  IPA_PATH="$REPO_ROOT/build/ios/ipa/iDeal Mobile.ipa"
fi

header "Building iOS IPA for '${FLAVOR}' flavor"
log "Version:        ${VERSION_NAME}"
log "Build code:     ${VERSION_CODE}"
log "Export method:  ${EXPORT_METHOD}"
log "Expected IPA:   ${IPA_PATH}"
log ""

if [[ "$CLEAN" == true ]]; then
  info "Running flutter clean..."
  run_or_echo flutter clean
fi

info "Building archive and exporting IPA..."
run_or_echo flutter build ipa \
  --flavor "$FLAVOR" \
  --dart-define="APP_FLAVOR=${FLAVOR}" \
  --export-method "$EXPORT_METHOD" \
  --build-name="$VERSION_NAME" \
  --build-number="$VERSION_CODE" \
  --release \
  --no-tree-shake-icons

if is_dry_run; then
  header "Dry run complete"
  info "Nothing was built."
else
  if [[ -f "$IPA_PATH" ]]; then
    header "Build succeeded"
    ok "IPA: $IPA_PATH"
    ls -lh "$IPA_PATH" | awk '{print "     " $5}'
  else
    FOUND="$(newest_file "$REPO_ROOT/build/ios/ipa" "*.ipa")"
    if [[ -n "$FOUND" ]]; then
      warn "Expected IPA not found, but found: $FOUND"
      ok "Using: $FOUND"
    else
      die "No IPA found under build/ios/ipa/. Check signing settings (see docs/release.md)."
    fi
  fi
  info "Next step:"
  log "  scripts/build/ios/upload.sh --flavor ${FLAVOR} --target testflight"
fi
