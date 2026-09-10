# I2 — Acceptance & Gate

## Scope

I2 selects and documents the Pega runtime baseline. It can complete the **architecture/preparation decision** without pretending that proprietary entitlements are available.

## Checklist

| Requirement | Evidence | Status |
|---|---|---|
| Audit `pega-docker-repo` | `docs/platform/I2_BASELINE_AUDIT.md` | DONE |
| Legacy/reuse/archive classification | baseline audit | DONE |
| Preferred Pega version selected | `docs/platform/I2_VERSION_RUNTIME_DECISION.md` | DONE — 26.1.1 preferred |
| Fallback defined | version decision | DONE — 25.1.3 if justified |
| Official Kubernetes/OpenShift deployment path | version decision + ADR-004 | DONE |
| Registry strategy | prerequisites + access matrix | DONE |
| Database strategy | version decision + prerequisites | DONE, exact DB major CHECK AT RUN |
| Customer Service access rule | access matrix | DONE — entitlement required |
| Constellation access rule | access matrix | DONE — entitlement/version check |
| CDH access rule | access matrix | DONE — entitlement required |
| SRS/backing-service rule | version decision | DONE — compatibility check at run |
| Pega binary/image policy | ADR-004 | DONE |
| CRC preflight requirements | `docs/platform/I2_OPENSHIFT_PREREQUISITES.md` | DONE |
| Runtime evidence requirements | version decision + prerequisites | DONE |

## External blockers that cannot be fabricated

The following facts require the user's Pega account/environment and therefore remain **external runtime gates**, not missing architecture work:

- actual entitlement to Pega Platform 26.1.1 images/install artifacts ;
- actual entitlement to Pega Customer Service ;
- actual entitlement to Customer Decision Hub ;
- actual availability/configuration of Constellation for the selected application ;
- exact supported PostgreSQL/JDBC versions for the entitled patch ;
- actual available CPU/RAM/storage on the user's CRC at execution time.

## Gate result

**I2 ARCHITECTURE/PREPARATION: PASS.**

**I2 RUNTIME ENTITLEMENT GATE: PENDING EXTERNAL VERIFICATION.**

This distinction is intentional. I3 can be completed as **deployment-ready infrastructure-as-code and runbooks**, but it cannot be marked `RUNTIME VALIDATED` until the user runs the deployment with authorized Pega artifacts on a real CRC/OpenShift cluster.

## Next action

Proceed to I3 implementation:

```text
OpenShift guardrails
 -> secret creation pattern
 -> PostgreSQL lab option
 -> Pega Helm values template
 -> preflight
 -> install/deploy script
 -> verify/smoke/evidence script
 -> rollback/cleanup
```
