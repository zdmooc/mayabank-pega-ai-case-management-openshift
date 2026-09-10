#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

fail=0

# Proprietary/binary artifacts that must never be committed to this public portfolio.
while IFS= read -r -d '' f; do
  echo "ERROR: prohibited binary/proprietary artifact tracked or present: $f" >&2
  fail=1
done < <(find . -type f \( -iname '*.war' -o -iname '*.ear' -o -iname '*.jar' -o -iname '*.zip' -o -iname '*.p12' -o -iname '*.pfx' -o -iname '*.jks' -o -iname '*.key' \) -print0)

# Heuristic secret checks. Example/template placeholders are allowed; real-looking assignments are not.
patterns=(
  'PGPASSWORD=[^<${][^[:space:]]+'
  'PEGA_.*(PASSWORD|TOKEN|SECRET|ACCESS_KEY)=[^<${][^[:space:]]+'
  'password:[[:space:]]*[^<${][^[:space:]]+'
  'clientSecret:[[:space:]]*[^<${][^[:space:]]+'
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
)

for pattern in "${patterns[@]}"; do
  if grep -RInE --exclude-dir=.git --exclude='*.md' "$pattern" . >/tmp/pega-secret-scan.txt 2>/dev/null; then
    echo "ERROR: possible secret detected for pattern: $pattern" >&2
    cat /tmp/pega-secret-scan.txt >&2
    fail=1
  fi
done

rm -f /tmp/pega-secret-scan.txt

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "PASS: no prohibited Pega binaries or obvious plaintext secrets detected."
