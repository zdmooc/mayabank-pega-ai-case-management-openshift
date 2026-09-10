#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
cd "$ROOT"

python - <<'PY'
from pathlib import Path
import re
import sys

root = Path('.')
scanner = Path('scripts/modern/validate-no-secrets.sh')
prohibited_suffixes = {'.war', '.ear', '.jar', '.zip', '.p12', '.pfx', '.jks', '.key'}
errors = []

# Pega/vendor binaries and private-key containers must never be committed here.
for p in root.rglob('*'):
    if not p.is_file() or '.git' in p.parts:
        continue
    if p.suffix.lower() in prohibited_suffixes:
        errors.append(f'prohibited binary/proprietary artifact: {p}')

credential_re = re.compile(
    r'(?i)(?P<key>[A-Z0-9_.-]*(?:PASSWORD|TOKEN|ACCESS[_-]?KEY|CLIENT[_-]?SECRET)[A-Z0-9_.-]*)'
    r'\s*[:=]\s*["\']?(?P<value>[^"\'\s#]+)'
)
private_key_re = re.compile(r'BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY')

safe_prefixes = ('<', '${', '$', '{{', '%', '***')
safe_exact = {'', 'null', 'none', 'example', 'placeholder', 'redacted'}

for p in root.rglob('*'):
    if not p.is_file() or '.git' in p.parts or p == scanner:
        continue
    if p.suffix.lower() in prohibited_suffixes:
        continue
    try:
        text = p.read_text(encoding='utf-8')
    except (UnicodeDecodeError, OSError):
        continue

    if private_key_re.search(text):
        errors.append(f'private key material marker: {p}')

    for lineno, line in enumerate(text.splitlines(), 1):
        for match in credential_re.finditer(line):
            key = match.group('key')
            value = match.group('value').strip()
            low = value.lower()

            # Variables/templates/format placeholders are references, not secret values.
            if value.startswith(safe_prefixes) or low in safe_exact:
                continue

            # Do not treat a Kubernetes secret object name/reference as a credential value.
            upper_key = key.upper()
            if 'IMAGE_PULL_SECRET' in upper_key or upper_key.endswith('SECRET_REF') or upper_key.endswith('SECRET_NAME'):
                continue

            errors.append(f'possible plaintext credential: {p}:{lineno}: {key}=<redacted>')

if errors:
    for item in errors:
        print(f'ERROR: {item}', file=sys.stderr)
    sys.exit(1)

print('PASS: no prohibited Pega binaries or obvious plaintext credentials detected.')
PY
