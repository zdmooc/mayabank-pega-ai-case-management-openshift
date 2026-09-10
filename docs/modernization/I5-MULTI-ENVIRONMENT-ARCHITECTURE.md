# I5 — Multi-Environment Architecture

## Objective

Define a repeatable Pega platform promotion model from local engineering through production while keeping configuration differences explicit and minimizing environment drift.

> Status: **DESIGNED / PLATFORM LAYERS CAN BE TESTED WITHOUT PEGA IMAGES**.

## Environments

| Environment | Purpose | Availability target | Data policy | Pega image source |
|---|---|---|---|---|
| LOCAL/CRC | Developer architecture lab | single-node, non-HA | synthetic only | approved placeholder/substitute until entitled |
| DEV | integration and configuration | non-production | synthetic/masked | approved internal registry |
| TEST | functional/integration regression | non-production | synthetic/masked | same approved digest promoted from DEV |
| PREPROD | production-like validation | production-like where feasible | masked/synthetic | same candidate digest |
| PROD | business service | HA/PRA according to SLO | governed production data | exact approved digest |

CRC is never used as evidence for multi-worker, multi-zone HA or production capacity.

## Configuration layering

```text
values/common.yaml
      |
      +--> values/local.yaml
      +--> values/dev.yaml
      +--> values/test.yaml
      +--> values/preprod.yaml
      +--> values/prod.yaml
```

Environment overlays should contain only real differences such as replica counts, endpoints, resource sizing, route hostnames, external service references and observability targets. Common Pega behavior belongs in `common.yaml`.

## Promotion principle

```text
Git revision R
Image digest D
Chart revision C
      |
      v
DEV validation
      |
      v
TEST validation
      |
      v
PREPROD validation
      |
      v
PROD approval
```

The target is to promote the same `(R, D, C)` release candidate rather than rebuild artifacts per environment.

## Environment contract

Each environment must record:

- Pega release and product set;
- Helm chart pin;
- exact container digests;
- OpenShift cluster/namespace identifier;
- database endpoint alias and schema strategy;
- route/DNS/TLS ownership;
- external IAM endpoint;
- Kafka/MQ/API endpoints where applicable;
- resource requests/limits and replicas;
- storage class and persistence requirements;
- backup policy;
- observability destinations;
- change/approval policy;
- data classification and masking rule.

## Production separation

Production secrets, customer data, registry credentials and private endpoints are never represented with literal values in this public portfolio. Only variable names, patterns and synthetic examples are versioned.

## Gate I5

I5 is complete when a reviewer can compare two environments and identify every intended difference from Git, while the same approved image digest can be traced through the promotion chain.