#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd oc
require_cmd openssl
ensure_generated_dir

# Namespace must exist before secrets.
oc apply -f "$REPO_ROOT/openshift/crc/namespace.yaml"

: "${DB_USER:=pega}"
: "${POSTGRES_DB:=pega}"
: "${DB_PASSWORD:=$(openssl rand -hex 24)}"
: "${PEGA_ADMIN_PASSWORD:=Maya-$(openssl rand -hex 20)}"
: "${PEGA_CLUSTERING_USERNAME:=pega-cluster}"
: "${PEGA_CLUSTERING_PASSWORD:=$(openssl rand -hex 24)}"

CRED_FILE="$REPO_ROOT/.generated/credentials.env"
{
  printf 'DB_USER=%q\n' "$DB_USER"
  printf 'DB_PASSWORD=%q\n' "$DB_PASSWORD"
  printf 'POSTGRES_DB=%q\n' "$POSTGRES_DB"
  printf 'PEGA_ADMIN_PASSWORD=%q\n' "$PEGA_ADMIN_PASSWORD"
  printf 'PEGA_CLUSTERING_USERNAME=%q\n' "$PEGA_CLUSTERING_USERNAME"
  printf 'PEGA_CLUSTERING_PASSWORD=%q\n' "$PEGA_CLUSTERING_PASSWORD"
} > "$CRED_FILE"
chmod 600 "$CRED_FILE" 2>/dev/null || true

oc -n "$PEGA_NAMESPACE" create secret generic pega-postgres-secret \
  --from-literal=database="$POSTGRES_DB" \
  --from-literal=username="$DB_USER" \
  --from-literal=password="$DB_PASSWORD" \
  --dry-run=client -o yaml | oc apply -f -

if oc -n "$PEGA_NAMESPACE" get secret "$PEGA_IMAGE_PULL_SECRET" >/dev/null 2>&1; then
  echo "Registry secret already exists: $PEGA_IMAGE_PULL_SECRET"
elif [[ -n "${PEGA_REGISTRY:-}" && -n "${PEGA_REGISTRY_USER:-}" && -n "${PEGA_REGISTRY_PASSWORD:-}" ]]; then
  oc -n "$PEGA_NAMESPACE" create secret docker-registry "$PEGA_IMAGE_PULL_SECRET" \
    --docker-server="$PEGA_REGISTRY" \
    --docker-username="$PEGA_REGISTRY_USER" \
    --docker-password="$PEGA_REGISTRY_PASSWORD" \
    --dry-run=client -o yaml | oc apply -f -
  echo "Registry secret created: $PEGA_IMAGE_PULL_SECRET"
else
  echo "WARNING: registry secret $PEGA_IMAGE_PULL_SECRET does not exist and registry credentials were not provided." >&2
  echo "Provide PEGA_REGISTRY/PEGA_REGISTRY_USER/PEGA_REGISTRY_PASSWORD or create the secret manually before deploy." >&2
fi

cat <<EOF
Local credentials prepared.
- Kubernetes DB secret: pega-postgres-secret
- Local ignored credential file: .generated/credentials.env
- Admin/clustering passwords were NOT printed.
Do not commit .generated/ or secret YAML.
EOF
