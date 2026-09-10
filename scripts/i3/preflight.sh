#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd crc
require_cmd oc
require_cmd helm
require_cmd git
require_cmd curl

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN=python
else
  echo "ERROR: python3/python is required for strict template rendering" >&2
  exit 2
fi

EVIDENCE_DIR="$(raw_evidence_dir)"
echo "I3 preflight — $(now_utc)" | tee "$EVIDENCE_DIR/preflight.txt"

echo "== Tool versions ==" | tee -a "$EVIDENCE_DIR/preflight.txt"
crc version 2>&1 | tee "$EVIDENCE_DIR/crc-version.txt"
oc version 2>&1 | tee "$EVIDENCE_DIR/oc-version.txt"
helm version 2>&1 | tee "$EVIDENCE_DIR/helm-version.txt"
git --version 2>&1 | tee "$EVIDENCE_DIR/git-version.txt"
"$PYTHON_BIN" --version 2>&1 | tee "$EVIDENCE_DIR/python-version.txt"

echo "== CRC status =="
CRC_STATUS="$(crc status 2>&1 || true)"
printf '%s\n' "$CRC_STATUS" | tee "$EVIDENCE_DIR/crc-status.txt"
if ! printf '%s\n' "$CRC_STATUS" | grep -qi "Running"; then
  echo "ERROR: CRC does not appear to be running. Start it before I3 runtime deployment." >&2
  exit 10
fi

echo "== OpenShift identity / cluster =="
oc whoami | tee "$EVIDENCE_DIR/whoami.txt"
oc get clusterversion -o wide | tee "$EVIDENCE_DIR/clusterversion.txt"
oc get nodes -o wide | tee "$EVIDENCE_DIR/nodes.txt"
oc get nodes -o json > "$EVIDENCE_DIR/nodes.json"
oc get storageclass -o wide | tee "$EVIDENCE_DIR/storageclasses.txt"
oc get ingresses.config/cluster -o json > "$EVIDENCE_DIR/ingress-config.json"

APPS_DOMAIN="$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')"
if [[ -z "${PEGA_ROUTE_HOST:-}" ]]; then
  export PEGA_ROUTE_HOST="pega.${APPS_DOMAIN}"
fi
printf 'APPS_DOMAIN=%s\nPEGA_ROUTE_HOST=%s\n' "$APPS_DOMAIN" "$PEGA_ROUTE_HOST" | tee "$EVIDENCE_DIR/routes-domain.txt"

echo "== Authorization =="
if ! oc auth can-i create namespaces | grep -qi '^yes$'; then
  if ! oc get namespace "$PEGA_NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: cannot create namespaces and $PEGA_NAMESPACE does not exist" >&2
    exit 11
  fi
fi

for resource in resourcequotas limitranges serviceaccounts roles rolebindings networkpolicies; do
  result="$(oc auth can-i create "$resource" -n "$PEGA_NAMESPACE" 2>/dev/null || true)"
  printf '%-25s %s\n' "$resource" "$result" | tee -a "$EVIDENCE_DIR/auth-can-i.txt"
done

echo "== Pega public Helm repository =="
helm repo add pega https://pegasystems.github.io/pega-helm-charts --force-update >/dev/null
helm repo update pega >/dev/null
helm search repo pega --versions | tee "$EVIDENCE_DIR/pega-helm-versions.txt"
CHART_ARGS=()
if [[ -n "${PEGA_HELM_CHART_VERSION:-}" ]]; then
  CHART_ARGS+=(--version "$PEGA_HELM_CHART_VERSION")
fi
helm show chart "$PEGA_HELM_CHART" "${CHART_ARGS[@]}" | tee "$EVIDENCE_DIR/pega-chart.txt"

echo "== Required non-secret runtime metadata =="
require_env PEGA_WEB_IMAGE
require_env PEGA_INSTALLER_IMAGE
require_env PEGA_CLUSTERING_SERVICE_IMAGE
require_env PEGA_JDBC_URL
require_env PEGA_JDBC_DRIVER_CLASS
require_env PEGA_DB_TYPE
require_env PEGA_JDBC_DRIVER_URI
require_env PEGA_RULES_SCHEMA
require_env PEGA_DATA_SCHEMA

if [[ "${PEGA_STREAM_ENABLED:-false}" == "true" ]]; then
  require_env PEGA_KAFKA_BOOTSTRAP
fi

cat > "$EVIDENCE_DIR/non-secret-runtime-inputs.txt" <<EOF
PEGA_NAMESPACE=$PEGA_NAMESPACE
PEGA_RELEASE=$PEGA_RELEASE
PEGA_VERSION=${PEGA_VERSION:-}
PEGA_HELM_CHART=$PEGA_HELM_CHART
PEGA_HELM_CHART_VERSION=${PEGA_HELM_CHART_VERSION:-auto-reviewed}
PEGA_WEB_IMAGE=$PEGA_WEB_IMAGE
PEGA_INSTALLER_IMAGE=$PEGA_INSTALLER_IMAGE
PEGA_CLUSTERING_SERVICE_IMAGE=$PEGA_CLUSTERING_SERVICE_IMAGE
PEGA_JDBC_URL=$PEGA_JDBC_URL
PEGA_DB_TYPE=$PEGA_DB_TYPE
PEGA_ROUTE_HOST=$PEGA_ROUTE_HOST
PEGA_STREAM_ENABLED=${PEGA_STREAM_ENABLED:-false}
EOF

echo "== Secret readiness =="
if oc get namespace "$PEGA_NAMESPACE" >/dev/null 2>&1; then
  if oc -n "$PEGA_NAMESPACE" get secret "$PEGA_IMAGE_PULL_SECRET" >/dev/null 2>&1; then
    echo "imagePullSecret: present" | tee "$EVIDENCE_DIR/secret-readiness.txt"
  else
    echo "imagePullSecret: not present yet (run create-secrets.sh)" | tee "$EVIDENCE_DIR/secret-readiness.txt"
  fi
else
  echo "namespace not created yet; secrets will be created after bootstrap" | tee "$EVIDENCE_DIR/secret-readiness.txt"
fi

echo "== Capacity snapshot =="
oc describe nodes > "$EVIDENCE_DIR/nodes-describe.txt"
oc adm top nodes > "$EVIDENCE_DIR/nodes-top.txt" 2>&1 || true

cat <<EOF

PRE-FLIGHT PASSED for architecture checks.
Runtime deployment is still conditional on:
  1) authorized Pega image access,
  2) selected Pega/database compatibility,
  3) local secrets creation,
  4) sufficient CRC capacity.
Evidence: $EVIDENCE_DIR
Route host resolved to: $PEGA_ROUTE_HOST
EOF
