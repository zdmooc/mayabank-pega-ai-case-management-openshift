# MayaBank — Pega CRM, Customer Service, Case Management & OpenShift

Référentiel d’architecture et futur POC démontrable pour construire une solution **Pega orientée Architecte Solution** couvrant :

- **CRM / Customer Service / Customer 360** ;
- **Case Management bancaire et assurance** ;
- **Decisioning / Next Best Action / règles** ;
- **API Management, Kafka et IBM MQ** ;
- **OpenShift, sécurité, observabilité et GitOps** ;
- **Constellation et AI/GenAI gouvernée** lorsque les composants/licences nécessaires sont disponibles.

> **Statut au 10 septembre 2026 : CADRAGE COMPLET / RUNTIME À CONSTRUIRE.**
> Aucun runtime Pega, composant Customer Service/CDH/Constellation, OpenShift multi-nœuds, Kafka, IBM MQ, ODM ou composant AI n’est déclaré validé dans ce dépôt tant qu’une preuve d’exécution n’est pas versionnée.

## Positionnement CV cible

**Architecte Solution Pega — CRM / Customer Service / Case Management / Decisioning / OpenShift — Certified SA & SSA**

Le dépôt doit démontrer la chaîne suivante :

```text
Customer Journey / Business Case
          |
          v
Pega Customer Service / CRM / Customer 360
          |
          v
Pega Case Management
          |
          +--> Rules / CDH / ODM
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

## Les 4 POC du dépôt

Le portfolio Pega est volontairement regroupé dans **un seul dépôt principal**.

### POC-A — CRM / Customer Service / Customer 360

Scénario : un client contacte MayaBank pour un paiement instantané non reçu. L’agent ouvre le Customer 360, retrouve les comptes/paiements/interactions et crée un Service Request relié à une investigation.

Capacités visées :

- Customer 360 synthétique ;
- Customer Interaction ;
- Service Requests / Complaints ;
- work queues / routing / SLA / escalation ;
- historique d’interactions ;
- séparation Pega / systèmes de record ;
- audit et sécurité.

### POC-B — Payment Investigation Case Management

```text
Wero / SCT Inst / Payment Core simulé
             |
             v
       API / Kafka / MQ
             |
             v
        Pega Case
             |
   +---------+----------+----------------+
   |                    |                |
PAYMENT_UNKNOWN    FRAUD_REVIEW   RECONCILIATION_BREAK
   |                    |                |
   +--------------------+----------------+
             |
             v
       Investigation
             |
       Rules / ODM
             |
       Human Approval
             |
             v
     Resolution / Audit
```

Le Core Payment reste le système de record financier. Pega orchestre le Case et les tâches humaines.

### POC-C — Pega Platform sur OpenShift

Objectif : démontrer l’architecture technique de production autour de Pega :

- version/runtime/licences vérifiés avant déploiement ;
- OpenShift Local/CRC pour les preuves locales compatibles ;
- namespace, RBAC, quotas, storage, database, TLS, NetworkPolicies ;
- GitOps / CI-CD ;
- observabilité ;
- backup/restore ;
- sizing/performance ;
- HA/PRA documentés et validés uniquement sur une infrastructure adaptée.

### POC-D — Pega moderne : Constellation / Decisioning / AI

Objectif : ajouter les capacités modernes après validation du Case Management déterministe :

- Constellation lorsque disponible ;
- Customer Decision Hub / Next Best Action lorsque disponible ;
- stratégie Pega rules vs CDH vs IBM ODM ;
- case summarization ;
- RAG procédures ;
- next investigation step ;
- human-in-the-loop ;
- provenance, audit et guardrails.

Principe :

```text
AI proposes
 -> Rules / policy validate
 -> Human approves when required
 -> Deterministic core executes
 -> Pega records outcome and audit
```

## Cas d’usage fil rouge

Le cas principal est **MayaBank Customer Service & Payment Investigation** :

```text
Customer
   |
   v
Customer Interaction
   |
   v
Customer 360
   |
   v
Service Request: Payment not received
   |
   v
PAYMENT_UNKNOWN Case
   |
   v
Investigation / Decision / Approval
   |
   v
Payment Core Resolution
   |
   v
Case Closure + Customer Interaction Audit
```

Une seconde déclinaison réutilisera la même architecture pour **MayaInsurance Claims Customer Service & Investigation**.

## Principes d’architecture

1. **Pega orchestre Customer Service et Case Management ; les cores restent systèmes de record.**
2. Les données Customer 360 ont un ownership explicite ; Pega ne devient pas implicitement MDM ou ledger.
3. Aucune décision financière irréversible n’est confiée à un LLM ou à un agent autonome.
4. Les intégrations synchrones et asynchrones sont choisies explicitement : REST/API, Kafka/Event Streaming ou IBM MQ.
5. Idempotence, correlation ID, audit trail, timeout, retry borné, DLQ/backout et gestion des états `UNKNOWN` sont obligatoires sur les flux critiques.
6. OpenShift Local/CRC sert aux preuves locales compatibles mais ne prouve pas une HA multi-worker/multi-zone.
7. Les composants Pega propriétaires ne sont jamais embarqués dans Git sans droit/licence approprié.
8. Les secrets, kubeconfigs, pull secrets, mots de passe et états Terraform ne sont jamais versionnés.
9. Toute affirmation `VALIDATED`, `TESTED`, `HA`, `RPO` ou `RTO` doit être accompagnée d’une evidence reproductible.
10. Toute décision d’architecture importante doit expliciter options, trade-offs et décision retenue.

## Articulation avec les autres dépôts

Ce dépôt ne doit pas dupliquer les autres POC. Il les intègre :

- `pega-docker-repo` : baseline **legacy/local** à auditer ;
- `wero-organisme-poc` : domaine Payment / SCT Inst / Wero ;
- `mayabank-api-management-architecture` : OpenAPI, OAuth/OIDC, mTLS et API governance ;
- `mayabank-kafka-ddd-openshift` et `kafka-expert` : DDD / Event-Driven / Kafka ;
- `mayabank-ibm-mq-native-ha-openshift-eda-platform` : IBM MQ / JMS / backout / retry ;
- `mayabank-ibm-odm-ai-decision-architecture` : règles déterministes / decisioning ;
- `keycloak-enterprise-roadmap-v7` : IAM/OIDC ;
- `dynatrace-observability-senior-project` : observabilité/SRE ;
- `mayabank-servicenow-csdm-cmdb-architecture` : exploitation/CMDB/ITOM ;
- `argocd-expert-pack` et `openshift-platform-blueprints` : GitOps/OpenShift ;
- `mayabank-azure-cloud-ai-platform` : cible Azure après validation locale ;
- `mayabank-carbon-aware-decision-architecture` : FinOps/GreenOps ;
- `cadrage_202682030` : référentiel maître et priorisation portfolio.

## Architecture cible

La description détaillée existante est dans [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

Le backlog de réalisation complet est dans [`BACKLOG.md`](BACKLOG.md).

## Roadmap synthétique

```text
I1  CRM / Customer Service / Case Model
 -> I2  Pega prerequisites / licences / version
 -> I3  Pega on OpenShift Local / CRC
 -> I4  Customer Service + Payment Investigation
 -> I5  API / IAM / Security
 ===== N1 : CV démontrable =====
 -> I6  Kafka
 -> I7  IBM MQ
 -> I8  Decisioning / ODM / CDH
 -> I10 Observability / SRE
 -> I11 GitOps / CI-CD
 -> I12 Resilience
 -> I13 Sizing / Performance
 ===== N2 : Architecte Solution solide =====
 -> I9  Constellation / AI / RAG
 -> I14 FinOps / GreenOps
 -> I15 Insurance reuse
 -> I16 Azure portability
 -> I17 HLD / LLD / DAT / Architecture Board / Demo
 ===== N3 : Portfolio premium =====
```

### Charge indicative

- **N1 — CV démontrable : 25–35 h** ;
- **N2 — Architecte Solution solide : 50–70 h cumulées** ;
- **N3 — Portfolio premium : 70–100 h cumulées**.

Ces charges sont des estimations de planification et doivent être recalibrées après vérification des licences, composants et contraintes du runtime Pega réellement accessible.

## Definition of Done globale

Le projet ne sera considéré terminé que si :

- le parcours CRM / Customer Service est documenté et démontrable ;
- le Case Payment Investigation est testable ;
- les frontières Pega/Core/Customer data/ODM/CDH/AI sont explicites ;
- les APIs/events/messages sont contractuels et versionnés ;
- la sécurité et l’audit sont démontrés ;
- les parties OpenShift déclarées exécutées possèdent une preuve reproductible ;
- les scénarios de panne sont testés lorsqu’une infrastructure adaptée existe ;
- les hypothèses de sizing sont séparées des mesures ;
- les fonctionnalités non accessibles sous licence sont marquées `DESIGNED ONLY` ;
- chaque claim `TESTED`, `VALIDATED`, `HA`, `RPO`, `RTO` pointe vers une preuve ;
- aucun nom, secret, donnée ou architecture interne d’une entreprise réelle n’est publié ;
- une démonstration complète de 20–30 minutes est possible.
