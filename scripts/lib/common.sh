#!/usr/bin/env bash
#
# common.sh — shared helpers for iDeal Mobile build/upload scripts.
#
# Source at the top of every script in scripts/build/<platform>/:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/../../lib/common.sh"
#
# Conventions:
#   • DRY_RUN=1 (exported by scripts) → run_or_echo prints instead of executing.
#   • Paths from scripts/build/.env are resolved relative to scripts/build/.

# ── Paths ────────────────────────────────────────────────────────────────────
COMMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$COMMON_LIB_DIR/../.." && pwd)"
BUILD_SCRIPTS_DIR="$REPO_ROOT/scripts/build"
BUILD_ENV_FILE="${IDEAL_BUILD_ENV:-$BUILD_SCRIPTS_DIR/.env}"
PUBSPEC_FILE="${IDEAL_PUBSPEC:-$REPO_ROOT/pubspec.yaml}"
ANDROID_DIR="$REPO_ROOT/android"
IOS_DIR="$REPO_ROOT/ios"

# ── Logging ──────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_CYAN=$'\033[36m'
else
  C_RESET=""; C_BOLD=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_CYAN=""
fi

log()  { printf '%s\n' "$*"; }
info() { printf '%s\n' "${C_BOLD}${C_CYAN}==> ${C_RESET}$*"; }
ok()   { printf '%s\n' "${C_GREEN}✔${C_RESET} $*"; }
warn() { printf '%s\n' "${C_YELLOW}⚠${C_RESET} $*" >&2; }
die()  { printf '%s\n' "${C_RED}✖ $*${C_RESET}" >&2; exit 1; }

header() {
  log ""
  log "${C_BOLD}${C_CYAN}==================================================${C_RESET}"
  log " $1"
  log "${C_BOLD}${C_CYAN}==================================================${C_RESET}"
}

require_cmd() {
  local cmd="$1" hint="${2:-}"
  command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not found.${hint:+ Install it with: $hint}"
}

is_dry_run() { [[ "${DRY_RUN:-0}" == "1" ]]; }

# Execute the given command, or just print it when DRY_RUN=1.
run_or_echo() {
  if is_dry_run; then
    log "+ $*"
  else
    "$@"
  fi
}

# ── Config loading ───────────────────────────────────────────────────────────
load_build_env() {
  [[ -f "$BUILD_ENV_FILE" ]] || return 1
  set -a
  # shellcheck disable=SC1090
  source "$BUILD_ENV_FILE"
  set +a
}

# Resolve a path from .env: absolute stays, ~ expands, otherwise relative to scripts/build/.
resolve_build_path() {
  local p="$1" base="${2:-$BUILD_SCRIPTS_DIR}"
  case "$p" in
    "")     return ;;
    "~"*)   printf '%s' "${p/#\~/$HOME}" ;;
    /*)     printf '%s' "$p" ;;
    *)      printf '%s' "$base/$p" ;;
  esac
}

cfg() { # cfg VAR_NAME DEFAULT — print value of var if non-empty else default
  local var="$1" default="$2"
  local val="${!var:-}"
  printf '%s' "${val:-$default}"
}

# ── Version handling (pubspec.yaml is the single source of truth) ───────────
pubspec_version_raw() {
  grep -E '^version:' "$PUBSPEC_FILE" | head -n1 | sed 's/^version:[[:space:]]*//' | tr -d '[:space:]'
}

version_name() {
  local raw; raw="$(pubspec_version_raw)"
  printf '%s' "${raw%%+*}"
}

version_code() {
  local raw; raw="$(pubspec_version_raw)"
  if [[ "$raw" == *+* ]]; then printf '%s' "${raw##*+}"; else printf '0'; fi
}

# Portable in-place sed (BSD/macOS needs -i '', GNU/busybox takes no suffix).
sed_inplace() { # sed_inplace SED_EXPR FILE
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "$1" "$2"
  else
    sed -i "$1" "$2"
  fi
}

bump_build_number() {
  local raw name code next
  raw="$(pubspec_version_raw)"
  name="${raw%%+*}"
  code="$(version_code)"
  next=$((code + 1))
  sed_inplace "s|^version:[[:space:]].*|version: ${name}+${next}|" "$PUBSPEC_FILE"
  log "Bumped build number in pubspec.yaml: ${name}+${code} → ${name}+${next}"
}

sync_local_properties() { # sync_local_properties VERSION_NAME BUILD_CODE
  local f="$ANDROID_DIR/local.properties"
  [[ -f "$f" ]] || return 0
  if grep -q '^flutter.versionName=' "$f"; then
    sed_inplace "s|^flutter.versionName=.*|flutter.versionName=$1|" "$f"
  else
    printf 'flutter.versionName=%s\n' "$1" >> "$f"
  fi
  if grep -q '^flutter.versionCode=' "$f"; then
    sed_inplace "s|^flutter.versionCode=.*|flutter.versionCode=$2|" "$f"
  else
    printf 'flutter.versionCode=%s\n' "$2" >> "$f"
  fi
}

resolve_java_home() {
  local candidate
  if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
    return 0
  fi
  for candidate in \
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
    "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home" \
    "$HOME/Library/Java/JavaVirtualMachines/jbr/Contents/Home" \
    "/opt/android-studio/jbr" \
    "/snap/android-studio/current/android-studio/jbr" \
    "/usr/lib/jvm/default-java" \
    "/usr/lib/jvm/java-17-openjdk-amd64"; do
    if [[ -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      return 0
    fi
  done
}

# Print the newest file matching a glob pattern, or nothing.
newest_file() { # newest_file DIR PATTERN
  ls -t "$1"/$2 2>/dev/null | head -n1 || true
}
