# I2-I8 implementation status

This status file separates **architecture completed in Git** from **runtime evidence that cannot exist yet without authorized Pega product access**.

| Iteration | Architecture/configuration status | Runtime status | Blocking dependency |
|---|---|---|---|
| I2 Licensing & entitlements | COMPLETE (design) | NOT APPLICABLE | customer contract/entitlement for real validation |
| I3 Registry & image governance | COMPLETE (design + contracts + CI guards) | SUBSTITUTE-IMAGE TESTABLE | official Pega image entitlement |
| I4 Official Helm/OpenShift architecture | COMPLETE (design) | STATICALLY VALIDATABLE AFTER CHART PIN | selected vendor chart/release pin |
| I5 Multi-environment model | COMPLETE (design + overlays) | PLATFORM-LAYER TESTABLE | target clusters for non-local environments |
| I6 DB/SRS/clustering/integration dependencies | COMPLETE (design) | PARTIALLY TESTABLE | selected Pega release/support matrix |
| I7 Security/IAM/TLS/secrets | COMPLETE (design + repository guard) | OPENSHIFT-LAYER TESTABLE | enterprise IdP/PKI/secret manager for real integration |
| I8 GitOps/promotion | COMPLETE (design + release contract + CI guard) | GITOPS-LAYER TESTABLE | Argo CD/runtime environments |

## Evidence vocabulary

Use only these labels:

- `DESIGNED`: architecture exists but has not been executed.
- `STATICALLY VALIDATED`: manifests/chart render or policy checks passed without runtime proof.
- `PLATFORM VALIDATED`: OpenShift/registry/GitOps mechanics executed using non-Pega substitutes where necessary.
- `RUNTIME VALIDATED`: authorized Pega runtime started and functional smoke tests passed.
- `HA VALIDATED`: failure tests executed on infrastructure capable of demonstrating the stated HA property.

CRC can support `PLATFORM VALIDATED` and possibly `RUNTIME VALIDATED` for a local Pega lab when authorized images are available, but it cannot support a production `HA VALIDATED` claim.

## Next execution gate

Before moving I4-I8 from design/static validation toward Pega runtime validation:

1. select and pin the official Pega Helm chart revision compatible with the chosen authorized Pega release;
2. obtain authorized Pega image coordinates and digests;
3. map the architecture overlays to the exact vendor chart keys;
4. run Helm lint/template and policy validation;
5. deploy platform prerequisites on CRC;
6. only then attempt the authorized Pega runtime.