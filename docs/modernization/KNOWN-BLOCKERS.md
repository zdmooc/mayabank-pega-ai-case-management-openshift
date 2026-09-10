# Known blockers

## Blocking genuine Pega runtime validation

- no current authorized Pega container image entitlement is available in this project context;
- exact Pega release/product entitlement is not yet verified against a customer contract;
- exact official Helm chart ref compatible with that authorized release has not yet been pinned;
- corresponding database/platform-service support versions therefore remain to be verified.

## Not blocked

The following work remains independently executable:

- OpenShift/CRC platform controls;
- Artifactory/Quay-style registry lab using substitute images;
- digest/SBOM/CVE/promotion mechanics;
- Helm/GitOps tooling;
- namespace/RBAC/quota/network policy/TLS patterns;
- architecture and runbook refinement.

These independent tests must not be represented as Pega runtime evidence.