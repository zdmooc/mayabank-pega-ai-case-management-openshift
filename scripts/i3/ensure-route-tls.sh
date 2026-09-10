#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env
require_cmd oc
assert_namespace

if [[ -z "${PEGA_ROUTE_HOST:-}" ]]; then
  APPS_DOMAIN="$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')"
  PEGA_ROUTE_HOST="pega.${APPS_DOMAIN}"
fi

ROUTE_NAME="$(oc -n "$PEGA_NAMESPACE" get route -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.host}{"\n"}{end}' | awk -v h="$PEGA_ROUTE_HOST" '$2==h {print $1; exit}')"
if [[ -z "$ROUTE_NAME" ]]; then
  echo "ERROR: no OpenShift Route found for host $PEGA_ROUTE_HOST" >&2
  oc -n "$PEGA_NAMESPACE" get route -o wide || true
  exit 30
fi

TERMINATION="$(oc -n "$PEGA_NAMESPACE" get route "$ROUTE_NAME" -o jsonpath='{.spec.tls.termination}')"
REDIRECT="$(oc -n "$PEGA_NAMESPACE" get route "$ROUTE_NAME" -o jsonpath='{.spec.tls.insecureEdgeTerminationPolicy}')"

# The official Pega OpenShift chart normally creates an edge-terminated Route
# when backend service TLS is disabled. Patch only if TLS was unexpectedly absent.
if [[ -z "$TERMINATION" ]]; then
  oc -n "$PEGA_NAMESPACE" patch route "$ROUTE_NAME" --type=merge \
    -p '{"spec":{"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}'
  TERMINATION="edge"
  REDIRECT="Redirect"
fi

case "$TERMINATION" in
  edge|reencrypt|passthrough) ;;
  *) echo "ERROR: unsupported/unexpected route TLS termination: $TERMINATION" >&2; exit 31 ;;
esac

if [[ "$REDIRECT" != "Redirect" ]]; then
  echo "WARNING: insecureEdgeTerminationPolicy=$REDIRECT (expected Redirect for the CRC lab)." >&2
fi

echo "Route TLS OK: name=$ROUTE_NAME host=$PEGA_ROUTE_HOST termination=$TERMINATION redirect=$REDIRECT"
