#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib.sh"
load_env

require_cmd oc
require_cmd helm
require_cmd curl
if command -v python3 >/dev/null 2>&1; then PYTHON_BIN=python3; elif command -v python >/dev/null 2>&1; then PYTHON_BIN=python; else echo "ERROR: python required" >&2; exit 2; fi
assert_namespace

EVIDENCE_DIR="$(raw_evidence_dir)"
mkdir -p "$REPO_ROOT/evidence/runtime"

oc version > "$EVIDENCE_DIR/oc-version.txt" 2>&1
crc version > "$EVIDENCE_DIR/crc-version.txt" 2>&1 || true
helm version > "$EVIDENCE_DIR/helm-version.txt" 2>&1
helm status "$PEGA_RELEASE" -n "$PEGA_NAMESPACE" > "$EVIDENCE_DIR/helm-status.txt" 2>&1
helm get values "$PEGA_RELEASE" -n "$PEGA_NAMESPACE" > "$EVIDENCE_DIR/helm-values-redacted-needed.txt" 2>&1 || true
# Helm values can contain credentials. Never commit raw evidence; the directory is gitignored.

oc -n "$PEGA_NAMESPACE" get pods -o wide > "$EVIDENCE_DIR/pods.txt"
oc -n "$PEGA_NAMESPACE" get pods -o json > "$EVIDENCE_DIR/pods.json"
oc -n "$PEGA_NAMESPACE" get deployment,statefulset,job -o wide > "$EVIDENCE_DIR/workloads.txt" 2>&1 || true
oc -n "$PEGA_NAMESPACE" get service -o wide > "$EVIDENCE_DIR/services.txt"
oc -n "$PEGA_NAMESPACE" get route -o wide > "$EVIDENCE_DIR/routes.txt" 2>&1 || true
oc -n "$PEGA_NAMESPACE" get pvc -o wide > "$EVIDENCE_DIR/pvcs.txt" 2>&1 || true
oc -n "$PEGA_NAMESPACE" get resourcequota,limitrange > "$EVIDENCE_DIR/guardrails.txt" 2>&1 || true
oc -n "$PEGA_NAMESPACE" get events --sort-by=.lastTimestamp > "$EVIDENCE_DIR/events.txt" 2>&1 || true

POD_CHECK="$EVIDENCE_DIR/pod-check.txt"
if "$PYTHON_BIN" - "$EVIDENCE_DIR/pods.json" > "$POD_CHECK" <<'PY'
import json, sys
p = json.load(open(sys.argv[1], encoding="utf-8"))
bad=[]
for pod in p.get("items", []):
    name=pod["metadata"]["name"]
    phase=pod.get("status",{}).get("phase","")
    if phase == "Succeeded":
        continue
    statuses=pod.get("status",{}).get("containerStatuses") or []
    ready=bool(statuses) and all(x.get("ready",False) for x in statuses)
    if phase != "Running" or not ready:
        bad.append((name,phase,ready))
if bad:
    for row in bad: print("NOT_READY", *row)
    raise SystemExit(1)
print("ALL_NON_COMPLETED_PODS_READY")
PY
then
  PODS_OK=true
else
  PODS_OK=false
fi

if [[ -z "${PEGA_ROUTE_HOST:-}" ]]; then
  PEGA_ROUTE_HOST="$(oc -n "$PEGA_NAMESPACE" get route -o jsonpath='{.items[0].spec.host}' 2>/dev/null || true)"
fi

HTTP_CODE="000"
SMOKE_URL=""
if [[ -n "$PEGA_ROUTE_HOST" ]]; then
  for path in /prweb/PRServlet /prweb/ /; do
    url="https://${PEGA_ROUTE_HOST}${path}"
    code="$(curl -k -sS -o "$EVIDENCE_DIR/http-body.tmp" -w '%{http_code}' --connect-timeout 10 --max-time 30 "$url" || true)"
    printf '%s %s\n' "$code" "$url" >> "$EVIDENCE_DIR/http-probes.txt"
    case "$code" in
      200|301|302|303|307|308|401|403)
        HTTP_CODE="$code"
        SMOKE_URL="$url"
        break
        ;;
    esac
  done
fi
rm -f "$EVIDENCE_DIR/http-body.tmp"

HTTP_OK=false
case "$HTTP_CODE" in 200|301|302|303|307|308|401|403) HTTP_OK=true ;; esac

HELM_OK=false
if helm status "$PEGA_RELEASE" -n "$PEGA_NAMESPACE" >/dev/null 2>&1; then HELM_OK=true; fi

STATUS="DEPLOYMENT_CHECK_FAILED"
if [[ "$HELM_OK" == true && "$PODS_OK" == true && "$HTTP_OK" == true ]]; then
  STATUS="DEPLOYED_TRANSPORT_VALIDATED"
  if [[ "${CONFIRM_PEGA_LOGIN:-no}" == "yes" ]]; then
    STATUS="RUNTIME_VALIDATED_BY_USER_LOGIN"
  fi
fi

cat > "$REPO_ROOT/evidence/runtime/I3_RUNTIME_STATUS.md" <<EOF
# I3 Runtime Status

- Timestamp UTC: $(now_utc)
- Status: **$STATUS**
- Namespace: \`$PEGA_NAMESPACE\`
- Helm release: \`$PEGA_RELEASE\`
- Pega target version: \`${PEGA_VERSION:-unknown}\`
- Route host: \`${PEGA_ROUTE_HOST:-not-found}\`
- HTTP probe: \`$HTTP_CODE\` \`${SMOKE_URL:-not-reachable}\`
- Helm release detected: \`$HELM_OK\`
- Non-completed pods ready: \`$PODS_OK\`

## Interpretation

\`DEPLOYED_TRANSPORT_VALIDATED\` proves that the Helm release exists, non-completed pods are ready and an HTTPS endpoint responds. It does **not** prove successful functional login.

\`RUNTIME_VALIDATED_BY_USER_LOGIN\` is emitted only when the same checks pass and the operator reruns verification with \`CONFIRM_PEGA_LOGIN=yes\` after actually logging in to the Pega runtime.

Raw evidence is kept under the gitignored \`evidence/runtime/raw/\` directory and must be reviewed/redacted before any publication.
EOF

cat "$REPO_ROOT/evidence/runtime/I3_RUNTIME_STATUS.md"

if [[ "$HELM_OK" != true || "$PODS_OK" != true || "$HTTP_OK" != true ]]; then
  echo "ERROR: one or more deployment checks failed. Inspect $EVIDENCE_DIR" >&2
  exit 50
fi
