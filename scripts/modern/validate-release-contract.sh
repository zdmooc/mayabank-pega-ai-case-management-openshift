#!/usr/bin/env bash
set -euo pipefail

CATALOG="${1:-platform/pega/registry/image-catalog.example.yaml}"
RELEASE="${2:-platform/pega/release/release-manifest.example.yaml}"

for f in "$CATALOG" "$RELEASE"; do
  [[ -f "$f" ]] || { echo "ERROR: missing $f" >&2; exit 1; }
done

required_catalog=(
  'immutableDigests: true'
  'approvedRegistriesOnly: true'
  'secretsInGit: false'
  'proprietaryImagesInGit: false'
  'sha256:'
)

for p in "${required_catalog[@]}"; do
  grep -q "$p" "$CATALOG" || { echo "ERROR: catalog missing contract: $p" >&2; exit 1; }
done

required_release=(
  'pegaRelease:'
  'vendorHelmChart:'
  'configurationRevision:'
  'runtime:'
  'installer:'
  'rollbackClass:'
)

for p in "${required_release[@]}"; do
  grep -q "$p" "$RELEASE" || { echo "ERROR: release manifest missing contract: $p" >&2; exit 1; }
done

if grep -Eq ':[[:space:]]+latest([[:space:]]|$)' "$RELEASE" "$CATALOG"; then
  echo "ERROR: mutable latest tag is forbidden in release contracts" >&2
  exit 1
fi

echo "PASS: release and image-governance contracts are present."
