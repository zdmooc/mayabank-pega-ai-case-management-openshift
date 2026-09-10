# I2 — Acceptance & Gate

## Scope

I2 sélectionne et documente la baseline runtime. Après audit du package local, le projet distingue désormais une baseline legacy réellement disponible d'une architecture cible moderne non licenciée.

## Checklist

| Requirement | Evidence | Status |
|---|---|---|
| Audit `pega-docker-repo` | `I2_BASELINE_AUDIT.md` | DONE |
| Audit package Pega PE 8.4.0 | `I2_BASELINE_AUDIT.md` + dépôt privé d'audit | DONE |
| Baseline legacy identifiée | Pega PE 8.4.0 / Java 8u121 / Tomcat 8.x / PostgreSQL embarqué | DONE |
| Hash `prweb.war` relevé | inventaire SHA-256 privé | DONE |
| JDBC legacy identifié | `postgresql-42.0.0.jar` | DONE |
| Version Tomcat exacte | collecte locale | PENDING RUNTIME EVIDENCE |
| Version PostgreSQL exacte | collecte locale | PENDING RUNTIME EVIDENCE |
| État/base Pega existante | collecte locale | PENDING RUNTIME EVIDENCE |
| Architecture cible moderne | Infinity 26.1.1 + Helm/OpenShift | DONE AS DESIGN |
| Entitlement Pega 26 | compte/licence opérateur | NOT AVAILABLE |
| Customer Service entitlement | compte/licence opérateur | NOT AVAILABLE |
| CDH entitlement | compte/licence opérateur | NOT AVAILABLE |
| Constellation availability | runtime moderne | NOT VALIDATED |
| Politique binaires/secrets | `.gitignore` + audit | DONE |
| CRC guardrails | I2 prerequisites + I3 | DONE AS DESIGN |

## Gate result

**I2 ARCHITECTURE/PREPARATION: PASS.**

**I2 LEGACY ARTIFACT INVENTORY: PASS.**

**I2 LEGACY RUNTIME VALIDATION: PENDING LOCAL EXECUTION.**

**I2 MODERN ENTITLEMENT GATE: BLOCKED — no current Pega 26 license/images.**

Ce blocage ne remet pas en cause la conception. Il interdit seulement d'affirmer que Pega 26, Customer Service, CDH ou Constellation ont été exécutés.

## Transition I3

I3 conserve deux voies :

```text
Track A — legacy-pe84-local
  collect evidence -> prove startup -> identify DB/config -> optional container/OpenShift experiment

Track B — modern-pega26-openshift
  manifests/scripts/runbook ready -> wait for authorized images -> execute later
```
