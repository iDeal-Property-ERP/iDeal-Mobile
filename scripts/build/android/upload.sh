#!/usr/bin/env bash
#
# upload.sh — upload a built Android artifact to Google Play via fastlane supply.
#
# Usage: scripts/build/android/upload.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

FLAVOR="$(cfg DEFAULT_FLAVOR prod)"
TRACK="$(cfg DEFAULT_PLAY_TRACK internal)"
ARTIFACT=""
PACKAGE_NAME=""
RELEASE_STATUS="completed"
DRY_RUN=0

STANDARD_TRACKS="internal alpha beta production"
VALID_STATUSES="completed draft halted inProgress"

usage() {
  cat <<EOF
scripts/build/android/upload.sh — upload an Android build to Google Play

Uses 'fastlane supply' with a Play service-account JSON key.

USAGE
  scripts/build/android/upload.sh [OPTIONS]

OPTIONS
  -f, --flavor <dev|prod>        Which flavor's artifact to pick by default
                                 (default: ${FLAVOR})
  -t, --track <name>             Play track (default: ${TRACK})
                                 Standard tracks: ${STANDARD_TRACKS}
  -a, --artifact <PATH>          Explicit .aab/.apk path; auto-detects newest
                                 for the flavor when omitted (AAB preferred)
  -p, --package-name <ID>        Application ID (default from scripts/build/.env)
      --release-status <STATUS>  completed|draft|halted|inProgress
                                 (default: ${RELEASE_STATUS}; use 'draft' to review
                                 in Play Console before publishing)
      --dry-run                  Print the command without executing it
  -h, --help                     Show this help

EXAMPLES
  scripts/build/android/upload.sh                          # newest prod AAB → internal track
  scripts/build/android/upload.sh -t production            # prod AAB → production
  scripts/build/android/upload.sh -t beta --release-status draft
  scripts/build/android/upload.sh -a path/to/app.aab       # explicit artifact

NOTES
  • Requires fastlane:   brew install fastlane   (or: gem install fastlane)
  • Requires a service-account JSON configured in scripts/build/.env
    (ANDROID_PLAY_SERVICE_ACCOUNT_JSON) — see docs/release.md.
  • The dev package id usually does not exist in Play Console —
    uploads are typically done with the prod flavor.
EOF
}

need_value() { [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || die "Option $1 requires a value. See --help."; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--flavor)         need_value "$@"; FLAVOR="$2"; shift 2 ;;
    -f=*|--flavor=*)     FLAVOR="${1#*=}"; shift ;;
    -t|--track)          need_value "$@"; TRACK="$2"; shift 2 ;;
    -t=*|--track=*)      TRACK="${1#*=}"; shift ;;
    -a|--artifact)       need_value "$@"; ARTIFACT="$2"; shift 2 ;;
    -a=*|--artifact=*)   ARTIFACT="${1#*=}"; shift ;;
    -p|--package-name)   need_value "$@"; PACKAGE_NAME="$2"; shift 2 ;;
    -p=*|--package-name=*) PACKAGE_NAME="${1#*=}"; shift ;;
    --release-status)    need_value "$@"; RELEASE_STATUS="$2"; shift 2 ;;
    --release-status=*)  RELEASE_STATUS="${1#*=}"; shift ;;
    --dry-run)           DRY_RUN=1; export DRY_RUN; shift ;;
    -h|--help)           usage; exit 0 ;;
    *)                   die "Unknown option: $1 (see --help)" ;;
  esac
done

[[ "$FLAVOR" == "dev" || "$FLAVOR" == "prod" ]] || die "Invalid flavor '$FLAVOR' (expected dev or prod)."
[[ -n "$RELEASE_STATUS" && " $VALID_STATUSES " == *" $RELEASE_STATUS "* ]] \
  || die "Invalid release status '$RELEASE_STATUS' (expected one of: $VALID_STATUSES)."
[[ "$TRACK" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid track '$TRACK'."

if [[ " $STANDARD_TRACKS " != *" $TRACK "* ]]; then
  warn "'$TRACK' is not a standard Play track ($STANDARD_TRACKS) — assuming a custom closed track."
fi

load_build_env || warn "No scripts/build/.env found — secrets must come from the environment."

if ! is_dry_run; then
  require_cmd fastlane "brew install fastlane   # or: gem install fastlane"
fi

if [[ -z "$PACKAGE_NAME" ]]; then
  PACKAGE_NAME="$(cfg "ANDROID_PACKAGE_NAME_$(printf '%s' "$FLAVOR" | tr '[:lower:]' '[:upper:]')" "")"
  if [[ -z "$PACKAGE_NAME" ]]; then
    PACKAGE_NAME="com.ideal.uz"
    if [[ "$FLAVOR" == "dev" ]]; then PACKAGE_NAME="com.ideal.uz.dev"; fi
  fi
fi

KEY_JSON_CFG="$(cfg ANDROID_PLAY_SERVICE_ACCOUNT_JSON ".secrets/android/play-service-account.json")"
KEY_JSON_ABS="$(resolve_build_path "$KEY_JSON_CFG")"

if is_dry_run; then
  [[ -f "$KEY_JSON_ABS" ]] || KEY_JSON_ABS="<MISSING:$KEY_JSON_CFG>"
else
  [[ -f "$KEY_JSON_ABS" ]] || die "Service account JSON not found: $KEY_JSON_ABS
Configure it via ANDROID_PLAY_SERVICE_ACCOUNT_JSON in scripts/build/.env (see docs/release.md)."
fi

if [[ -z "$ARTIFACT" ]]; then
  BUNDLE_DIR="$REPO_ROOT/build/app/outputs/bundle/${FLAVOR}Release"
  ARTIFACT="$(newest_file "$BUNDLE_DIR" "app-${FLAVOR}-release.aab")"
  if [[ -z "$ARTIFACT" ]]; then
    APK_DIR="$REPO_ROOT/build/app/outputs/flutter-apk"
    APK_MATCHES=("$APK_DIR"/app-*-${FLAVOR}-release.apk)
    if [[ ${#APK_MATCHES[@]} -gt 1 ]]; then
      die "Multiple split APKs found for '${FLAVOR}' — Google Play expects one artifact.
Pass one explicitly with --artifact, or build an AAB instead:
  scripts/build/android/build.sh --flavor ${FLAVOR} --format aab"
    fi
    ARTIFACT="$(newest_file "$APK_DIR" "app-*-${FLAVOR}-release.apk")"
  fi
  [[ -n "$ARTIFACT" ]] || die "No built artifact found for flavor '${FLAVOR}'.
Build one first:
  scripts/build/android/build.sh --flavor ${FLAVOR}"
else
  ARTIFACT="$(resolve_build_path "$ARTIFACT" "$PWD")"
  [[ -f "$ARTIFACT" ]] || die "Artifact not found: $ARTIFACT"
fi

case "$ARTIFACT" in
  *.aab) ARTIFACT_FLAG=(--aab "$ARTIFACT") ;;
  *.apk) ARTIFACT_FLAG=(--apk "$ARTIFACT") ;;
  *)     die "Unsupported artifact type (expected .aab or .apk): $ARTIFACT" ;;
esac

HEADER_TITLE="Uploading to Google Play"
if is_dry_run; then HEADER_TITLE+=" (dry run)"; fi
header "$HEADER_TITLE"
log "Package:       ${PACKAGE_NAME}"
log "Track:         ${TRACK}"
log "Rel. status:   ${RELEASE_STATUS}"
log "Service acct:  ${KEY_JSON_ABS}"
log "Artifact:      ${ARTIFACT}"
log ""

if is_dry_run; then
  log "+ fastlane supply --package_name ${PACKAGE_NAME} \\"
  log "      --json_key ${KEY_JSON_ABS} \\"
  log "      ${ARTIFACT_FLAG[*]} \\"
  log "      --track ${TRACK} --release_status ${RELEASE_STATUS}"
  ok "Dry run complete."
else
  fastlane supply \
    --package_name "$PACKAGE_NAME" \
    --json_key "$KEY_JSON_ABS" \
    "${ARTIFACT_FLAG[@]}" \
    --track "$TRACK" \
    --release_status "$RELEASE_STATUS"
  header "Upload complete"
  info "Track rollout status: https://play.google.com/console → ${PACKAGE_NAME} → ${TRACK}"
fi
