# Backlog moderne — MayaBank Pega Solution Architecture

> Cible : **Architecte Solution Pega — CRM / Customer Service / Case Management / Decisioning / OpenShift — Certified SA & SSA**
>
> Baseline : architecture Pega moderne, sans dépendre d’un ancien Personal Edition. Toute fonction nécessitant un entitlement ou une image Pega officielle reste `DESIGNED`/`STATICALLY VALIDATED` tant que l’accès n’est pas disponible.

## Légende

- `[x]` architecture/configuration livrée dans Git ;
- `[~]` partiellement exécutable, runtime Pega bloqué ;
- `[ ]` restant à faire ;
- `RUNTIME VALIDATED` uniquement avec preuve d’exécution Pega autorisée.

## I0 — Cadrage / Architecture

- [x] Positionnement Architecte Solution Pega.
- [x] Fil rouge MayaBank Customer Service & Payment Investigation.
- [x] Second vertical MayaInsurance Claims.
- [x] Séparation Pega orchestrateur / Core système de record.
- [x] Politique d’evidence et de claims.

## I1 — CRM / Customer Service / Case Model

- [x] Architecture métier et Case Model initial.
- [x] Customer Service / Customer 360 / Payment Investigation cadrés.
- [x] Principes SLA/routing/audit/data ownership définis au niveau architecture.
- [~] Runtime Customer Service réel dépend du produit/licence Pega.

## I2 — Licences / produits / entitlements — ARCHITECTURE COMPLETE

- [x] Pega Cloud vs Client-Managed vs On-Prem responsibilities.
- [x] Chaîne contrat -> entitlement -> software distribution -> registry.
- [x] Checklist produits/environnements/support/DR.
- [x] Template d’entitlement nettoyé.
- [x] Politique : aucun contrat/licence/token dans Git.
- [~] Validation contractuelle réelle dépend d’un client/entitlement.

Livrables : `docs/modernization/I2-LICENSING-ENTITLEMENTS.md`, `platform/pega/licensing/`.

## I3 — Images / Registry / Artifactory / Supply Chain — ARCHITECTURE COMPLETE

- [x] Vendor acquisition -> quarantine -> scan/SBOM -> approval -> approved registry.
- [x] Modèle Artifactory local/remote/virtual.
- [x] Catalogue image/digest/SBOM/scan/approval.
- [x] Promotion du même digest DEV -> TEST -> PREPROD -> PROD.
- [x] Politique anti-`latest` / approved registry.
- [x] Guard contre WAR/JAR/ZIP/secrets dans Git.
- [~] Test registry possible avec images substitutives.
- [ ] Pull/mirror Pega réel après entitlement.

Livrables : `docs/modernization/I3-REGISTRY-IMAGE-GOVERNANCE.md`, `platform/pega/registry/`, `platform/pega/artifactory/`.

## I4 — Helm officiel Pega / OpenShift — ARCHITECTURE COMPLETE

- [x] `pegasystems/pega-helm-charts` défini comme source vendor de référence.
- [x] Politique de pin chart release/commit.
- [x] Séparation vendor chart / overlays MayaBank.
- [x] Topologie runtime/dépendances définie au niveau architecture.
- [ ] Choisir/piner le chart exact compatible avec la release autorisée.
- [ ] Mapper les overlays vers les vraies clés du chart.
- [ ] `helm lint` / `helm template` et policies.
- [ ] Runtime Pega après accès images.

Livrables : `docs/modernization/I4-HELM-OPENSHIFT-ARCHITECTURE.md`, `platform/pega/helm/`.

## I5 — LOCAL / DEV / TEST / PREPROD / PROD — ARCHITECTURE COMPLETE

- [x] Matrice des environnements.
- [x] Common + overlays LOCAL/DEV/TEST/PREPROD/PROD.
- [x] Politique same-digest promotion.
- [x] Politique données synthétiques/masquées hors PROD.
- [x] CRC explicitement exclu des preuves HA.
- [ ] Valider les contrôles plateforme sur CRC.
- [ ] Déployer vers vraies plateformes non-prod lorsque disponibles.

Livrables : `docs/modernization/I5-MULTI-ENVIRONMENT-ARCHITECTURE.md`, `platform/pega/values/`, `platform/pega/multi-env/`.

## I6 — DB / SRS / Clustering / API / Kafka / MQ — ARCHITECTURE COMPLETE

- [x] Dependency map.
- [x] Ownership matrix.
- [x] Database architecture checklist.
- [x] SRS et clustering traités comme release-dependent.
- [x] API/Kafka/MQ integration responsibilities.
- [ ] Vérifier versions/support matrix lorsque release Pega autorisée choisie.
- [ ] Exécuter les labs dépendances utiles.

Livrables : `docs/modernization/I6-PLATFORM-DEPENDENCIES.md`, `platform/pega/dependencies/`.

## I7 — IAM / TLS / Secrets / RBAC / Network — ARCHITECTURE COMPLETE

- [x] Human vs service identities.
- [x] Secret classes et stockage externe.
- [x] TLS/PKI/rotation responsibilities.
- [x] Namespace/RBAC/SCC/NetworkPolicy principles.
- [x] Secret/proprietary-artifact CI guard.
- [ ] Test RBAC/NetworkPolicies/TLS sur CRC.
- [ ] Intégration IdP réelle quand environnement disponible.

Livrables : `docs/modernization/I7-SECURITY-IAM-SECRETS.md`, `platform/pega/security/`, `scripts/modern/`.

## I8 — GitOps / Argo CD / Release Promotion — ARCHITECTURE COMPLETE

- [x] Release tuple : Pega release + chart ref + image digests + config Git + DB plan.
- [x] Release manifest exemple.
- [x] Promotion PR DEV -> TEST -> PREPROD -> PROD.
- [x] Rollback class DB-aware.
- [x] GitHub Architecture Guard.
- [ ] Valider Argo CD sur CRC.
- [ ] Ajouter render/validation du vrai chart Pega après pin.
- [ ] Runtime GitOps Pega après entitlement.

Livrables : `docs/modernization/I8-GITOPS-PROMOTION.md`, `platform/pega/release/`, `platform/pega/gitops/`.

## I9 — Installation / patch / upgrade / rollback

- [ ] Runbooks installation DB + Pega.
- [ ] Patch/upgrade sequencing.
- [ ] Zero/near-zero downtime pattern selon support release.
- [ ] Database-aware rollback / forward-fix matrix.
- [ ] Tests statiques puis runtime.

## I10 — Observability / SRE

- [ ] PDC responsibilities.
- [ ] Logs/métriques/traces.
- [ ] SLO/SLI et alerting.
- [ ] Health dashboards et evidence.

## I11 — HA / PRA / Backup / Restore

- [ ] Multi-node/multi-zone HLD.
- [ ] PDB/anti-affinity/topology spread selon support.
- [ ] DB/SRS/clustering failure domains.
- [ ] Backup/restore.
- [ ] RPO/RTO.
- [ ] Tests de panne uniquement sur infra adaptée.

## I12 — Sizing / Performance / Capacity / Cost

- [ ] Workload model.
- [ ] Requests/limits/replicas.
- [ ] DB/SRS sizing.
- [ ] Load/performance test plan.
- [ ] Capacity and FinOps model.

## I13 — Pega Cloud vs Client-Managed vs On-Prem

- [ ] Decision matrix complète.
- [ ] RACI opérations/sécurité/upgrade/DR.
- [ ] Contraintes souveraineté/coût/SLA/intégration.
- [ ] Architecture de connectivité Pega Cloud.

## I14 — Migration Pega 8.x -> modern Infinity / Constellation

- [ ] Assessment application/rules/UI/integrations.
- [ ] Compatibility/dependency inventory.
- [ ] Migration waves.
- [ ] Traditional UI -> Constellation decision framework.
- [ ] Cutover/rollback/data plan.

## I15 — Customer Service / Customer 360 / Constellation

- [ ] Customer Service product architecture.
- [ ] Customer 360 ownership/access patterns.
- [ ] Constellation views.
- [ ] Agent journey runtime when entitled.
- [ ] SLA/routing/audit demo.

## I16 — CDH / Decisioning / AI-GenAI

- [ ] Pega rules vs CDH vs ODM decision matrix.
- [ ] NBA strategy.
- [ ] Case summarization/RAG/procedure assistant.
- [ ] Guardrails, provenance, HITL.
- [ ] AI failure must not block essential deterministic processing.

## I17 — Portfolio final / HLD / LLD / Architecture Board

- [ ] HLD final.
- [ ] LLD plateforme.
- [ ] ADR/DAT set.
- [ ] Threat model.
- [ ] Requirements -> architecture -> tests -> evidence matrix.
- [ ] `CV_MAPPING.md`.
- [ ] Démo 20-30 min.
- [ ] Architecture Board pack.
- [ ] README final avec status exact.

## Prochain lot recommandé

**I9 -> I12** peut être enchaîné en architecture/runbooks sans image Pega. En parallèle, exécuter sur CRC les validations plateforme restantes de I3/I5/I7/I8. Le runtime Pega reste bloqué jusqu’à entitlement/images officielles.