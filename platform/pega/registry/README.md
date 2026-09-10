# Pega image registry topology

## Logical repositories

```text
pega-upstream-remote        optional controlled proxy/reference
pega-quarantine-local      newly acquired images, not production-approved
pega-approved-local        approved immutable images
pega-virtual               cluster-facing endpoint (name illustrative)
```

The exact naming is organization-specific. The architecture goal is to separate **acquisition/quarantine** from **approved deployment artifacts**.

## Required metadata per image

- vendor product/release;
- source registry/repository/tag;
- resolved `sha256` digest;
- acquisition timestamp;
- SBOM reference;
- vulnerability scan reference;
- exception/approval reference when applicable;
- environments allowed;
- retention/rollback status.

## Promotion rule

An image is never promoted by rebuilding it. Promotion means authorizing the exact previously scanned digest for the next environment.

## Credentials

Vendor access keys and internal registry robot credentials must be supplied by a secret manager or protected CI/CD secret. They must never be committed to this repository.