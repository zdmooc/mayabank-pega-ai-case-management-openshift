# I3 — Pega Registry & Image Governance

## Objective

Model the enterprise software-supply-chain used to acquire, control and promote authorized Pega container images without ever publishing proprietary Pega binaries or credentials in Git.

> Status: **DESIGNED / EXECUTABLE WITH SUBSTITUTE IMAGES / PEGA RUNTIME REQUIRES ENTITLEMENT**.

## Target flow

```text
Pega authorized distribution
        |
        v
Acquisition identity / access key
        |
        v
QUARANTINE repository
        |
        +--> malware/CVE scan
        +--> SBOM generation/import
        +--> signature/digest verification
        +--> licence/policy checks
        |
        v
Security approval
        |
        v
APPROVED immutable repository
        |
        v
Virtual registry endpoint
        |
        +--> DEV
        +--> TEST
        +--> PREPROD
        +--> PROD
```

## Repository model (Artifactory/Quay equivalent)

Recommended logical repositories:

```text
pega-upstream-remote          # optional controlled proxy where contractually/technically appropriate
pega-quarantine-local        # newly acquired images, not deployable to prod
pega-approved-local          # security-approved immutable images
pega-virtual                 # consumer endpoint exposed to clusters
```

The exact Artifactory repository type/topology depends on the organization's security policy and whether upstream proxying is permitted. An explicit pull-then-push process is acceptable and often easier to audit for proprietary vendor registries.

## Image metadata contract

Every promoted artifact must be represented by immutable metadata:

```yaml
product: pega-platform
version: "<authorized-version>"
sourceRegistry: "<vendor-registry>"
sourceRepository: "<vendor-repository>"
sourceTag: "<vendor-tag>"
digest: "sha256:<digest>"
sbom: "<sbom-reference>"
scanReport: "<scan-report-reference>"
approvalTicket: "<approval-reference>"
approvedAt: "<timestamp>"
allowedEnvironments:
  - dev
  - test
  - preprod
  - prod
```

No real credential, token or proprietary layer is stored in Git.

## Promotion policy

**Build once / acquire once, promote the same digest.**

Never rebuild or retag an uncontrolled image independently for each environment. The deployment contract should pin the approved digest whenever supported:

```text
vendor image tag
     |
     v
resolve digest sha256:ABC
     |
     v
scan + approve ABC
     |
     +--> DEV uses ABC
     +--> TEST uses ABC
     +--> PREPROD uses ABC
     +--> PROD uses ABC
```

If a tag is used for operator convenience, the corresponding digest must remain recorded and promotion must fail if the digest changes unexpectedly.

## Controls

- authenticated pull from vendor distribution;
- private registry only;
- TLS verification enabled;
- robot/service account per automation scope;
- short-lived credentials where supported;
- secret injection from a secret manager, never `.env` committed values;
- vulnerability policy with documented exception workflow;
- SBOM generation or ingestion;
- signature/provenance verification when vendor or enterprise process supports it;
- immutable approved repository;
- retention policy aligned with rollback/support requirements;
- audit trail for import, approval and promotion;
- deny unapproved registries at OpenShift policy level;
- deployment references use approved internal registry coordinates.

## Pega image families

Track each vendor-provided image independently rather than treating “Pega” as one image. The exact set and names are release-dependent and must be taken from the official Pega documentation/Helm values for the selected release. Typical architectural families include:

- Pega application/runtime image;
- Pega installer/upgrade image;
- Search and Reporting Service (SRS) components when required;
- clustering service components when required;
- other platform services required by the selected Pega release/product.

Do not invent vendor image names in production configuration. Git templates use variables until authorized coordinates are known.

## Example consumer variables

```dotenv
PEGA_RUNTIME_IMAGE=<internal-registry>/<repo>/<image>@sha256:<digest>
PEGA_INSTALLER_IMAGE=<internal-registry>/<repo>/<image>@sha256:<digest>
PEGA_SRS_IMAGE=<internal-registry>/<repo>/<image>@sha256:<digest>
PEGA_CLUSTERING_IMAGE=<internal-registry>/<repo>/<image>@sha256:<digest>
```

## Environment promotion gates

| Gate | Required evidence |
|---|---|
| Import -> Quarantine | source, version, digest, timestamp |
| Quarantine -> Approved | CVE policy result, SBOM, approval |
| Approved -> DEV | deployment manifest render + smoke prerequisites |
| DEV -> TEST | functional/integration evidence |
| TEST -> PREPROD | regression/security/performance evidence |
| PREPROD -> PROD | architecture/CAB approval + rollback target |

## Rollback

Rollback is a controlled redeployment of a previously approved digest plus any compatible database/application rollback procedure. A container-image rollback alone is **not** assumed safe after a Pega database schema upgrade.

## Gate I3

Complete at architecture level when the team can trace every deployed image from vendor entitlement to immutable digest, security approval and target environment without exposing a secret or proprietary image in Git.