#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd oc
require_cmd helm
if command -v python3 >/dev/null 2>&1; then PYTHON_BIN=python3; elif command -v python >/dev/null 2>&1; then PYTHON_BIN=python; else echo "ERROR: python required" >&2; exit 2; fi

# Static Kubernetes syntax/schema checks for repository-owned manifests.
for f in \
  "$REPO_ROOT/openshift/crc/namespace.yaml" \
  "$REPO_ROOT/openshift/crc/resourcequota.yaml" \
  "$REPO_ROOT/openshift/crc/limitrange.yaml" \
  "$REPO_ROOT/openshift/crc/rbac-observer.yaml" \
  "$REPO_ROOT/openshift/crc/networkpolicies-staged.yaml"; do
  echo "Validating $f"
  oc apply --dry-run=client -f "$f" >/dev/null
done

# Detect unresolved template variables in source templates. This checks syntax of our
# templating contract without publishing any secret.
"$PYTHON_BIN" - "$REPO_ROOT/openshift/helm/pega-values-crc.overlay.yaml.tpl" "$REPO_ROOT/openshift/crc/postgres-lab.yaml.tpl" <<'PY'
import re, sys
from pathlib import Path
p = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")
for name in sys.argv[1:]:
    text = Path(name).read_text(encoding="utf-8")
    vars_ = sorted(set(p.findall(text)))
    if not vars_:
        raise SystemExit(f"ERROR: template {name} contains no declared variables; wrong file?")
    print(f"{name}: {len(vars_)} template variables")
PY

# Helm template validation can use deliberately non-routable placeholders when the
# operator has not yet received Pega images. This validates chart/values structure,
# NOT runtime compatibility or entitlement.
export PEGA_RELEASE="${PEGA_RELEASE:-mayabank-pega}"
export PEGA_JDBC_URL="${PEGA_JDBC_URL:-jdbc:postgresql://pega-postgres:5432/pega}"
export PEGA_JDBC_DRIVER_CLASS="${PEGA_JDBC_DRIVER_CLASS:-org.postgresql.Driver}"
export PEGA_DB_TYPE="${PEGA_DB_TYPE:-postgres}"
export PEGA_JDBC_DRIVER_URI="${PEGA_JDBC_DRIVER_URI:-https://example.invalid/postgresql.jar}"
export PEGA_RULES_SCHEMA="${PEGA_RULES_SCHEMA:-pegarules}"
export PEGA_DATA_SCHEMA="${PEGA_DATA_SCHEMA:-pegadata}"
export PEGA_IMAGE_PULL_SECRET="${PEGA_IMAGE_PULL_SECRET:-pega-registry}"
export PEGA_WEB_IMAGE="${PEGA_WEB_IMAGE:-example.invalid/authorized-pega-image:placeholder}"
export PEGA_INSTALLER_IMAGE="${PEGA_INSTALLER_IMAGE:-example.invalid/authorized-pega-installer:placeholder}"
export PEGA_CLUSTERING_SERVICE_IMAGE="${PEGA_CLUSTERING_SERVICE_IMAGE:-example.invalid/authorized-clustering-service:placeholder}"
export PEGA_ROUTE_HOST="${PEGA_ROUTE_HOST:-pega.apps-crc.testing}"
export PEGA_WEB_MEMORY="${PEGA_WEB_MEMORY:-6Gi}"
export PEGA_WEB_CPU_REQUEST="${PEGA_WEB_CPU_REQUEST:-500m}"
export PEGA_WEB_CPU_LIMIT="${PEGA_WEB_CPU_LIMIT:-2}"
export PEGA_WEB_HEAP="${PEGA_WEB_HEAP:-4096m}"
export PEGA_CLUSTERING_REPLICAS="${PEGA_CLUSTERING_REPLICAS:-1}"
export PEGA_STREAM_ENABLED="${PEGA_STREAM_ENABLED:-false}"
export PEGA_KAFKA_BOOTSTRAP="${PEGA_KAFKA_BOOTSTRAP:-}"
export PEGA_KAFKA_SECURITY_PROTOCOL="${PEGA_KAFKA_SECURITY_PROTOCOL:-PLAINTEXT}"

ensure_generated_dir
"$PYTHON_BIN" "$SCRIPT_DIR/render_template.py" \
  "$REPO_ROOT/openshift/helm/pega-values-crc.overlay.yaml.tpl" \
  "$REPO_ROOT/.generated/pega-values-static.yaml"

helm repo add pega https://pegasystems.github.io/pega-helm-charts --force-update >/dev/null
helm repo update pega >/dev/null
CHART_ARGS=()
if [[ -n "${PEGA_HELM_CHART_VERSION:-}" ]]; then CHART_ARGS+=(--version "$PEGA_HELM_CHART_VERSION"); fi

helm template "$PEGA_RELEASE" "${PEGA_HELM_CHART:-pega/pega}" \
  "${CHART_ARGS[@]}" \
  -n "${PEGA_NAMESPACE:-mayabank-pega}" \
  -f "$REPO_ROOT/.generated/pega-values-static.yaml" \
  --set global.actions.execute=deploy \
  --set global.jdbc.username=static-validation \
  --set global.jdbc.password=static-validation \
  --set installer.adminPassword=Static-Validation-Only-12345 \
  --set hazelcast.username=static-validation \
  --set hazelcast.password=static-validation \
  > "$REPO_ROOT/.generated/helm-template.yaml"

# Validate the rendered objects client-side. CRDs/API compatibility is still checked
# again against the real cluster during preflight/deploy.
oc apply --dry-run=client -f "$REPO_ROOT/.generated/helm-template.yaml" >/dev/null || {
  echo "WARNING: client-side validation of rendered Helm objects failed. Inspect .generated/helm-template.yaml." >&2
  exit 60
}

echo "STATIC VALIDATION PASSED. No runtime or entitlement claim is implied."
