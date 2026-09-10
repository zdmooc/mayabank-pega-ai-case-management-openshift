# Backlog — MayaBank Pega AI Case Management on OpenShift

> Statut : **PARKED / À RÉALISER PLUS TARD**. Ce backlog est le point de reprise officiel.

## Règles de travail

- [ ] Ne jamais déclarer `TESTED`, `VALIDATED`, `HA`, `RPO` ou `RTO` sans preuve versionnée.
- [ ] Utiliser uniquement des données fictives/synthétiques MayaBank/MayaInsurance.
- [ ] Ne jamais committer de secret, kubeconfig, pull secret, mot de passe ou binaire propriétaire non autorisé.
- [ ] Réutiliser les autres dépôts avant de réimplémenter Kafka, MQ, ODM, IAM, observabilité ou Azure.
- [ ] Distinguer `DESIGNED`, `CONFIGURED`, `DEPLOYED`, `RUNTIME VALIDATED`.
- [ ] Chaque itération doit produire docs + code/config + tests + evidence avant clôture.

---

## I0 — Cadrage / Architecture / DoD — EN PLACE

- [x] README initial.
- [x] Architecture cible complète.
- [x] Backlog global.
- [x] Définir Payment Investigation comme premier vertical.
- [x] Prévoir Insurance Claims comme second vertical réutilisant le même socle.
- [ ] Ajouter `docs/adr/` avec ADR-001 à ADR-012.
- [ ] Ajouter diagrammes PlantUML/Mermaid/SVG.
- [ ] Ajouter matrice de traçabilité exigences -> architecture -> tests -> evidence.

**Gate I0** : aucun runtime requis.

---

## I1 — Domaine métier / Case Management

### Payment Investigation
- [ ] Définir personas : Payment Ops, Fraud Analyst, Supervisor, SRE, Auditor.
- [ ] Définir `PAYMENT_UNKNOWN`, `FRAUD_REVIEW`, `RECONCILIATION_BREAK`, `DUPLICATE_PAYMENT`, `REFUND_REQUEST`, `RECALL_REQUEST`.
- [ ] Définir Case Types, stages, steps, assignments, work queues, SLA et escalation.
- [ ] Construire state machine canonique.
- [ ] Construire BPMN/process flow.
- [ ] Définir data model case.
- [ ] Définir business outcomes et KPI.
- [ ] Définir règles de clôture et reopen.
- [ ] Définir audit requirements.

### Insurance Claims
- [ ] Définir extension Claims Investigation sans dupliquer la plateforme.

**Livrables** : `docs/domain/`, BPMN, state machine, use-case catalog.

---

## I2 — Baseline Pega / prérequis / licence

- [ ] Auditer `pega-docker-repo` et extraire uniquement ce qui reste utile.
- [ ] Identifier version Pega cible au moment de l’exécution.
- [ ] Vérifier prérequis/licences/images autorisées.
- [ ] Vérifier documentation de déploiement Pega sur Kubernetes/OpenShift correspondant à la version retenue.
- [ ] Définir registry/image pull strategy.
- [ ] Définir base de données supportée pour le lab.
- [ ] Définir dépendances externes Pega nécessaires à la version choisie.
- [ ] Décider : réutilisation baseline Docker ou nouveau déploiement propre.
- [ ] Écrire ADR-012.

**Gate** : ne pas poursuivre au runtime Pega tant que licence/images/version ne sont pas claires.

---

## I3 — Pega sur OpenShift Local / CRC

- [ ] Créer namespace/projet lab.
- [ ] ResourceQuota / LimitRange.
- [ ] ServiceAccount / RBAC.
- [ ] Secret pattern sans valeur réelle dans Git.
- [ ] Storage/PVC.
- [ ] Database lab.
- [ ] Déployer Pega avec mécanisme supporté pour la version choisie.
- [ ] Service / Route TLS.
- [ ] Readiness/liveness probes selon capacités supportées.
- [ ] NetworkPolicies.
- [ ] Requests/limits.
- [ ] Smoke test UI/API.
- [ ] Documenter limites CRC mono-nœud.
- [ ] Capturer evidence.

**Gate** : Pega réellement accessible sur CRC ou, si licence indisponible, architecture explicitement marquée `DESIGNED ONLY`.

---

## I4 — Payment Investigation vertical

- [ ] Créer case `PAYMENT_UNKNOWN`.
- [ ] Recevoir événement depuis mock/payment core.
- [ ] Corréler `caseId`, `paymentId`, `correlationId`.
- [ ] Lire détails paiement via API.
- [ ] Afficher evidence opérateur.
- [ ] Human task Investigation.
- [ ] Workflow WAITING_EXTERNAL / WAITING_APPROVAL.
- [ ] Resolution request vers core simulé.
- [ ] Outcome event.
- [ ] Closure + audit.
- [ ] Tests E2E nominal + unknown + duplicate + timeout.

**Réutilisation** : `wero-organisme-poc`.

---

## I5 — API Management / Security

- [ ] Définir APIs OpenAPI 3.1.
- [ ] Case API.
- [ ] Payment read API.
- [ ] Resolution command API.
- [ ] Decision API.
- [ ] OAuth2/OIDC.
- [ ] SSO / personas.
- [ ] mTLS cible si nécessaire.
- [ ] API gateway policy.
- [ ] Rate limits / quotas.
- [ ] Correlation ID.
- [ ] Idempotency-Key.
- [ ] Error model.
- [ ] Security tests.

**Réutilisation** : `mayabank-api-management-architecture`, `keycloak-enterprise-roadmap-v7`.

---

## I6 — Kafka / Event-Driven

- [ ] AsyncAPI.
- [ ] Topics/events.
- [ ] Partition key strategy.
- [ ] Producer idempotence.
- [ ] Consumer idempotence.
- [ ] Outbox/inbox si nécessaire.
- [ ] Retry/DLQ/quarantine.
- [ ] Replay contrôlé.
- [ ] Duplicate and out-of-order tests.
- [ ] Lag/consumer observability.

**Réutilisation** : `mayabank-kafka-ddd-openshift`, `kafka-expert`, `wero-organisme-poc`.

---

## I7 — IBM MQ / legacy integration

- [ ] Définir cas nécessitant MQ plutôt que Kafka/API.
- [ ] Request/reply JMS.
- [ ] Persistent messages.
- [ ] Transactions.
- [ ] Backout threshold.
- [ ] Backout queue.
- [ ] DLQ.
- [ ] Poison message.
- [ ] Retry borné.
- [ ] Correlation ID.
- [ ] Consumer restart.
- [ ] Option bridge MQ -> Kafka.
- [ ] Tests et evidence.

**Réutilisation obligatoire** : `mayabank-ibm-mq-native-ha-openshift-eda-platform`.

---

## I8 — IBM ODM / Decision Management

- [ ] Définir décision déterministe de triage/résolution.
- [ ] Decision API contract.
- [ ] Policy version.
- [ ] Reason codes.
- [ ] Human review flag.
- [ ] Pega -> ODM integration.
- [ ] Fallback ODM unavailable.
- [ ] Audit decision.
- [ ] Tests de non-contournement des règles.

**Réutilisation** : `mayabank-ibm-odm-ai-decision-architecture`.

---

## I9 — AI / RAG / Agent assistant

- [ ] Définir AI Gateway interface.
- [ ] RAG corpus synthétique : procédures paiement/claims.
- [ ] Case summary.
- [ ] Recommended next investigation step.
- [ ] Document extraction/classification.
- [ ] Confidence score.
- [ ] Retrieval provenance/citations.
- [ ] Prompt registry/versioning.
- [ ] Tool allow-list.
- [ ] MCP tool scopes si retenu.
- [ ] Human-in-the-loop obligatoire pour actions sensibles.
- [ ] Model/provider fallback.
- [ ] Prompt injection tests.
- [ ] Hallucination/grounding evaluation.
- [ ] Audit model/prompt/tool calls.
- [ ] Cost/token metrics.
- [ ] Démontrer que panne AI n’empêche pas le traitement manuel essentiel.

**Réutilisation** : `TradeOps-GenAI-Integration`, `mayabank-ibm-odm-ai-decision-architecture`.

---

## I10 — Observabilité / SRE

- [ ] OpenTelemetry traces.
- [ ] Metrics.
- [ ] Logs structurés.
- [ ] Dashboards techniques.
- [ ] Dashboards métier.
- [ ] Case age / backlog / SLA breach.
- [ ] API latency/error.
- [ ] Kafka lag.
- [ ] MQ queue depth/backout/DLQ.
- [ ] AI latency/token/error.
- [ ] Correlation case/payment/message/trace.
- [ ] Alerting.
- [ ] Définir SLI/SLO candidats après baseline.

**Réutilisation** : `dynatrace-observability-senior-project` et patterns OTel existants.

---

## I11 — GitOps / CI/CD / Supply Chain

- [ ] Base + overlays `crc/dev/preprod/prod`.
- [ ] Argo CD Application/ApplicationSet.
- [ ] CI lint/unit/integration.
- [ ] OpenAPI/AsyncAPI validation.
- [ ] SAST/dependency scan.
- [ ] Image build.
- [ ] SBOM.
- [ ] Signature/admission si environnement le permet.
- [ ] Promotion par digest.
- [ ] Rollback.
- [ ] Evidence pipeline.

**Réutilisation** : `argocd-expert-pack`, `openshift-platform-blueprints`.

---

## I12 — HA / Résilience / RTO-RPO / PRA

### Application
- [ ] Multi-replica Pega/integration workloads.
- [ ] PDB.
- [ ] anti-affinity/topology spread.
- [ ] rolling upgrade.

### Data
- [ ] DB HA design.
- [ ] backup/restore.
- [ ] PITR where relevant.
- [ ] restore test.

### Dependencies
- [ ] Kafka failure.
- [ ] MQ failure.
- [ ] IAM failure.
- [ ] ODM failure.
- [ ] AI provider failure.
- [ ] Payment core failure.
- [ ] duplicate/reordered event.

### Infrastructure
- [ ] worker failure.
- [ ] zone failure.
- [ ] site failure.
- [ ] PRA/failover/failback runbook.
- [ ] RPO/RTO evidence.

**Gate** : CRC ne permet pas de valider panne worker/zone/site.

---

## I13 — Sizing / Capacity / Performance

- [ ] Définir workload business x1.
- [ ] Scénarios x2/x5/x10.
- [ ] Cases/day et peak cases/min.
- [ ] Concurrent users.
- [ ] Steps/events/docs per case.
- [ ] AI calls/tokens per case.
- [ ] Load tests.
- [ ] CPU/RAM measurements.
- [ ] DB IOPS/connections/storage.
- [ ] Kafka throughput/lag.
- [ ] MQ throughput/depth.
- [ ] AI latency.
- [ ] Capacity model.
- [ ] Bottleneck analysis.

---

## I14 — FinOps / GreenOps

- [ ] €/1000 cases.
- [ ] €/investigation.
- [ ] €/1000 AI calls.
- [ ] Token cost/case.
- [ ] CPU/RAM utilisation.
- [ ] Idle capacity.
- [ ] Non-prod shutdown strategy.
- [ ] Storage retention/tiering.
- [ ] Right-sizing.
- [ ] Carbon methodology/source explicit if used.
- [ ] No estimated carbon gain presented as measured fact.

**Réutilisation** : `mayabank-carbon-aware-decision-architecture`.

---

## I15 — Insurance Claims vertical reuse

- [ ] FNOL intake.
- [ ] Claims Investigation Case.
- [ ] Documents.
- [ ] Policy retrieval.
- [ ] Fraud score.
- [ ] ODM coverage/eligibility.
- [ ] AI summary/RAG.
- [ ] Human claims handler.
- [ ] Deterministic claims core action.
- [ ] Audit/closure.
- [ ] Prove reuse of same platform instead of duplicate stack.

---

## I16 — Azure portability

- [ ] ADR AKS vs ARO.
- [ ] Entra ID mapping.
- [ ] APIM mapping.
- [ ] Kafka/Event Hubs mapping where justified.
- [ ] Service Bus mapping where justified.
- [ ] PostgreSQL managed target where justified.
- [ ] Key Vault.
- [ ] Azure Monitor/OTel.
- [ ] AI adapter to Azure AI/Foundry if used.
- [ ] Terraform plan.
- [ ] GitHub Actions OIDC.
- [ ] Deploy -> verify -> demo -> destroy.
- [ ] Cost evidence.
- [ ] No overnight expensive lab resources.

**Réutilisation** : `mayabank-azure-cloud-ai-platform`.

---

## I17 — Enterprise architecture / DAT / soutenance

- [ ] TOGAF traceability.
- [ ] ArchiMate views.
- [ ] HOPEX mapping/reference.
- [ ] C4 context/container/deployment.
- [ ] HLD.
- [ ] LLD.
- [ ] DAT.
- [ ] NFR matrix.
- [ ] Security architecture.
- [ ] HA/PRA architecture.
- [ ] Sizing report.
- [ ] FinOps/GreenOps report.
- [ ] ADR register.
- [ ] Runbooks.
- [ ] Architecture Board decision pack.
- [ ] Demo script 20–30 min.
- [ ] Interview questions/answers.
- [ ] Final evidence index.
- [ ] Final audit: claims vs actual evidence.

---

# Ordre de reprise recommandé

Quand ce projet sera repris :

```text
I1 Domain / Case Model
 -> I2 Pega prerequisites
 -> I3 Pega on CRC
 -> I4 Payment Investigation
 -> I5 API/Security
 -> I6 Kafka
 -> I7 MQ
 -> I8 ODM
 -> I9 AI
 -> I10 Observability
 -> I11 GitOps
 -> I12 Resilience
 -> I13 Sizing
 -> I14 FinOps/GreenOps
 -> I15 Insurance
 -> I16 Azure
 -> I17 Final Architecture Board Pack
```

Ne pas démarrer par l’AI. D’abord obtenir un **case métier déterministe et observable**, puis ajouter l’AI comme capacité d’assistance gouvernée.