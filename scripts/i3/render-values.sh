#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd oc
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN=python
else
  echo "ERROR: python3/python required" >&2
  exit 2
fi

ensure_generated_dir

: "${PEGA_WEB_MEMORY:=6Gi}"
: "${PEGA_WEB_CPU_REQUEST:=500m}"
: "${PEGA_WEB_CPU_LIMIT:=2}"
: "${PEGA_WEB_HEAP:=4096m}"
: "${PEGA_CLUSTERING_REPLICAS:=1}"
: "${PEGA_STREAM_ENABLED:=false}"
: "${PEGA_KAFKA_BOOTSTRAP:=}"
: "${PEGA_KAFKA_SECURITY_PROTOCOL:=PLAINTEXT}"
: "${POSTGRES_STORAGE:=10Gi}"

if [[ -z "${PEGA_ROUTE_HOST:-}" ]]; then
  APPS_DOMAIN="$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')"
  export PEGA_ROUTE_HOST="pega.${APPS_DOMAIN}"
fi

for v in PEGA_RELEASE PEGA_JDBC_URL PEGA_JDBC_DRIVER_CLASS PEGA_DB_TYPE \
         PEGA_JDBC_DRIVER_URI PEGA_RULES_SCHEMA PEGA_DATA_SCHEMA \
         PEGA_IMAGE_PULL_SECRET PEGA_WEB_IMAGE PEGA_INSTALLER_IMAGE \
         PEGA_CLUSTERING_SERVICE_IMAGE PEGA_ROUTE_HOST PEGA_WEB_MEMORY \
         PEGA_WEB_CPU_REQUEST PEGA_WEB_CPU_LIMIT PEGA_WEB_HEAP \
         PEGA_CLUSTERING_REPLICAS PEGA_STREAM_ENABLED PEGA_KAFKA_BOOTSTRAP \
         PEGA_KAFKA_SECURITY_PROTOCOL; do
  export "$v"
done

"$PYTHON_BIN" "$SCRIPT_DIR/render_template.py" \
  "$REPO_ROOT/openshift/helm/pega-values-crc.overlay.yaml.tpl" \
  "$REPO_ROOT/.generated/pega-values-crc.overlay.yaml"

if [[ "${DEPLOY_LOCAL_POSTGRES:-false}" == "true" ]]; then
  require_env POSTGRES_IMAGE
  export POSTGRES_IMAGE POSTGRES_STORAGE
  "$PYTHON_BIN" "$SCRIPT_DIR/render_template.py" \
    "$REPO_ROOT/openshift/crc/postgres-lab.yaml.tpl" \
    "$REPO_ROOT/.generated/postgres-lab.yaml"
fi

echo "Rendered non-secret values under .generated/."
