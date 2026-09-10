# Artifact promotion gates

| Transition | Mandatory checks |
|---|---|
| Vendor -> Quarantine | entitlement, source, tag, resolved digest, acquisition timestamp |
| Quarantine -> Approved | CVE policy, SBOM, provenance/signature when available, approval/exception |
| Approved -> DEV | release manifest references approved digest |
| DEV -> TEST | smoke + integration evidence |
| TEST -> PREPROD | regression + security evidence |
| PREPROD -> PROD | change approval + rollback/forward-fix plan + DB compatibility assessment |

## Immutability

The image digest approved in quarantine must be the digest deployed in each promoted environment. Any digest change restarts the approval process.

## Database warning

Pega platform upgrades may include database changes. Artifact promotion and rollback therefore must be coupled with the supported database install/upgrade/recovery procedure for the selected release.