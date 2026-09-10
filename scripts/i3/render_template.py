#!/usr/bin/env python3
"""Strict ${VAR} template renderer for I3.

Only environment-variable substitution is performed. Missing variables fail fast.
No secrets should be rendered with this helper into tracked repository files.
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

PATTERN = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} TEMPLATE OUTPUT", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    text = src.read_text(encoding="utf-8")

    missing = sorted({m.group(1) for m in PATTERN.finditer(text) if m.group(1) not in os.environ})
    if missing:
        print("ERROR: missing environment variables: " + ", ".join(missing), file=sys.stderr)
        return 3

    rendered = PATTERN.sub(lambda m: os.environ[m.group(1)], text)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(rendered, encoding="utf-8")
    print(dst)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
