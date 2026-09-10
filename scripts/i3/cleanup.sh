#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env
require_cmd oc
require_cmd helm

if [[ "${CONFIRM_UNINSTALL:-no}" != "yes" ]]; then
  echo "Refusing uninstall. Set CONFIRM_UNINSTALL=yes after reviewing what will be removed." >&2
  exit 70
fi

if helm status "$PEGA_RELEASE" -n "$PEGA_NAMESPACE" >/dev/null 2>&1; then
  helm uninstall "$PEGA_RELEASE" -n "$PEGA_NAMESPACE"
else
  echo "Helm release not found: $PEGA_RELEASE"
fi

if [[ "${CONFIRM_DELETE_DATA:-no}" == "yes" ]]; then
  echo "Deleting optional local PostgreSQL StatefulSet/service/PVC and local generated credentials."
  oc -n "$PEGA_NAMESPACE" delete statefulset pega-postgres --ignore-not-found
  oc -n "$PEGA_NAMESPACE" delete service pega-postgres --ignore-not-found
  oc -n "$PEGA_NAMESPACE" delete secret pega-postgres-secret --ignore-not-found
  oc -n "$PEGA_NAMESPACE" delete pvc -l app.kubernetes.io/name=pega-postgres --ignore-not-found || true
  rm -f "$REPO_ROOT/.generated/credentials.env"
else
  echo "Data/secrets retained. Set CONFIRM_DELETE_DATA=yes only when destruction is intended."
fi

# Namespace is deliberately preserved so quota/RBAC/evidence can be inspected.
echo "Namespace $PEGA_NAMESPACE retained. Delete it manually only when all retained data is disposable."
