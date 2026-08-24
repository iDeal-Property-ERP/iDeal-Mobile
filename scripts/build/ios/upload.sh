#!/usr/bin/env bash
#
# upload.sh — upload a built iOS IPA to TestFlight or the App Store via fastlane.
#
# Usage: scripts/build/ios/upload.sh --help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

TARGET="$(cfg DEFAULT_IOS_TARGET testflight)"
FLAVOR="$(cfg DEFAULT_FLAVOR prod)"
IPA_PATH=""
SUBMIT_FOR_REVIEW=false
SKIP_WAIT=false
BETA_GROUPS=""
CHANGELOG=""
DRY_RUN=0

usage() {
  cat <<EOF
scripts/build/ios/upload.sh — upload an IPA to TestFlight / App Store

Uses fastlane (pilot for TestFlight, deliver for App Store) authenticated
with an App Store Connect API key configured in scripts/build/.env.

USAGE
  scripts/build/ios/upload.sh [OPTIONS]

OPTIONS
  -t, --target <testflight|appstore>  Upload destination (default: ${TARGET})
  -f, --flavor <dev|prod>             Flavor used to auto-detect the IPA and
                                      bundle id (default: ${FLAVOR})
  -i, --ipa <PATH>                    Explicit .ipa path; otherwise:
                                        prod → build/ios/ipa/iDeal Mobile.ipa
                                        dev  → build/ios/ipa/iDeal Mobile Dev.ipa
      --submit-for-review             appstore: submit for review after upload
      --skip-wait-processing          Do not wait for Apple to finish processing
      --beta-groups <"g1,g2">         testflight: distribute to tester groups
      --changelog <FILE|TEXT>         testflight: "What to test" notes
      --dry-run                       Print commands without executing them
  -h, --help                          Show this help

EXAMPLES
  scripts/build/ios/upload.sh                                  # prod IPA → TestFlight
  scripts/build/ios/upload.sh -f dev                           # dev IPA → TestFlight
  scripts/build/ios/upload.sh -f dev --beta-groups "QA Team"   # ...to a tester group
  scripts/build/ios/upload.sh -t appstore                      # App Store build upload
  scripts/build/ios/upload.sh -t appstore --submit-for-review  # also submit for review

REQUIRED CONFIG (scripts/build/.env — see docs/release.md)
  APP_STORE_CONNECT_KEY_ID       API key id (e.g. ABC123XYZ9)
  APP_STORE_CONNECT_ISSUER_ID    API key issuer id (UUID)
  APP_STORE_CONNECT_KEY_FILE     Path to AuthKey_*.p8 (relative to scripts/build/)
EOF
}

need_value() { [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || die "Option $1 requires a value. See --help."; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)     need_value "$@"; TARGET="$2"; shift 2 ;;
    -t=*|--target=*) TARGET="${1#*=}"; shift ;;
    -f|--flavor)     need_value "$@"; FLAVOR="$2"; shift 2 ;;
    -f=*|--flavor=*) FLAVOR="${1#*=}"; shift ;;
    -i|--ipa)        need_value "$@"; IPA_PATH="$2"; shift 2 ;;
    -i=*|--ipa=*)    IPA_PATH="${1#*=}"; shift ;;
    --submit-for-review) SUBMIT_FOR_REVIEW=true; shift ;;
    --skip-wait-processing) SKIP_WAIT=true; shift ;;
    --beta-groups)   need_value "$@"; BETA_GROUPS="$2"; shift 2 ;;
    --beta-groups=*) BETA_GROUPS="${1#*=}"; shift ;;
    --changelog)     need_value "$@"; CHANGELOG="$2"; shift 2 ;;
    --changelog=*)   CHANGELOG="${1#*=}"; shift ;;
    --dry-run)       DRY_RUN=1; export DRY_RUN; shift ;;
    -h|--help)       usage; exit 0 ;;
    *)               die "Unknown option: $1 (see --help)" ;;
  esac
done

[[ "$TARGET" == "testflight" || "$TARGET" == "appstore" ]] || die "Invalid target '$TARGET' (expected testflight or appstore)."
[[ "$FLAVOR" == "dev" || "$FLAVOR" == "prod" ]] || die "Invalid flavor '$FLAVOR' (expected dev or prod)."

load_build_env || warn "No scripts/build/.env found — secrets must come from the environment."

if ! is_dry_run; then
  require_cmd fastlane "brew install fastlane   # or: gem install fastlane"
fi

KEY_ID="$(cfg APP_STORE_CONNECT_KEY_ID "")"
ISSUER_ID="$(cfg APP_STORE_CONNECT_ISSUER_ID "")"
KEY_FILE_CFG="$(cfg APP_STORE_CONNECT_KEY_FILE "")"
KEY_FILE_ABS="$(resolve_build_path "$KEY_FILE_CFG")"

missing_config() {
  local m=()
  [[ -n "$KEY_ID" ]] || m+=("APP_STORE_CONNECT_KEY_ID")
  [[ -n "$ISSUER_ID" ]] || m+=("APP_STORE_CONNECT_ISSUER_ID")
  if [[ -z "$KEY_FILE_CFG" ]]; then
    m+=("APP_STORE_CONNECT_KEY_FILE")
  elif [[ ! -f "$KEY_FILE_ABS" ]]; then
    m+=("APP_STORE_CONNECT_KEY_FILE ($KEY_FILE_ABS not found)")
  fi
  if [[ ${#m[@]} -eq 0 ]]; then
    return 0
  fi
  printf '%s\n' "${m[@]}"
}

MISSING="$(missing_config)"
if [[ -n "$MISSING" ]]; then
  if is_dry_run; then
    warn "Missing ASC config (placeholders will be shown): ${MISSING//$'\n'/, }"
  else
    die "Missing App Store Connect configuration:
$MISSING

Set these in scripts/build/.env — copy scripts/build/.env.example to get started."
  fi
fi

if [[ -z "$IPA_PATH" ]]; then
  if [[ "$FLAVOR" == "dev" ]]; then
    IPA_PATH="$REPO_ROOT/build/ios/ipa/iDeal Mobile Dev.ipa"
  else
    IPA_PATH="$REPO_ROOT/build/ios/ipa/iDeal Mobile.ipa"
  fi
else
  IPA_PATH="$(resolve_build_path "$IPA_PATH" "$PWD")"
fi

if is_dry_run; then
  [[ -f "$IPA_PATH" ]] || warn "IPA not found at $IPA_PATH (continuing dry run)."
elif [[ ! -f "$IPA_PATH" ]]; then
  die "IPA not found at: $IPA_PATH

Build one first:
  scripts/build/ios/build.sh --flavor ${FLAVOR}"
fi

# Changelog may be inline text or a path to a text file.
CHANGELOG_CONTENT="$CHANGELOG"
if [[ -n "$CHANGELOG" && -f "$CHANGELOG" ]]; then
  CHANGELOG_CONTENT="$(cat "$CHANGELOG")"
fi

BUNDLE_ID="$(cfg "IOS_BUNDLE_ID_$(printf '%s' "$FLAVOR" | tr '[:lower:]' '[:upper:]')" "")"
if [[ -z "$BUNDLE_ID" ]]; then
  BUNDLE_ID="com.ideal.mobile"
  if [[ "$FLAVOR" == "dev" ]]; then BUNDLE_ID="com.ideal.mobile.dev"; fi
fi

API_KEY_DIR=""
cleanup_api_key() {
  if [[ -n "$API_KEY_DIR" && -d "$API_KEY_DIR" ]]; then
    rm -rf "$API_KEY_DIR"
  fi
}
trap cleanup_api_key EXIT

make_api_key_json() { # make_api_key_json OUT_FILE
  local out="$1"
  local esc=""
  if [[ -f "$KEY_FILE_ABS" ]]; then
    esc="$(tr -d '\r' < "$KEY_FILE_ABS" | awk '{printf "%s\\n", $0}')"
    esc="${esc%\\n}"
  fi
  cat > "$out" <<EOF
{
  "key_id": "${KEY_ID:-<KEY_ID>}",
  "issuer_id": "${ISSUER_ID:-<ISSUER_ID>}",
  "key": "${esc:-<P8_CONTENT>}",
  "in_house": false
}
EOF
  chmod 600 "$out"
}

HEADER_TITLE="Uploading IPA → ${TARGET}"
if is_dry_run; then HEADER_TITLE+=" (dry run)"; fi
header "$HEADER_TITLE"
log "Target:      ${TARGET}"
log "Flavor:      ${FLAVOR}"
log "Bundle id:   ${BUNDLE_ID}"
log "IPA:         ${IPA_PATH}"
if [[ -n "$CHANGELOG_CONTENT" ]]; then log "Changelog:   ${CHANGELOG_CONTENT}"; fi
if [[ -n "$BETA_GROUPS" ]]; then log "Beta groups: ${BETA_GROUPS}"; fi
log ""

# Print an array as a shell-continuation style multi-line command.
show_cmd() {
  local arr=("$@") i last=$(( ${#arr[@]} - 1 ))
  log "+ ${arr[0]} \\"
  for ((i = 1; i <= last; i++)); do
    if (( i < last )); then
      log "    '${arr[i]}' \\"
    else
      log "    '${arr[i]}'"
    fi
  done
}

if is_dry_run; then
  if [[ "$TARGET" == "testflight" ]]; then
    CMD=(fastlane pilot upload --api_key_path '<asc-api-key.json>' --ipa "$IPA_PATH")
    if [[ -n "$CHANGELOG_CONTENT" ]]; then CMD+=(--changelog "$CHANGELOG_CONTENT"); fi
    if [[ -n "$BETA_GROUPS" ]]; then CMD+=(--groups "$BETA_GROUPS"); fi
    if [[ "$SKIP_WAIT" == true ]]; then
      CMD+=(--skip_waiting_for_build_processing)
    else
      CMD+=(--wait_processing_interval 60)
    fi
  else
    CMD=(fastlane deliver --api_key_path '<asc-api-key.json>' --ipa "$IPA_PATH"
         --app_identifier "$BUNDLE_ID" --skip_metadata --skip_screenshots --force)
    if [[ "$SUBMIT_FOR_REVIEW" == true ]]; then CMD+=(--submit_for_review); fi
    if [[ "$SKIP_WAIT" == true ]]; then CMD+=(--wait_for_build_processing_to_be_complete false); fi
  fi
  show_cmd "${CMD[@]}"
  ok "Dry run complete."
  exit 0
fi

# Private temp dir for the fastlane API-key JSON (removed on exit).
API_KEY_DIR="$(mktemp -d "${TMPDIR:-/tmp}/asc-api-key.XXXXXX")"
API_KEY_JSON="$API_KEY_DIR/api-key.json"
make_api_key_json "$API_KEY_JSON"

if [[ "$TARGET" == "testflight" ]]; then
  PILOT_ARGS=(upload
    --api_key_path "$API_KEY_JSON"
    --ipa "$IPA_PATH"
    --wait_processing_interval 60)
  if [[ -n "$CHANGELOG_CONTENT" ]]; then PILOT_ARGS+=(--changelog "$CHANGELOG_CONTENT"); fi
  if [[ -n "$BETA_GROUPS" ]]; then PILOT_ARGS+=(--groups "$BETA_GROUPS"); fi
  if [[ "$SKIP_WAIT" == true ]]; then PILOT_ARGS+=(--skip_waiting_for_build_processing); fi

  fastlane pilot "${PILOT_ARGS[@]}"

  header "Upload complete"
  info "Track processing: https://appstoreconnect.apple.com → TestFlight"
else
  DELIVER_ARGS=(--api_key_path "$API_KEY_JSON"
    --ipa "$IPA_PATH"
    --app_identifier "$BUNDLE_ID"
    --skip_metadata
    --skip_screenshots
    --force)
  if [[ "$SUBMIT_FOR_REVIEW" == true ]]; then DELIVER_ARGS+=(--submit_for_review); fi
  if [[ "$SKIP_WAIT" == true ]]; then DELIVER_ARGS+=(--wait_for_build_processing_to_be_complete false); fi

  fastlane deliver "${DELIVER_ARGS[@]}"

  header "Upload complete"
  info "Check status: https://appstoreconnect.apple.com → My Apps"
fi
