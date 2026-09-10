# I2 — Component Access / Entitlement Matrix

## Purpose

Separate **architecture intent** from **what can actually be executed** with the user's available Pega entitlements. This prevents the portfolio from claiming Customer Service, CDH, Constellation or GenAI execution without access evidence.

## Matrix

| Component | Needed for | Required for I3? | Evidence required | Current status |
|---|---|---:|---|---|
| Pega Platform Infinity 26.1.1 | base runtime / Case Management | YES | authorized image/installer access | EXTERNAL CHECK REQUIRED |
| Pega database installer image/artifacts | initial DB installation | YES | authorized artifact/image access | EXTERNAL CHECK REQUIRED |
| Pega web/runtime image | runtime | YES | authorized registry/image access | EXTERNAL CHECK REQUIRED |
| PostgreSQL + JDBC driver compatible with selected Pega version | database | YES | support-matrix confirmation | CHECK AT RUN |
| Helm `pega/pega` | deployment | YES | public chart reachable | PUBLIC / PRECHECK SCRIPT |
| SRS / backing services | search/reporting according to version | MAYBE | compatibility/version decision | CHECK AT RUN |
| Pega Customer Service | CRM POC | NO for platform deployment; YES for product demo | product entitlement/application access | EXTERNAL CHECK REQUIRED |
| Constellation | modern UX | NO for basic I3 | version/application support | EXTERNAL CHECK REQUIRED |
| Customer Decision Hub | NBA/decisioning POC | NO | product entitlement | EXTERNAL CHECK REQUIRED |
| Pega GenAI services | I9 | NO | license/config + provider setup | EXTERNAL CHECK REQUIRED |

## Allowed statuses

- `PUBLIC` — public source/tool accessible without proprietary entitlement.
- `AVAILABLE` — user has verified legal/technical access.
- `CONFIGURED` — configuration exists but execution not proven.
- `DEPLOYED` — component exists in target cluster.
- `RUNTIME VALIDATED` — functional evidence recorded.
- `EXTERNAL CHECK REQUIRED` — ChatGPT/GitHub cannot infer entitlement.
- `DESIGNED ONLY` — architecture can be documented but not executed.

## Gate script input

The runtime scripts will expect the user to set non-secret metadata and create secrets locally/inside OpenShift. Git will never contain registry passwords or Pega credentials.

Recommended local variables:

```text
PEGA_VERSION=26.1.1
PEGA_HELM_CHART_VERSION=<selected>
PEGA_WEB_IMAGE=<authorized registry/repository:tag>
PEGA_INSTALL_IMAGE=<authorized registry/repository:tag>
PEGA_NAMESPACE=mayabank-pega
PEGA_ROUTE_DOMAIN=<crc/apps domain or selected domain>
POSTGRES_HOST=<service-or-host>
POSTGRES_PORT=5432
POSTGRES_DB=pega
POSTGRES_USER=<local secret value>
```

Passwords/tokens must be provided through OpenShift Secret creation or an external secret manager, never committed.

## Customer Service fallback

If Pega Customer Service product access is unavailable, the portfolio may still implement a **Customer Service-like Case Management demo** using base Pega Platform concepts, but the README must call it exactly that and must not claim that Pega Customer Service product was installed.

## CDH fallback

If CDH is unavailable, document NBA architecture and use a deterministic mock/ODM integration for the runtime. Do not label the mock as CDH.

## Constellation fallback

If Constellation is not available/supported in the selected application, keep the Constellation design and DX API study as `DESIGNED ONLY`, while validating the underlying Case Management through the available UI/API.

## Decision

I3 may proceed to **deployment-ready implementation** before entitlement is resolved, but the final `helm install` and runtime evidence gate remains blocked until Pega artifacts are actually available.
