# Modern Pega Architecture — I2 to I8

This directory is the architecture track for a modern **Pega Solution Architect** portfolio, centered on client-managed Pega on OpenShift while also understanding Pega Cloud responsibilities.

## Iterations

- [I2 — Licensing, Entitlements & Product Access](I2-LICENSING-ENTITLEMENTS.md)
- [I3 — Registry & Image Governance](I3-REGISTRY-IMAGE-GOVERNANCE.md)
- [I4 — Official Pega Helm / OpenShift Architecture](I4-HELM-OPENSHIFT-ARCHITECTURE.md)
- [I5 — Multi-Environment Architecture](I5-MULTI-ENVIRONMENT-ARCHITECTURE.md)
- [I6 — Platform Dependencies](I6-PLATFORM-DEPENDENCIES.md)
- [I7 — Security, IAM, TLS & Secrets](I7-SECURITY-IAM-SECRETS.md)
- [I8 — GitOps & Release Promotion](I8-GITOPS-PROMOTION.md)
- [Public reference repositories](PUBLIC-REFERENCE-REPOSITORIES.md)
- [I2-I8 status and validation gates](I2-I8-STATUS.md)

## Implementation skeleton

See [`../../platform/pega/`](../../platform/pega/) for release, registry and environment contracts.

## Current constraint

No authorized Pega runtime images are assumed to be available. Therefore the repository distinguishes architecture/static/platform validation from actual Pega runtime validation.