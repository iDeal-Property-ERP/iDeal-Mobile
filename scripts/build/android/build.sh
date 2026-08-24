#!/usr/bin/env bash
#
# build.sh — build Android packages (AAB and/or APK) for a given flavor.
#
# Usage: scripts/build/android/build.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

FLAVOR="$(cfg DEFAULT_FLAVOR prod)"
FORMAT="$(cfg DEFAULT_ANDROID_FORMAT aab)"
BUMP=false
BUILD_NAME=""
BUILD_NUMBER=""
CLEAN=false
DRY_RUN=0

usage() {
  cat <<EOF
scripts/build/android/build.sh — build the Android app

USAGE
  scripts/build/android/build.sh [OPTIONS]

OPTIONS
  -f, --flavor <dev|prod>     Build flavor (default: ${FLAVOR})
  -t, --format <aab|apk|both> Output format; 'apk' produces split-per-ABI APKs
                              (default: ${FORMAT})
      --bump                  Increment build number in pubspec.yaml before building
      --build-number <N>      Use this build number without editing pubspec.yaml
      --build-name <X.Y.Z>    Use this version name without editing pubspec.yaml
  -c, --clean                 Run 'flutter clean' first
      --dry-run               Print the commands without executing them
  -h, --help                  Show this help

EXAMPLES
  scripts/build/android/build.sh                       # prod AAB
  scripts/build/android/build.sh -f dev -t both        # dev AAB + split APKs
  scripts/build/android/build.sh --bump                # bump version, then prod AAB
  scripts/build/android/build.sh --build-number 42     # fixed build number

ARTIFACTS
  AAB → build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab
  APK → build/app/outputs/flutter-apk/app-<abi>-<flavor>-release.apk
EOF
}

need_value() { [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || die "Option $1 requires a value. See --help."; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--flavor)       need_value "$@"; FLAVOR="$2"; shift 2 ;;
    -f=*|--flavor=*)   FLAVOR="${1#*=}"; shift ;;
    -t|--format)       need_value "$@"; FORMAT="$2"; shift 2 ;;
    -t=*|--format=*)   FORMAT="${1#*=}"; shift ;;
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
[[ "$FORMAT" == "aab" || "$FORMAT" == "apk" || "$FORMAT" == "both" ]] || die "Invalid format '$FORMAT' (expected aab, apk, or both)."
[[ -z "$BUILD_NUMBER" || "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || die "--build-number must be an integer."

load_build_env || warn "No scripts/build/.env found — using built-in defaults (fine for builds; required for uploads)."

if [[ "$BUMP" == true ]]; then
  is_dry_run && log "+ would bump build number in pubspec.yaml" || bump_build_number
fi

VERSION_NAME="${BUILD_NAME:-$(version_name)}"
VERSION_CODE="${BUILD_NUMBER:-$(version_code)}"
is_dry_run || sync_local_properties "$VERSION_NAME" "$VERSION_CODE"
resolve_java_home

FORMAT_UC="$(printf '%s' "$FORMAT" | tr '[:lower:]' '[:upper:]')"
header "Building Android ${FORMAT_UC} for '${FLAVOR}' flavor"
log "Version:    ${VERSION_NAME}"
log "Build code: ${VERSION_CODE}"
[[ -n "${JAVA_HOME:-}" ]] && log "Java home:  ${JAVA_HOME}"
log ""

KEY_PROPERTIES="$ANDROID_DIR/key.properties"
if [[ ! -f "$KEY_PROPERTIES" ]]; then
  warn "android/key.properties not found — release builds will fall back to DEBUG signing!"
  warn "Play Store uploads require release signing. See docs/release.md."
fi

if [[ "$CLEAN" == true ]]; then
  info "Running flutter clean..."
  run_or_echo flutter clean
fi

DART_DEF_B64="$(printf "APP_FLAVOR=%s" "$FLAVOR" | base64 | tr -d '\n')"

if [[ "$FORMAT" == "aab" || "$FORMAT" == "both" ]]; then
  if [[ "$FLAVOR" == "dev" ]]; then GRADLE_TASK="bundleDevRelease"; else GRADLE_TASK="bundleProdRelease"; fi
  info "Packaging AAB with Gradle task: ${GRADLE_TASK}..."
  if is_dry_run; then
    log "+ (cd android && JAVA_HOME=${JAVA_HOME:-<PATH>} ./gradlew ${GRADLE_TASK} \\"
    log "      -Pdart-defines=${DART_DEF_B64} -Pbuild-name=${VERSION_NAME} -Pbuild-number=${VERSION_CODE})"
  else
    (
      cd "$ANDROID_DIR"
      JAVA_HOME="${JAVA_HOME:-}" ./gradlew "$GRADLE_TASK" \
        "-Pdart-defines=$DART_DEF_B64" \
        "-Pbuild-name=$VERSION_NAME" \
        "-Pbuild-number=$VERSION_CODE"
    )
  fi
  AAB_PATH="build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab"
fi

if [[ "$FORMAT" == "apk" || "$FORMAT" == "both" ]]; then
  info "Building split-per-ABI APKs with Flutter..."
  run_or_echo flutter build apk \
    --flavor "$FLAVOR" \
    --release \
    --dart-define="APP_FLAVOR=${FLAVOR}" \
    --build-name="$VERSION_NAME" \
    --build-number="$VERSION_CODE" \
    --split-per-abi
fi

header "Build succeeded"
[[ -n "${AAB_PATH:-}" ]] && { ok "AAB: $REPO_ROOT/$AAB_PATH"; ls -lh "$AAB_PATH" 2>/dev/null || true; }
if [[ "$FORMAT" == "apk" || "$FORMAT" == "both" ]]; then
  for apk in build/app/outputs/flutter-apk/app-*-${FLAVOR}-release.apk; do
    [[ -e "$apk" ]] && { ok "APK: $REPO_ROOT/$apk"; ls -lh "$apk" | awk '{print "     " $5 "  " $9}'; }
  done
fi

if is_dry_run; then
  info "Dry run complete — nothing was built."
else
  info "Next step:"
  log "  scripts/build/android/upload.sh --flavor ${FLAVOR} --track <internal|alpha|beta|production>"
fi
