# Pega release contract

A deployable Pega release is not just an image tag. Treat it as the tuple:

```text
Pega application/product release
+ pinned official Pega Helm chart reference
+ approved immutable image digests
+ MayaBank configuration Git revision
+ database install/upgrade plan
+ environment approval state
```

## Why this matters

A container rollback is not necessarily safe after a database schema/rules upgrade. The release manifest therefore records a rollback classification and a database change plan.

## Promotion

Promote the same approved release tuple DEV -> TEST -> PREPROD -> PROD. Do not rebuild Pega vendor images per environment.

The example manifest in this directory is documentation/configuration metadata, not a real Kubernetes CRD.