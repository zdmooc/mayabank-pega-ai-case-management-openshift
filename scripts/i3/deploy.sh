#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd oc
require_cmd helm
if command -v python3 >/dev/null 2>&1; then PYTHON_BIN=python3; elif command -v python >/dev/null 2>&1; then PYTHON_BIN=python; else echo "ERROR: python required" >&2; exit 2; fi

for v in PEGA_WEB_IMAGE PEGA_INSTALLER_IMAGE PEGA_CLUSTERING_SERVICE_IMAGE \
         PEGA_JDBC_URL PEGA_JDBC_DRIVER_CLASS PEGA_DB_TYPE PEGA_JDBC_DRIVER_URI \
         PEGA_RULES_SCHEMA PEGA_DATA_SCHEMA; do
  require_env "$v"
done

# Prepare namespace and namespace-scoped guardrails.
oc apply -f "$REPO_ROOT/openshift/crc/namespace.yaml"
oc apply -f "$REPO_ROOT/openshift/crc/resourcequota.yaml"
oc apply -f "$REPO_ROOT/openshift/crc/limitrange.yaml"
oc apply -f "$REPO_ROOT/openshift/crc/rbac-observer.yaml"

# Local credentials may already exist. Create them if the ignored file is absent.
if [[ ! -f "$REPO_ROOT/.generated/credentials.env" ]]; then
  "$SCRIPT_DIR/create-secrets.sh"
  load_env
fi

require_env DB_USER
require_env DB_PASSWORD
require_env PEGA_ADMIN_PASSWORD
require_env PEGA_CLUSTERING_USERNAME
require_env PEGA_CLUSTERING_PASSWORD

# An image pull secret is required by the overlay. Do not continue with a broken image reference.
if ! oc -n "$PEGA_NAMESPACE" get secret "$PEGA_IMAGE_PULL_SECRET" >/dev/null 2>&1; then
  echo "ERROR: image pull secret '$PEGA_IMAGE_PULL_SECRET' not found in $PEGA_NAMESPACE." >&2
  echo "Run create-secrets.sh with registry credentials or create the authorized registry secret manually." >&2
  exit 20
fi

# Render non-secret overlay and optional PostgreSQL lab manifest.
"$SCRIPT_DIR/render-values.sh"

if [[ "${DEPLOY_LOCAL_POSTGRES:-false}" == "true" ]]; then
  echo "Deploying optional local PostgreSQL lab..."
  oc apply -f "$REPO_ROOT/.generated/postgres-lab.yaml"
  oc -n "$PEGA_NAMESPACE" rollout status statefulset/pega-postgres --timeout=10m
fi

helm repo add pega https://pegasystems.github.io/pega-helm-charts --force-update >/dev/null
helm repo update pega >/dev/null

CHART_ARGS=()
if [[ -n "${PEGA_HELM_CHART_VERSION:-}" ]]; then
  CHART_ARGS+=(--version "$PEGA_HELM_CHART_VERSION")
fi

# Sensitive chart values are written only to a temporary chmod-600 JSON file.
# JSON is valid YAML and safely escapes user-provided strings.
SECRET_VALUES="$(mktemp)"
chmod 600 "$SECRET_VALUES" 2>/dev/null || true
cleanup_secret_values() { rm -f "$SECRET_VALUES"; }
trap cleanup_secret_values EXIT
export SECRET_VALUES
"$PYTHON_BIN" - <<'PY'
import json, os
payload = {
    "global": {
        "jdbc": {
            "username": os.environ["DB_USER"],
            "password": os.environ["DB_PASSWORD"],
        }
    },
    "installer": {
        "adminPassword": os.environ["PEGA_ADMIN_PASSWORD"],
    },
    "hazelcast": {
        "username": os.environ["PEGA_CLUSTERING_USERNAME"],
        "password": os.environ["PEGA_CLUSTERING_PASSWORD"],
    },
}
with open(os.environ["SECRET_VALUES"], "w", encoding="utf-8") as f:
    json.dump(payload, f)
PY

VALUES_ARGS=(
  -f "$REPO_ROOT/.generated/pega-values-crc.overlay.yaml"
  -f "$SECRET_VALUES"
)

if helm status "$PEGA_RELEASE" -n "$PEGA_NAMESPACE" >/dev/null 2>&1; then
  echo "Existing Helm release detected: upgrade/deploy only (no database reinstall)."
  helm upgrade "$PEGA_RELEASE" "$PEGA_HELM_CHART" \
    -n "$PEGA_NAMESPACE" \
    "${CHART_ARGS[@]}" \
    "${VALUES_ARGS[@]}" \
    --wait --timeout 90m
else
  echo "First Helm release: install Pega schema then deploy."
  echo "WARNING: confirm the target database is the intended empty/new Pega database before continuing."
  if [[ "${CONFIRM_INITIAL_PEGA_INSTALL:-}" != "yes" ]]; then
    echo "ERROR: set CONFIRM_INITIAL_PEGA_INSTALL=yes for the first database install." >&2
    exit 21
  fi
  helm install "$PEGA_RELEASE" "$PEGA_HELM_CHART" \
    -n "$PEGA_NAMESPACE" \
    "${CHART_ARGS[@]}" \
    "${VALUES_ARGS[@]}" \
    --set global.actions.execute=install-deploy \
    --wait --timeout 90m
fi

"$SCRIPT_DIR/ensure-route-tls.sh"

if [[ "${APPLY_NETWORK_POLICIES:-false}" == "true" ]]; then
  "$SCRIPT_DIR/apply-network-policies.sh"
else
  echo "NetworkPolicy hardening remains staged. Set APPLY_NETWORK_POLICIES=true only after required egress endpoints are mapped."
fi

"$SCRIPT_DIR/verify.sh"
