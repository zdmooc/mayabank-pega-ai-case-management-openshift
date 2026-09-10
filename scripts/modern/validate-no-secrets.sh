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
config_suffixes = {'.yaml', '.yml', '.json', '.properties', '.ini', '.conf', '.env'}
errors = []

for p in root.rglob('*'):
    if not p.is_file() or '.git' in p.parts:
        continue

    # Proprietary/binary Pega artifacts and private-key containers are forbidden.
    if p.suffix.lower() in prohibited_suffixes:
        errors.append(f'prohibited binary/proprietary artifact: {p}')
        continue

    # A real dotenv file must never be committed. `.env.example` is allowed.
    if p.name == '.env':
        errors.append(f'local environment secret file must not be committed: {p}')

    try:
        text = p.read_text(encoding='utf-8')
    except (UnicodeDecodeError, OSError):
        continue

    if re.search(r'BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY', text):
        errors.append(f'private key material marker: {p}')

    # Templates/examples and shell scripts intentionally contain secret references,
    # variable names and validation expressions. Scan only concrete config files
    # for literal credential assignments to avoid treating references as secrets.
    if p == scanner or p.suffix.lower() not in config_suffixes:
        continue
    if p.name.endswith(('.example.yaml', '.example.yml', '.example.json', '.example')):
        continue
    if '.tpl' in p.suffixes or p.name.endswith('.tpl'):
        continue

    credential_re = re.compile(
        r'(?i)(?P<key>[A-Z0-9_.-]*(?:PASSWORD|PASSWD|ACCESS[_-]?KEY|CLIENT[_-]?SECRET|AUTH[_-]?TOKEN)[A-Z0-9_.-]*)'
        r'\s*[:=]\s*["\']?(?P<value>[^"\'\s#]+)'
    )
    safe_prefixes = ('<', '${', '$', '{{', '%', '***')
    safe_exact = {'', 'null', 'none', 'example', 'placeholder', 'redacted'}

    for lineno, line in enumerate(text.splitlines(), 1):
        for match in credential_re.finditer(line):
            key = match.group('key')
            value = match.group('value').strip()
            low = value.lower()
            if value.startswith(safe_prefixes) or low in safe_exact:
                continue
            errors.append(f'possible plaintext credential: {p}:{lineno}: {key}=<redacted>')

if errors:
    for item in errors:
        print(f'ERROR: {item}', file=sys.stderr)
    sys.exit(1)

print('PASS: no prohibited Pega binaries, private keys, .env files or obvious literal credentials detected.')
PY
