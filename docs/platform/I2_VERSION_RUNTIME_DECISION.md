# I2 — Version / Runtime / Deployment Decision

## Decision date

2026-09-10.

## Target version

### Preferred target

**Pega Platform Infinity '26 — 26.1.1**, sous réserve que l'utilisateur dispose des droits, images et produits nécessaires.

Raison : la documentation publique Pega liste 26.1.1 comme patch Infinity '26 publié le **1er septembre 2026**. Infinity '26 est GA depuis le 14 juillet 2026.

### Fallback target

**Pega Platform Infinity '25 — 25.1.3** uniquement si entitlement, compatibilité produit ou disponibilité des artefacts rend 26.1.1 impossible dans le lab.

Le fallback n'est pas automatique : il doit être enregistré dans une ADR mise à jour avec la cause.

## Official deployment baseline

Source de référence : dépôt officiel Pegasystems `pega-helm-charts` et documentation Pega d'installation/update.

- Helm 3+ ;
- Pega Docker images autorisées et accessibles via registry ;
- provider OpenShift configuré avec `openshift` ;
- base SQL supportée et accessible ;
- chart `pega/pega` ;
- `pega/backingservices` lorsque SRS/backing services sont nécessaires ;
- installation initiale avec action `install-deploy`, puis déploiements ultérieurs sans réinstaller le schéma.

La documentation OpenShift publique Pegasystems indique un support de **Red Hat OpenShift Container Platform self-managed**. Le lab CRC est utilisé comme environnement de développement local ; il ne constitue pas une preuve de HA ou de support production.

## Helm chart strategy

Ne pas copier une version ancienne du chart dans le dépôt comme vérité permanente.

Au moment du run :

```bash
helm repo add pega https://pegasystems.github.io/pega-helm-charts
helm repo update
helm search repo pega --versions
helm show values pega/pega > evidence/runtime/pega-chart-values.txt
```

Le runbook public consulté le 2026-09-10 montre `pega/pega` chart **2.2.0**. Le script de préflight doit néanmoins relever la version réellement sélectionnée et l'enregistrer dans `evidence/runtime/VERSIONS.md`.

## Products / capabilities

| Capability | Design target | Runtime claim before entitlement |
|---|---|---|
| Pega Platform | 26.1.1 preferred | NOT VALIDATED |
| Case Management | required | NOT VALIDATED |
| Constellation | target UX | NOT VALIDATED |
| Pega Customer Service | target CRM product if entitled | NOT VALIDATED |
| Customer Decision Hub | optional advanced decisioning if entitled | NOT VALIDATED |
| SRS / search & reporting | according to version requirements | NOT VALIDATED |
| Pega GenAI services | later I9 and only if licensed/configured | NOT VALIDATED |

## Runtime topology target

### CRC lab

```text
OpenShift Local / CRC
  namespace: mayabank-pega
    Pega web/runtime via official Helm mechanism
    integration adapters / mocks
    PostgreSQL lab OR externally reachable supported PostgreSQL
    optional backing services according to selected Pega version
```

CRC is **single-node**. It can validate manifests, route, connectivity, application access and functional flows, not worker/zone/site resilience.

### Enterprise target

```text
OpenShift self-managed
  -> multiple worker nodes
  -> separated Pega tiers/node roles as supported
  -> external/HA database
  -> SRS/search services as required
  -> externalized Kafka where architecture requires it
  -> ingress/route TLS
  -> secrets and registry controls
  -> observability
  -> backup/PRA
```

## Database decision

For the local reference lab, use **PostgreSQL** because the official OpenShift deployment guide demonstrates Pega with PostgreSQL. Exact PostgreSQL major version and driver must be checked against the selected Pega 26.1.1 support matrix before runtime installation.

Therefore the repo does **not** hard-code an unsupported PostgreSQL major version as a Pega production requirement. A lab manifest can provide a placeholder PostgreSQL service, but the preflight gate must confirm compatibility before executing the Pega database installer.

## Search / stream decisions

- Search/reporting architecture must follow the selected Infinity version and SRS compatibility guidance.
- For stream/event processing, prefer an **externalized Kafka** architecture in the enterprise target when applicable. The existing MayaBank Kafka repositories are reused rather than embedding a second full Kafka platform here.
- Do not treat Kafka required by Pega internals and business-domain event streaming as automatically the same lifecycle/security domain; document the integration before merging them.

## Runtime evidence required

Before any `RUNTIME VALIDATED` claim, record:

- `oc version` ;
- `crc version` ;
- `helm version` ;
- selected Helm chart version ;
- Pega image tags/digests without credentials ;
- Pega application version ;
- DB version ;
- OpenShift namespace ;
- install command with secrets redacted ;
- pod status ;
- route ;
- smoke test result ;
- timestamp.

## External references

- Pega installation/update roadmap: `https://support.pega.com/installation-and-update-information-pega-products`
- Official Helm charts: `https://github.com/pegasystems/pega-helm-charts`
- OpenShift deployment guide: `https://github.com/pegasystems/pega-helm-charts/blob/master/docs/Deploying-Pega-on-openshift.md`

## Decision

**Architecture baseline selected: Infinity 26.1.1 preferred + official Helm/OpenShift deployment path.**

**Entitlement/image access remains an external gate and cannot be inferred from GitHub.**
