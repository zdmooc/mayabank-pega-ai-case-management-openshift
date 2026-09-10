# Backlog — MayaBank Pega Solution Architecture

> **Cible CV : Architecte Solution Pega — CRM / Customer Service / Case Management / Decisioning / OpenShift — Certified SA & SSA**
>
> Statut : **PARKED / À RÉALISER PLUS TARD**. Ce fichier est le point de reprise officiel du projet.
>
> Objectif : transformer le dépôt en **portfolio Pega démontrable en entretien**, avec architecture, configuration, exécution, tests et preuves. Aucun composant n'est déclaré validé sans evidence reproductible.

---

## 0. Résultat attendu

Le dépôt doit démontrer de bout en bout :

```text
Besoin métier / Customer Journey
        |
        v
Pega Customer Service / CRM / Customer 360
        |
        v
Pega Case Management
        |
        +--> Decisioning / CDH / ODM
        +--> REST / API Management
        +--> Kafka / IBM MQ
        +--> Core Banking / Insurance simulé
        +--> AI assistant gouverné
        |
        v
Pega Platform sur OpenShift
        |
        +--> IAM / Security
        +--> Observability / SRE
        +--> GitOps / CI-CD
        +--> HA / PRA / Capacity
        +--> FinOps / GreenOps
```

Le fil rouge principal est **MayaBank Customer Service & Payment Investigation**. Le second vertical est **MayaInsurance Claims Investigation**.

---

## 1. Les 4 POC à terminer dans CE dépôt

Ne pas créer quatre nouveaux dépôts Pega. Ils constituent quatre démonstrations cohérentes dans `mayabank-pega-ai-case-management-openshift`.

### POC-A — Pega CRM / Customer Service / Customer 360

Objectif CV : montrer que Pega n'est pas seulement une plateforme technique mais une solution CRM / Customer Service intégrée au SI.

- [ ] Définir personas : Customer, Customer Service Agent, Supervisor, Fraud Analyst, Payment Ops, Auditor.
- [ ] Définir Customer 360 synthétique : identité, comptes, cartes, contrats, paiements, interactions, cases.
- [ ] Définir Customer Interaction : téléphone/chat/web simulés.
- [ ] Définir Service Requests : payment inquiry, complaint, recall, refund, card/payment issue.
- [ ] Définir historique d'interactions omnicanales.
- [ ] Définir SLA, priorities, routing, work queues et escalations.
- [ ] Définir séparation System of Record / Pega Customer 360 / caches / données de travail.
- [ ] Définir consentement, minimisation, rétention et audit.
- [ ] Définir intégration Customer Service -> Case Management.
- [ ] Préparer scénario Next Best Action / CDH sans présenter CDH comme validé avant accès au produit.
- [ ] Ajouter captures / diagrammes / tests / evidence.

**Demo attendue** : un agent identifie un client, ouvre la Vue 360, consulte ses interactions et son paiement, puis crée ou rejoint un Case `PAYMENT_UNKNOWN`.

### POC-B — Pega Case Management bancaire / Payment Investigation

Objectif CV : démontrer le niveau SSA / Solution Architecture sur un vrai processus bancaire.

- [ ] Case Types : `PAYMENT_UNKNOWN`, `FRAUD_REVIEW`, `RECONCILIATION_BREAK`, `DUPLICATE_PAYMENT`, `REFUND_REQUEST`, `RECALL_REQUEST`.
- [ ] Stages / Steps / Assignments.
- [ ] Work queues et routing.
- [ ] SLA / escalation.
- [ ] State machine canonique.
- [ ] Child cases / related cases si justifiés.
- [ ] Data objects et data pages / access patterns documentés selon version Pega cible.
- [ ] Documents / evidence opérateur.
- [ ] Audit trail.
- [ ] Reopen / duplicate / cancel / technical-blocked patterns.
- [ ] Event entrant PaymentUnknown.
- [ ] Consultation Payment Core via API.
- [ ] Human Investigation.
- [ ] Validation règle / ODM.
- [ ] Human Approval quand requis.
- [ ] Resolution command vers core simulé.
- [ ] Outcome event.
- [ ] Tests E2E : nominal, unknown, duplicate, timeout, replay, retry, dépendance indisponible.

**Demo attendue** : `SCT Inst / Wero simulé -> UNKNOWN -> Pega Case -> Investigation -> Decision -> Human Approval -> Core Resolution -> Closure/Audit`.

### POC-C — Pega Platform sur OpenShift / Architecture technique

Objectif CV : différencier le profil par Pega + OpenShift + architecture de production.

- [ ] Définir version Pega cible au moment de l'exécution.
- [ ] Vérifier licences et artefacts/images autorisés.
- [ ] Auditer `pega-docker-repo` comme baseline legacy uniquement.
- [ ] Vérifier mécanisme officiel/supporté de déploiement pour la version cible.
- [ ] Définir architecture runtime Pega et dépendances.
- [ ] Namespace/projet OpenShift.
- [ ] ServiceAccount / RBAC.
- [ ] ResourceQuota / LimitRange.
- [ ] Secrets pattern sans secret réel dans Git.
- [ ] TLS / Routes.
- [ ] PVC / storage.
- [ ] Database lab supportée.
- [ ] Requests / limits.
- [ ] Probes.
- [ ] NetworkPolicies.
- [ ] GitOps Argo CD.
- [ ] CI/CD / quality / security checks.
- [ ] Observabilité.
- [ ] Backup / restore.
- [ ] HA design, PDB, anti-affinity / topology spread sur cible adaptée.
- [ ] PRA / RTO-RPO design et tests uniquement sur infrastructure permettant de les valider.
- [ ] Sizing / performance / capacity.
- [ ] Evidence reproductible.

**Demo attendue** : déploiement contrôlé, route TLS, health, test fonctionnel, métriques/logs/traces, redeploy GitOps et rollback.

### POC-D — Pega moderne : Constellation + Decisioning + AI gouvernée

Objectif CV : montrer une architecture Pega moderne sans remplacer le moteur déterministe par l'IA.

- [ ] Étudier/adopter Constellation selon version et licences disponibles.
- [ ] Construire vues agent pour Customer Service / Payment Investigation.
- [ ] Définir usage DX/API si pertinent.
- [ ] Définir Customer Decision Hub / Next Best Action comme capacité séparée du Case Management.
- [ ] Définir stratégie decisioning : Pega local rules vs CDH vs IBM ODM.
- [ ] Définir AI Gateway abstraite du fournisseur.
- [ ] Case summarization.
- [ ] RAG sur procédures bancaires synthétiques.
- [ ] Recommended next investigation step.
- [ ] Document classification/extraction.
- [ ] Confidence score.
- [ ] Human-in-the-loop pour actions sensibles.
- [ ] Provenance/citations RAG.
- [ ] Prompt/tool/model audit.
- [ ] Prompt injection / grounding / hallucination tests.
- [ ] Démontrer que panne AI n'empêche pas le traitement manuel essentiel.

**Principe obligatoire** :

```text
AI proposes
 -> Rules / policy validate
 -> Human approves when required
 -> Deterministic core executes
 -> Pega records outcome and audit
```

---

## 2. Charge et niveaux de finition

Estimations de planification, à recalibrer après accès réel aux composants Pega et licences.

| Niveau | Objectif | Charge indicative |
|---|---|---:|
| N1 — CV démontrable | CRM/Customer Service + Case Management + baseline OpenShift + API/Security + demo | 25–35 h |
| N2 — Architecte Solution solide | N1 + Kafka/MQ + ODM + observabilité + GitOps + résilience/performance | 50–70 h cumulées |
| N3 — Portfolio premium | N2 + Constellation/CDH/AI + Claims + Azure + DAT/HLD/LLD + soutenance finale | 70–100 h cumulées |

**Priorité immédiate** : obtenir N1 avant de poursuivre les extensions avancées.

---

# Roadmap détaillée I0 -> I17

## I0 — Cadrage / Architecture / Definition of Done — EN PLACE

- [x] README initial.
- [x] Architecture cible complète.
- [x] Backlog global initial.
- [x] Définir Payment Investigation comme premier vertical.
- [x] Prévoir Insurance Claims comme second vertical réutilisant le même socle.
- [x] Repositionner le projet vers **Architecte Solution Pega — CRM / Customer Service / Case Management / OpenShift**.
- [x] Regrouper les travaux sous 4 POC cohérents plutôt que multiplier les dépôts.
- [ ] Ajouter `docs/adr/` avec ADR-001 à ADR-015.
- [ ] Ajouter diagrammes PlantUML/Mermaid/SVG.
- [ ] Ajouter matrice `requirements -> architecture -> tests -> evidence`.
- [ ] Ajouter `docs/portfolio/CV_MAPPING.md` : compétences CV -> preuves GitHub.
- [ ] Ajouter `docs/portfolio/DEMO_SCRIPT.md` : démonstration 20–30 min.

**Gate I0** : aucun runtime requis.

---

## I1 — CRM / Customer Service / domaine métier / Case Model

### I1.1 Customer Service / CRM

- [ ] Définir Customer Journey principal : « mon paiement instantané n'est pas arrivé ».
- [ ] Définir personas et rôles.
- [ ] Définir modèle Customer 360 synthétique.
- [ ] Définir interactions, service requests et complaints.
- [ ] Définir canaux simulés : web / mobile / call center / chat.
- [ ] Définir relation Interaction -> Service Case -> Investigation Case.
- [ ] Définir work queues / routing / SLA / escalation.
- [ ] Définir KPIs : FCR, average case age, SLA breach, reopen rate, escalation rate.
- [ ] Définir règles de rétention/audit des interactions.

### I1.2 Payment Investigation

- [ ] Définir `PAYMENT_UNKNOWN`, `FRAUD_REVIEW`, `RECONCILIATION_BREAK`, `DUPLICATE_PAYMENT`, `REFUND_REQUEST`, `RECALL_REQUEST`.
- [ ] Définir Case Types, stages, steps, assignments, work queues, SLA et escalation.
- [ ] Construire state machine canonique.
- [ ] Construire BPMN/process flow.
- [ ] Définir data model du case.
- [ ] Définir business outcomes et KPI.
- [ ] Définir règles de clôture / reopen / duplicate / cancel.
- [ ] Définir audit requirements.

### I1.3 Architecture Solution

- [ ] Définir System of Record pour Customer / Account / Payment / Case / Decision / Documents.
- [ ] Définir frontières Pega vs Core Banking vs MDM/CRM externe vs ODM vs AI.
- [ ] ADR : Pega comme orchestrateur de Case, pas comme ledger financier.
- [ ] ADR : synchrones vs asynchrones.
- [ ] ADR : Customer 360 et stratégie d'accès aux données.

**Livrables** : `docs/domain/`, `docs/crm/`, BPMN, state machine, customer journey, use-case catalog, data ownership matrix.

---

## I2 — Pega baseline / version / prérequis / licences

- [ ] Auditer `pega-docker-repo`.
- [ ] Identifier ce qui est legacy, réutilisable ou à archiver.
- [ ] Identifier version Pega cible au moment de l'exécution.
- [ ] Vérifier prérequis/licences/images autorisées.
- [ ] Vérifier disponibilité des composants Customer Service / Constellation / CDH nécessaires.
- [ ] Vérifier documentation de déploiement Kubernetes/OpenShift correspondant à la version retenue.
- [ ] Définir registry/image pull strategy.
- [ ] Définir base de données supportée pour le lab.
- [ ] Définir dépendances externes nécessaires à la version choisie.
- [ ] Décider : réutilisation de baseline Docker ou déploiement OpenShift propre.
- [ ] ADR : version/runtime/licences.

**Gate** : ne pas poursuivre au runtime Pega tant que version, droits d'utilisation et artefacts ne sont pas clairs.

---

## I3 — Pega Platform sur OpenShift Local / CRC

- [ ] Créer namespace/projet lab.
- [ ] ResourceQuota / LimitRange.
- [ ] ServiceAccount / RBAC.
- [ ] Secret pattern sans valeur réelle dans Git.
- [ ] Storage / PVC.
- [ ] Database lab.
- [ ] Déployer Pega via mécanisme supporté pour la version retenue.
- [ ] Service / Route TLS.
- [ ] Readiness/liveness probes selon capacités supportées.
- [ ] NetworkPolicies.
- [ ] Requests/limits.
- [ ] Smoke test UI/API.
- [ ] Documenter limites de CRC mono-nœud.
- [ ] Capturer evidence : commandes, manifests, captures, logs et versions.

**Gate** : Pega réellement accessible sur CRC, ou architecture explicitement marquée `DESIGNED ONLY` si les artefacts/licences ne permettent pas l'exécution.

---

## I4 — CRM Customer Service + Payment Investigation vertical

### I4.1 Customer Service

- [ ] Charger un customer synthétique.
- [ ] Afficher Customer 360.
- [ ] Afficher comptes / contrats / paiements / interactions.
- [ ] Simuler une interaction agent.
- [ ] Créer Service Request « payment not received ».
- [ ] Lier l'interaction au Case.
- [ ] Ajouter notes/evidence/audit.
- [ ] Tester routing et SLA.

### I4.2 Investigation Case

- [ ] Créer case `PAYMENT_UNKNOWN`.
- [ ] Recevoir événement depuis mock/payment core.
- [ ] Corréler `caseId`, `paymentId`, `correlationId`, `customerIdSynthetic`.
- [ ] Lire détails paiement via API.
- [ ] Afficher evidence opérateur.
- [ ] Human task Investigation.
- [ ] Workflow `WAITING_EXTERNAL` / `WAITING_APPROVAL`.
- [ ] Resolution request vers core simulé.
- [ ] Outcome event.
- [ ] Closure + audit.
- [ ] Tests E2E : nominal + unknown + duplicate + timeout + retry + dependency unavailable.

**Réutilisation** : `wero-organisme-poc`.

**Gate N1 partiel** : un customer journey et un Case métier doivent être démontrables.

---

## I5 — API Management / IAM / Security

- [ ] Définir APIs OpenAPI 3.1.
- [ ] Customer read API.
- [ ] Interaction API si exposée.
- [ ] Case API.
- [ ] Payment read API.
- [ ] Resolution command API.
- [ ] Decision API.
- [ ] OAuth2/OIDC.
- [ ] SSO / personas.
- [ ] Service identities.
- [ ] mTLS cible si nécessaire.
- [ ] API gateway policy.
- [ ] Rate limits / quotas.
- [ ] `X-Correlation-Id`.
- [ ] `Idempotency-Key` pour commandes sensibles.
- [ ] Error model métier vs technique.
- [ ] RBAC / least privilege.
- [ ] Security tests : token invalide, mauvais rôle, accès interdit, replay.
- [ ] Threat model et security architecture.

**Réutilisation** : `mayabank-api-management-architecture`, `keycloak-enterprise-roadmap-v7`.

**Gate N1** : CRM + Case + API/Security + baseline OpenShift + evidence démontrable.

---

## I6 — Kafka / Event-Driven Architecture

- [ ] AsyncAPI.
- [ ] Topics/events.
- [ ] `PaymentUnknownDetected`, `CaseCreated`, `CaseEscalated`, `ResolutionRequested`, `ResolutionCompleted`, `CaseClosed`.
- [ ] Partition key strategy.
- [ ] Producer idempotence.
- [ ] Consumer idempotence.
- [ ] Outbox/inbox si nécessaire.
- [ ] Retry / DLQ / quarantine.
- [ ] Replay contrôlé.
- [ ] Duplicate and out-of-order tests.
- [ ] Lag/consumer observability.
- [ ] Matrice : quand API vs Kafka.

**Réutilisation** : `mayabank-kafka-ddd-openshift`, `kafka-expert`, `wero-organisme-poc`.

---

## I7 — IBM MQ / JMS / intégration legacy bancaire

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
- [ ] Option bridge MQ -> Kafka si justifiée.
- [ ] Tests et evidence.
- [ ] Matrice : API vs Kafka vs MQ.

**Réutilisation obligatoire** : `mayabank-ibm-mq-native-ha-openshift-eda-platform`.

---

## I8 — Decisioning : Pega rules / CDH / IBM ODM

### I8.1 Architecture de décision

- [ ] Définir quelles décisions restent locales à Pega.
- [ ] Définir quelles décisions relèvent de Customer Decision Hub / Next Best Action.
- [ ] Définir quelles politiques complexes sont externalisées vers IBM ODM.
- [ ] Éviter le double ownership d'une même règle critique.
- [ ] Définir policy/rule versioning et audit.

### I8.2 ODM

- [ ] Définir décision déterministe de triage/résolution.
- [ ] Decision API contract.
- [ ] Policy version.
- [ ] Reason codes.
- [ ] Human review flag.
- [ ] Pega -> ODM integration.
- [ ] Fallback ODM unavailable.
- [ ] Audit decision.
- [ ] Tests de non-contournement des règles.

### I8.3 Customer Decision Hub / NBA

- [ ] Définir use cases NBA : informer, conseiller, proposer service case, next action agent.
- [ ] Définir données nécessaires au decisioning.
- [ ] Définir arbitration / eligibility / suitability / contact policy au niveau d'architecture.
- [ ] Intégrer seulement si produit/licence disponible ; sinon `DESIGNED ONLY`.

**Réutilisation** : `mayabank-ibm-odm-ai-decision-architecture`.

---

## I9 — Constellation / UX moderne / AI-RAG-Agent assistant

### I9.1 Constellation

- [ ] Vérifier disponibilité et compatibilité version cible.
- [ ] Définir UI architecture Customer Service / Investigation.
- [ ] Construire vues opérateur modernes si disponible.
- [ ] Étudier DX/API et SDK uniquement si utiles au POC.
- [ ] Tester navigation / permissions / responsive baseline.

### I9.2 AI / RAG / Agent assistant

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
- [ ] Démontrer que panne AI n'empêche pas le traitement manuel essentiel.

**Réutilisation** : `TradeOps-GenAI-Integration`, `mayabank-ibm-odm-ai-decision-architecture`.

---

## I10 — Observabilité / PDC / SRE / métier

- [ ] Identifier capacités Pega/PDC réellement disponibles dans l'environnement retenu.
- [ ] OpenTelemetry traces pour composants externes/adapters.
- [ ] Metrics.
- [ ] Logs structurés.
- [ ] Dashboards techniques.
- [ ] Dashboards métier.
- [ ] Case age / backlog / SLA breach.
- [ ] Customer interaction metrics.
- [ ] API latency/error.
- [ ] Kafka lag.
- [ ] MQ queue depth/backout/DLQ.
- [ ] ODM latency/error.
- [ ] AI latency/token/error.
- [ ] Correlation `customer / interaction / case / payment / message / trace`.
- [ ] Alerting.
- [ ] Définir SLI/SLO après baseline mesurée.
- [ ] Runbooks diagnostic/remédiation.

**Réutilisation** : `dynatrace-observability-senior-project` et patterns OpenTelemetry existants.

---

## I11 — GitOps / CI-CD / DevSecOps / Supply Chain

- [ ] Base + overlays `crc/dev/preprod/prod`.
- [ ] Argo CD Application/ApplicationSet.
- [ ] CI lint/unit/integration.
- [ ] OpenAPI/AsyncAPI validation.
- [ ] SAST/dependency scan.
- [ ] Image build composants custom.
- [ ] SBOM.
- [ ] Signature/admission si environnement le permet.
- [ ] Promotion par digest.
- [ ] Gestion des artefacts/rulesets Pega selon mécanisme retenu.
- [ ] Rollback.
- [ ] Evidence pipeline.
- [ ] Séparation config/code/secrets.

**Réutilisation** : `argocd-expert-pack`, `openshift-platform-blueprints`.

---

## I12 — HA / Résilience / RTO-RPO / PRA

### Application

- [ ] Multi-replica Pega/integration workloads sur cible adaptée.
- [ ] PDB.
- [ ] anti-affinity / topology spread.
- [ ] rolling upgrade.
- [ ] graceful shutdown/restart.

### Data

- [ ] DB HA design.
- [ ] backup/restore.
- [ ] PITR where relevant.
- [ ] restore test.
- [ ] document/object storage continuity.

### Dependencies

- [ ] Kafka failure.
- [ ] MQ failure.
- [ ] IAM failure.
- [ ] ODM failure.
- [ ] AI provider failure.
- [ ] Payment core failure.
- [ ] duplicate/reordered event.
- [ ] API timeout.

### Infrastructure

- [ ] worker failure.
- [ ] zone failure.
- [ ] site failure.
- [ ] PRA/failover/failback runbook.
- [ ] RPO/RTO evidence.

**Gate** : CRC ne permet pas de valider panne worker/zone/site. Ces éléments restent `DESIGNED` tant qu'ils ne sont pas testés sur une cible adaptée.

---

## I13 — Sizing / Capacity / Performance

- [ ] Définir workload business x1.
- [ ] Scénarios x2/x5/x10.
- [ ] Customers / interactions / cases par jour.
- [ ] Peak cases/min.
- [ ] Concurrent users/agents.
- [ ] Steps/events/docs per case.
- [ ] AI calls/tokens per case.
- [ ] Load tests.
- [ ] CPU/RAM measurements.
- [ ] DB IOPS/connections/storage.
- [ ] API latency percentiles.
- [ ] Kafka throughput/lag.
- [ ] MQ throughput/depth.
- [ ] ODM latency.
- [ ] AI latency.
- [ ] Capacity model.
- [ ] Bottleneck analysis.
- [ ] Purge/archive/retention test.

---

## I14 — FinOps / GreenOps

- [ ] €/1000 cases.
- [ ] €/1000 customer interactions.
- [ ] €/investigation.
- [ ] €/1000 AI calls.
- [ ] Token cost/case.
- [ ] CPU/RAM utilisation.
- [ ] Idle capacity.
- [ ] Non-prod shutdown strategy.
- [ ] Storage retention/tiering.
- [ ] Right-sizing.
- [ ] Carbon methodology/source explicit if used.
- [ ] Ne jamais présenter un gain carbone estimé comme une mesure réelle.

**Réutilisation** : `mayabank-carbon-aware-decision-architecture`.

---

## I15 — MayaInsurance / Claims Customer Service reuse

Objectif : prouver la réutilisabilité de l'architecture sans recréer une deuxième plateforme.

- [ ] FNOL / contact initial.
- [ ] Customer/Policy 360 synthétique.
- [ ] Claims Service Request.
- [ ] Claims Investigation Case.
- [ ] Documents.
- [ ] Policy retrieval.
- [ ] Fraud score.
- [ ] ODM coverage/eligibility.
- [ ] AI summary/RAG.
- [ ] Human claims handler.
- [ ] Deterministic claims core action.
- [ ] Audit/closure.
- [ ] Mesurer le niveau de réutilisation du socle.

---

## I16 — Azure portability / Cloud target

- [ ] ADR AKS vs ARO selon support/cible retenue.
- [ ] Entra ID mapping.
- [ ] APIM mapping.
- [ ] Kafka/Event Hubs mapping where justified.
- [ ] Service Bus mapping where justified.
- [ ] PostgreSQL managed target where justified.
- [ ] Key Vault.
- [ ] Azure Monitor/OTel.
- [ ] AI adapter Azure si utilisé.
- [ ] Terraform plan.
- [ ] GitHub Actions OIDC.
- [ ] Deploy -> verify -> demo -> destroy pour composants autorisés.
- [ ] Cost evidence.
- [ ] No overnight expensive lab resources.

**Réutilisation** : `mayabank-azure-cloud-ai-platform`.

---

## I17 — Enterprise Architecture / DAT / HLD / LLD / soutenance

### Architecture pack

- [ ] Business capability map.
- [ ] Customer Journey / value stream.
- [ ] TOGAF traceability.
- [ ] ArchiMate views.
- [ ] HOPEX mapping/reference.
- [ ] C4 context/container/deployment.
- [ ] HLD.
- [ ] LLD.
- [ ] DAT.
- [ ] NFR matrix.
- [ ] Data ownership matrix.
- [ ] Integration matrix.
- [ ] Security architecture.
- [ ] HA/PRA architecture.
- [ ] Sizing report.
- [ ] FinOps/GreenOps report.
- [ ] ADR register.
- [ ] Runbooks.

### Portfolio / entretien

- [ ] Architecture Board decision pack.
- [ ] `CV_MAPPING.md` : chaque compétence CV pointe vers une preuve.
- [ ] Demo script 20–30 min.
- [ ] Demo « executive » 5 min.
- [ ] Interview questions/answers Pega Solution Architect.
- [ ] Captures/screen recording optionnelles sans données/confidentiel.
- [ ] Final evidence index.
- [ ] Final audit : claims vs actual evidence.

---

# Definition of Done globale

Le projet n'est `DONE` que si :

- [ ] un parcours CRM / Customer Service est démontrable ;
- [ ] un Case Payment Investigation est démontrable ;
- [ ] les frontières Pega / Core / CRM data / ODM / CDH / AI sont explicites ;
- [ ] les APIs/events/messages sont contractuels et versionnés ;
- [ ] la sécurité et l'audit sont démontrés ;
- [ ] l'OpenShift target est documentée et les parties exécutables ont une evidence ;
- [ ] les scénarios de panne sont documentés et testés quand l'infrastructure le permet ;
- [ ] les hypothèses de sizing sont séparées des mesures ;
- [ ] les technologies indisponibles sous licence sont clairement marquées `DESIGNED ONLY` ;
- [ ] chaque affirmation `TESTED`, `VALIDATED`, `HA`, `RPO`, `RTO` pointe vers une preuve ;
- [ ] aucun nom, secret, donnée ou architecture interne d'une entreprise réelle n'est publié ;
- [ ] la démonstration finale peut être réalisée en 20–30 minutes.

---

# Ordre de reprise recommandé

```text
I1  CRM / Customer Service / Case Model
 -> I2  Pega prerequisites / licences / version
 -> I3  Pega on OpenShift Local / CRC
 -> I4  Customer Service + Payment Investigation
 -> I5  API / IAM / Security
 ========= NIVEAU N1 CV DÉMONTRABLE =========
 -> I6  Kafka
 -> I7  IBM MQ
 -> I8  Decisioning / ODM / CDH
 -> I10 Observability / SRE
 -> I11 GitOps / CI-CD
 -> I12 Resilience
 -> I13 Sizing / Performance
 ========= NIVEAU N2 SOLUTION ARCHITECT =========
 -> I9  Constellation / AI / RAG
 -> I14 FinOps / GreenOps
 -> I15 Insurance reuse
 -> I16 Azure portability
 -> I17 Final Architecture Board / HLD / LLD / DAT / Demo
 ========= NIVEAU N3 PORTFOLIO PREMIUM =========
```

## Règle de priorité

**Ne pas démarrer par l'AI.**

D'abord obtenir :

```text
Customer Interaction
 -> Customer 360
 -> Service Request
 -> deterministic Case Management
 -> API/Security
 -> observable execution
```

Ensuite seulement ajouter Kafka/MQ, Decisioning, Constellation, CDH et AI.

---

# Règles de travail

- [ ] Utiliser uniquement des données fictives/synthétiques MayaBank/MayaInsurance.
- [ ] Ne jamais committer secret, kubeconfig, pull secret, mot de passe, dump client ou binaire Pega propriétaire non autorisé.
- [ ] Réutiliser les autres dépôts avant de réimplémenter Kafka, MQ, ODM, IAM, observabilité ou Azure.
- [ ] Distinguer partout : `DESIGNED`, `CONFIGURED`, `DEPLOYED`, `RUNTIME VALIDATED`.
- [ ] Chaque itération produit docs + code/config + tests + evidence avant clôture.
- [ ] Versionner les ADR et les contrats d'intégration.
- [ ] Toute décision d'architecture significative doit documenter options, trade-offs et décision retenue.
