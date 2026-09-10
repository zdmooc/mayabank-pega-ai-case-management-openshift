# Architecture gates

## Gate I2 — licensing

No runtime deployment until products, release, deployment model and authorized artifact access are understood.

## Gate I3 — images

No controlled deployment from an image that lacks source, digest, scan/SBOM evidence and approval state.

## Gate I4 — Helm

No deployment before the exact official Pega chart ref is pinned and rendered with mapped customer overlays.

## Gate I5 — environments

No promotion if the target introduces undocumented configuration drift or a different unapproved image digest.

## Gate I6 — dependencies

No Pega install/upgrade before database and release-dependent platform services are ready and support-compatible.

## Gate I7 — security

No production go-live with secrets in Git, unreviewed SCC privileges, unencrypted required flows or unmanaged identities.

## Gate I8 — GitOps

No production promotion without a traceable release tuple, approvals, evidence and a database-aware rollback/forward-fix plan.
