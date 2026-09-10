# Validation plan — from no licence to runtime evidence

## Stage 0 — now

No official Pega image entitlement is assumed.

Validate:

- architecture documentation;
- YAML contracts;
- repository secret/proprietary-artifact guard;
- registry and release metadata model;
- OpenShift generic controls with substitute images where useful.

Allowed claim: `DESIGNED` / `STATICALLY VALIDATED` / `PLATFORM VALIDATED` as evidence permits.

## Stage 1 — after vendor chart pin

Validate:

- official chart retrieval at explicit ref;
- mapping from MayaBank overlays to real Pega chart keys;
- `helm lint`;
- `helm template`;
- policy-as-code checks on rendered manifests.

No runtime claim yet.

## Stage 2 — after authorized Pega image access

Validate:

- vendor image acquisition;
- digest and image catalog;
- private registry mirror;
- image pull from OpenShift;
- supported database install/bootstrap;
- Pega startup and route;
- functional smoke test;
- sanitized runtime evidence.

Allowed claim after success: `RUNTIME VALIDATED` for that exact release/environment.

## Stage 3 — production-like infrastructure

Validate:

- multiple replicas/nodes/zones where required;
- dependency failures;
- node/pod failures;
- backup/restore;
- RTO/RPO measurement;
- upgrade and recovery scenarios.

Only then use `HA VALIDATED`, and only for properties actually tested.