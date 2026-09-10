# I6 — Database, SRS, Clustering & Integration Dependencies

## Objective

Make every non-Pega dependency explicit so that a Solution Architect can reason about supportability, ownership, failure modes and deployment order.

> Status: **DESIGNED / DEPENDENCY LABS CAN BE EXECUTED INDEPENDENTLY**.

## Dependency map

```text
                    Pega workloads
                         |
       +-----------------+------------------+
       |                 |                  |
       v                 v                  v
 Relational DB       SRS/Search        Clustering service
       |                                    |
       +-----------------+------------------+
                         |
             Integration endpoints
                         |
        +----------------+----------------+
        |                |                |
       API             Kafka             MQ
```

The exact components and supported versions must be taken from the selected Pega release documentation and support matrix. This repository deliberately does not freeze guessed vendor versions.

## Relational database

Architecture decisions to capture:

- supported engine/version for the selected Pega release;
- managed vs self-managed database;
- network path and TLS;
- schema model required by the selected install/upgrade method;
- connection pooling and capacity;
- backup/restore and PITR capabilities;
- HA/failover model;
- encryption at rest/in transit;
- maintenance/patch ownership;
- monitoring;
- upgrade sequencing with Pega installer jobs.

For local labs, PostgreSQL can be used only when it is supported for the chosen exercise. A lab database is not evidence for production sizing or supportability.

## Search and Reporting Service (SRS)

For releases where SRS is required/recommended, document:

- service topology and image(s);
- persistent state requirements, if any;
- endpoints/certificates;
- sizing;
- backup/recovery expectations;
- failure behavior from Pega's perspective;
- compatibility with the selected Pega release.

Do not substitute an arbitrary Elasticsearch/OpenSearch deployment and call it “Pega SRS”.

## Clustering service

For releases using a dedicated clustering service, document:

- cluster membership topology;
- discovery/service endpoints;
- replicas and anti-affinity for production;
- TLS/authentication where supported;
- startup dependency behavior;
- failure/recovery behavior;
- monitoring and capacity.

CRC can validate manifests/connectivity patterns but cannot prove a multi-zone clustering SLA.

## Kafka / event streaming

Kafka is treated as an integration dependency, not automatically as a mandatory platform component for every Pega use case.

For MayaBank Payment Investigation:

```text
Payment Core -> PaymentUnknown event -> Kafka -> integration adapter -> Pega Case
Pega Case -> outcome event -> Kafka -> downstream consumers
```

Required controls: schema/versioning, correlation ID, idempotence, bounded retries, DLQ/error topic, replay policy, audit and data classification.

## IBM MQ

MQ remains a valid integration choice for legacy/core-bank flows requiring queue semantics. Pega integration must document JMS/client compatibility, TLS, retry/backout, transactional boundaries and operational ownership.

## REST/API

Synchronous calls are preferred only when the business step needs an immediate response and timeout/failure behavior is explicit. Use OAuth/OIDC or mTLS according to the API security model; never embed static credentials in rules or Git.

## Dependency ownership matrix

| Dependency | Product owner | Platform owner | App team responsibility |
|---|---|---|---|
| Pega runtime | Pega/customer contract | Pega platform team | application configuration |
| Database | DB/platform team | infra/cloud team | schema/use within supported pattern |
| SRS | Pega platform team | platform team | application consumption |
| Clustering | Pega platform team | platform team | none beyond supported use |
| Kafka | event platform team | platform team | topics/contracts/consumers |
| MQ | messaging team | platform team | queues/contracts/integration |
| API gateway | API platform team | platform team | API contract/policy |

## Deployment-order rule

Infrastructure dependencies, networking, certificates and secrets must be ready before Pega installation jobs start. Database schema upgrades must be treated as release events with backup, compatibility and rollback analysis.

## Gate I6

I6 is complete when every required external service has a named owner, support/version decision, security model, failure mode and recovery strategy.