# I8 — GitOps, CI/CD & Release Promotion

## Objective

Define how Pega platform configuration is promoted through environments using Git as the desired-state source while proprietary images and secrets remain outside Git.

> Status: **DESIGNED / GITOPS CONTROL PLANE CAN BE TESTED WITHOUT PEGA RUNTIME**.

## Target flow

```text
Architecture / app/platform change
            |
            v
Git pull request
            |
       static checks
            |
            +--> YAML/Helm validation
            +--> secret scan
            +--> policy checks
            +--> image provenance/digest checks
            |
            v
merge approved revision
            |
            v
Argo CD sync DEV
            |
            v
promotion PR -> TEST
            |
            v
promotion PR -> PREPROD
            |
            v
change approval -> PROD
```

## Separation of concerns

Git stores:

- Helm values and environment overlays;
- image coordinates/digests, when disclosure is acceptable;
- OpenShift manifests;
- Argo CD Applications/ApplicationSets;
- policies;
- release metadata;
- architecture decisions;
- test definitions and evidence metadata.

Git does **not** store:

- Pega image layers;
- registry access keys;
- database passwords;
- private TLS keys;
- OAuth client secrets;
- kubeconfigs;
- Pega licence/order-form data;
- production customer data.

## Promotion object

A release candidate is a tuple:

```text
Pega application release
+ vendor Helm chart pin
+ approved image digests
+ MayaBank configuration Git revision
+ database migration/install plan
```

Promotion is the approval of that tuple for the next environment, not a rebuild.

## Example release manifest

```yaml
apiVersion: mayabank.example/v1alpha1
kind: PegaRelease
metadata:
  name: pega-candidate
spec:
  pegaRelease: "<authorized-version>"
  vendorChartRef: "<pinned-ref>"
  configRevision: "<git-sha>"
  images:
    runtime: "<internal-registry>/<path>@sha256:<digest>"
    installer: "<internal-registry>/<path>@sha256:<digest>"
  databaseChange:
    required: true
    planRef: "docs/runbooks/database-upgrade.md"
```

This is a documentation contract in this repository, not a real Kubernetes CRD unless one is deliberately implemented later.

## Pipeline controls

Pre-merge:

- markdown/link checks where useful;
- YAML syntax;
- Helm lint/template against the pinned vendor chart;
- secret scanning;
- policy-as-code validation;
- prohibited-registry detection;
- required image digest presence for controlled environments;
- environment-drift checks.

Post-merge / deployment:

- Argo CD sync status;
- namespace health;
- route/TLS checks;
- dependency connectivity;
- smoke tests;
- Pega functional smoke test only when runtime is available;
- evidence capture with timestamps and Git/image versions.

## Environment promotion

| Environment | Promotion mechanism | Required approver class |
|---|---|---|
| DEV | merge to desired-state branch/path | engineering |
| TEST | promotion PR | engineering/QA |
| PREPROD | promotion PR | QA/platform/security as required |
| PROD | controlled promotion PR/change record | production/change authority |

The actual organization-specific approval workflow belongs in the customer's operating model; the portfolio keeps a generic architecture pattern.

## Database-aware rollback

Git rollback is not automatically a valid Pega rollback. If an installation or upgrade has changed database schemas/rules/data in a non-backward-compatible way, the recovery plan must follow the supported Pega/database procedure.

Therefore every production release must classify rollback as one of:

```text
A. configuration-only rollback
B. image rollback with DB compatibility confirmed
C. forward-fix required
D. database restore/recovery procedure required
```

## Evidence model

Each environment validation should capture:

```text
Timestamp
Cluster/context identifier (sanitized)
Namespace
Git revision
Vendor chart ref
Pega release
Image digests
Argo CD health/sync
Smoke-test result
Known limitations
Evidence status: STATIC / RUNTIME / HA-VALIDATED
```

## Gate I8

I8 is complete at architecture level when the same approved release tuple can be traced through DEV -> TEST -> PREPROD -> PROD, with Git approvals, immutable image identity, secret separation and database-aware rollback.