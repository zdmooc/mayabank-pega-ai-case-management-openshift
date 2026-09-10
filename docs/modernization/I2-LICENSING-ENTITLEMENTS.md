# I2 — Pega Licensing, Entitlements & Product Access

## Objective

Define how an enterprise acquires the legal and technical right to run Pega products and retrieve the corresponding software/container artifacts before any deployment is attempted.

> Status: **DESIGNED / REQUIRES CUSTOMER ENTITLEMENT FOR RUNTIME**.

## Scope

This iteration covers the architecture and operating model for:

- Pega Platform / Pega Infinity;
- Pega Customer Service;
- Pega Customer Decision Hub (CDH) / Next-Best-Action where licensed;
- Constellation capabilities included in the selected product/version;
- client-managed deployments (on-premises, private cloud, OpenShift/Kubernetes);
- Pega Cloud as a managed-service alternative;
- software distribution and support lifecycle.

## Three deployment responsibility models

| Model | Runtime operated by | Infrastructure operated by | Container images handled by customer | Typical use |
|---|---|---|---|---|
| Pega Cloud | Pega | Pega | No, except integration-side artifacts | Managed SaaS/PaaS-style operating model |
| Client-managed cloud | Customer/partner | Customer/partner | Yes | OpenShift, AKS, EKS, GKE, private cloud |
| On-premises self-managed | Customer/partner | Customer/partner | Yes | Datacenter/private infrastructure |

The exact contractual scope, metrics, product rights, non-production rights and disaster-recovery rights must always be checked against the customer's current Pega order form and support terms. This repository does not attempt to reproduce proprietary licence terms.

## Entitlement chain

```text
Commercial agreement / order form
            |
            v
Pega customer account / authorized user
            |
            v
Product entitlement + support rights
            |
            v
Authorized software/container distribution access
            |
            v
Credential / access key / registry authentication
            |
            v
Approved enterprise acquisition process
            |
            v
Internal registry / Artifactory / Quay
            |
            v
OpenShift deployment
```

## Architect checklist

Before approving a deployment, verify:

1. The exact Pega product and release are contractually entitled.
2. The target deployment model is allowed by the agreement.
3. Production and non-production environments are covered.
4. Required companion products/services are licensed or otherwise entitled.
5. The organization is authorized to obtain the official container images.
6. Registry credentials/access keys are stored outside Git.
7. Support lifecycle and target upgrade path are known.
8. Backup/PRA/DR environments are reviewed from both technical and contractual perspectives.
9. Third-party dependencies (database, OpenShift, Artifactory, observability, IAM) have their own licences/subscriptions reviewed separately.
10. No Pega proprietary binary, image layer, pull credential, licence file or customer-specific contract data is committed to this repository.

## Product capability matrix to maintain per customer

| Capability | Product / entitlement question | Runtime dependency | Repository treatment |
|---|---|---|---|
| Core case management | Is Pega Platform/Infinity entitled? | Pega runtime | Architecture + placeholders only |
| Customer Service | Is the Customer Service product entitled? | Product rules/application package | `DESIGNED ONLY` until access |
| Customer Decision Hub | Is CDH entitled? | CDH application/services | `DESIGNED ONLY` until access |
| Constellation | Is supported by target product/release and application architecture? | UI/static-service architecture depending on release | Design + compatibility matrix |
| Search/Reporting services | Required/supported for target release? | Pega platform services | Helm placeholders + topology |
| Clustering services | Required/supported for target release? | Pega platform services | Helm placeholders + topology |

## Evidence policy

A licensing or entitlement statement is never marked `VALIDATED` solely because public documentation mentions a feature. Runtime evidence requires customer-authorized access and must be recorded without exposing credentials or proprietary artifacts.

Allowed evidence examples:

- redacted screenshot showing authorized product/version access;
- sanitized registry login success metadata (never the secret/token);
- image repository/tag/digest metadata with no credential;
- Helm render using authorized image coordinates redacted when necessary;
- support/version matrix reference.

## Gate I2

I2 is complete at architecture level when the team can answer:

- Which Pega products are required?
- Which deployment model is selected?
- Who operates platform, infrastructure, database and upgrades?
- How are official artifacts obtained lawfully?
- Which environments are covered?
- Which items cannot be executed yet because entitlement is missing?

Runtime deployment remains blocked until authorized Pega artifacts are available.