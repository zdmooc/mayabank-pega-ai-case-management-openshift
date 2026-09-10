# Pega Platform — Client-Managed OpenShift Skeleton

This directory contains the **customer-owned configuration layer** around the official Pega deployment assets. It intentionally contains no Pega proprietary image or binary.

## Structure

```text
platform/pega/
  release/
    release-manifest.example.yaml
  registry/
    image-catalog.example.yaml
  values/
    common.example.yaml
    local.example.yaml
    dev.example.yaml
    test.example.yaml
    preprod.example.yaml
    prod.example.yaml
```

## Rules

1. Use only authorized Pega images obtained through the customer's valid entitlement.
2. Mirror approved images to the enterprise private registry.
3. Pin immutable digests for controlled environments.
4. Never commit registry passwords, pull tokens, database passwords or private keys.
5. Treat official Pega Helm charts as vendor source-of-truth; do not fork them casually.
6. CRC/local can validate platform mechanics and static Helm rendering, not production HA.
7. `RUNTIME VALIDATED` requires an actual authorized Pega runtime and reproducible evidence.

See `docs/modernization/` for I2-I8 architecture decisions.