#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env
require_cmd oc
assert_namespace

if [[ "${APPLY_NETWORK_POLICIES:-false}" != "true" ]]; then
  echo "Refusing to apply staged default-deny policies because APPLY_NETWORK_POLICIES is not true." >&2
  echo "Map DB/SRS/Kafka/ODM/API egress first; then set APPLY_NETWORK_POLICIES=true." >&2
  exit 40
fi

cat <<'WARN'
WARNING: this policy set introduces namespace-wide default deny.
It currently allows same-namespace traffic, OpenShift router ingress and DNS only.
External DB/SRS/Kafka/API endpoints require explicit egress policies before use.
WARN

if [[ "${CONFIRM_NETWORK_POLICY_APPLY:-}" != "yes" ]]; then
  echo "ERROR: set CONFIRM_NETWORK_POLICY_APPLY=yes after reviewing required egress." >&2
  exit 41
fi

oc apply -f "$REPO_ROOT/openshift/crc/networkpolicies-staged.yaml"
oc -n "$PEGA_NAMESPACE" get networkpolicy
