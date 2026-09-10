#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

load_env() {
  if [[ -f "$REPO_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.env"
    set +a
  fi
  if [[ -f "$REPO_ROOT/.generated/credentials.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$REPO_ROOT/.generated/credentials.env"
    set +a
  fi
  : "${PEGA_NAMESPACE:=mayabank-pega}"
  : "${PEGA_RELEASE:=mayabank-pega}"
  : "${PEGA_HELM_CHART:=pega/pega}"
  : "${PEGA_IMAGE_PULL_SECRET:=pega-registry}"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: required command not found: $1" >&2
    exit 2
  }
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: required environment variable is empty: $name" >&2
    exit 3
  fi
}

ensure_generated_dir() {
  mkdir -p "$REPO_ROOT/.generated"
  chmod 700 "$REPO_ROOT/.generated" 2>/dev/null || true
}

now_utc() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

raw_evidence_dir() {
  local stamp
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  local dir="$REPO_ROOT/evidence/runtime/raw/$stamp"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

assert_namespace() {
  oc get namespace "$PEGA_NAMESPACE" >/dev/null 2>&1 || {
    echo "ERROR: namespace $PEGA_NAMESPACE does not exist" >&2
    exit 4
  }
}

helm_version_args() {
  if [[ -n "${PEGA_HELM_CHART_VERSION:-}" ]]; then
    printf '%s\n' "--version" "$PEGA_HELM_CHART_VERSION"
  fi
}
