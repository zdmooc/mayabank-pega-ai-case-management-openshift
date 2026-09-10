# Architecture cible — MayaBank Pega AI Case Management on OpenShift

## 1. Objectif

Construire une architecture de référence démontrable de **Case Management Pega** pour banque et assurance, sans faire de Pega le système de record financier. La plateforme doit orchestrer les dossiers, tâches humaines, règles, SLA, pièces, investigations et intégrations, tout en laissant les systèmes transactionnels exécuter les opérations irréversibles.

Le premier vertical sera **Payment Investigation & Exception Management**. Le second réutilisera le socle pour **Insurance Claims Investigation**.

## 2. Contexte C4 — niveau système

```text
                         UTILISATEURS
                Operations / Fraud / Claims
                           |
                           v
                    Pega Case Portal
                           |
                           v
+-------------------------------------------------------------+
|                   PEGA CASE PLATFORM                        |
| Case lifecycle | Tasks | SLA | Routing | Audit | UI        |
+-------------------------------------------------------------+
        |             |               |              |
        v             v               v              v
   API Gateway    Kafka/Event Bus    IBM MQ      AI/Decision
        |             |               |              |
        +-------------+---------------+--------------+
                           |
                           v
+-------------------------------------------------------------+
|               DETERMINISTIC BUSINESS CORE                   |
| Payments | Ledger | Wero/SCT Inst | Claims | Policies       |
+-------------------------------------------------------------+
                           |
                           v
                     Systems of Record
```

## 3. Principe directeur

```text
AI proposes
    |
    v
Rules / policy validate
    |
    v
Human approves when required
    |
    v
Deterministic core executes
    |
    v
Pega records case outcome and audit evidence
```

### Responsabilités

**Pega** :
- création et cycle de vie du case ;
- tâches humaines ;
- routage/work queues ;
- SLA/escalation ;
- formulaires et vues opérateur ;
- collecte de pièces ;
- orchestration ;
- audit métier du case ;
- règles simples locales si pertinent ;
- appels contrôlés vers règles/AI/core.

**Core Payments / Insurance** :
- autorité transactionnelle ;
- ledger ;
- settlement ;
- statut financier ;
- changement irréversible ;
- règles critiques spécifiques au système de record.

**IBM ODM / Decision Service** :
- politiques métier déterministes complexes ;
- decision tables / ruleflows ;
- reason codes ;
- version de politique ;
- décision auditable.

**AI Platform** :
- résumé de dossier ;
- recherche RAG ;
- extraction documentaire ;
- aide à l’investigation ;
- proposition d’actions ;
- classification/priorisation avec confidence score ;
- outils MCP gouvernés si retenus.

L’AI ne doit pas déplacer de fonds, clôturer un sinistre sensible ou contourner une règle sans contrôle explicite.

## 4. Cas métier principal — Payment Investigation

### 4.1 Types de dossiers

- `PAYMENT_UNKNOWN`
- `FRAUD_REVIEW`
- `RECONCILIATION_BREAK`
- `DUPLICATE_PAYMENT`
- `PAYMENT_TIMEOUT`
- `WERO_CALLBACK_MISSING`
- `SCT_INST_FAILURE`
- `REFUND_REQUEST`
- `RECALL_REQUEST`
- `CUSTOMER_COMPLAINT`
- `TECHNICAL_INCIDENT_LINKED`

### 4.2 Cycle de vie canonique

```text
NEW
 -> TRIAGE
 -> INVESTIGATING
 -> WAITING_EXTERNAL
 -> WAITING_CUSTOMER
 -> WAITING_APPROVAL
 -> READY_TO_RESOLVE
 -> RESOLVED
 -> CLOSED

Branches :
 -> DUPLICATE
 -> CANCELLED
 -> ESCALATED
 -> TECHNICAL_BLOCKED
```

### 4.3 Données minimales du case

```text
caseId
caseType
businessDomain
paymentId / claimId
correlationId
customerRefSynthetic
priority
severity
status
owner
workQueue
slaTarget
createdAt
updatedAt
sourceSystem
sourceEventId
evidence[]
documents[]
recommendations[]
decisions[]
approvals[]
resolutionCode
resolutionText
auditTrail[]
```

## 5. Séquence Payment Investigation

```text
Payment Core
   |
   | PaymentUnknown event
   v
Kafka / MQ
   |
   v
Integration Adapter
   |
   v
Pega Case API
   |
   +--> Create PAYMENT_UNKNOWN case
   |
   +--> Fetch payment details via API
   |
   +--> Query reconciliation evidence
   |
   +--> Ask AI Investigation Assistant
   |        |
   |        +--> RAG procedures
   |        +--> transaction read API
   |        +--> logs/traces read tool
   |        +--> audit lookup
   |
   +--> ODM / policy validation
   |
   +--> Human operator review
   |
   +--> Approved resolution request
   |
   v
Payment Core executes deterministic action
   |
   v
Outcome event
   |
   v
Pega closes/resolves case + audit
```

## 6. Intégration

### 6.1 API synchrone

À utiliser pour :
- consultation transaction/policy/customer ;
- création/lecture contrôlée de case ;
- décision ODM ;
- demande de résolution lorsque le caller doit recevoir un résultat immédiat.

Contraintes :
- OpenAPI versionné ;
- OAuth2/OIDC ;
- mTLS quand requis ;
- `X-Correlation-Id` ;
- idempotency key pour commandes sensibles ;
- timeout court et retry seulement si sémantiquement sûr ;
- circuit breaker/bulkhead si nécessaire ;
- erreurs métier distinctes des erreurs techniques.

### 6.2 Kafka / Event-Driven

À utiliser pour :
- événements de paiement ;
- création asynchrone de dossiers ;
- changement de statut ;
- audit/convergence ;
- notifications ;
- traitement découplé.

Exemples d’événements :
- `PaymentUnknownDetected`
- `FraudReviewRequested`
- `CaseCreated`
- `CaseEscalated`
- `HumanApprovalCompleted`
- `ResolutionRequested`
- `ResolutionCompleted`
- `CaseClosed`

Exigences : schéma versionné, clé de partition, ordering utile, idempotence consumer, replay contrôlé, DLQ/quarantine selon le pattern retenu.

### 6.3 IBM MQ

À utiliser quand le besoin requiert un middleware MQ traditionnel, request/reply JMS, intégration legacy, garanties de livraison ou coexistence avec patrimoine bancaire.

Patterns à démontrer :
- persistent messages ;
- transactions ;
- backout threshold ;
- backout queue ;
- DLQ ;
- retry borné ;
- correlation ID ;
- poison message ;
- consumer restart ;
- bridge MQ -> Kafka lorsque justifié.

Réutiliser le dépôt `mayabank-ibm-mq-native-ha-openshift-eda-platform` plutôt que réécrire le socle MQ.

## 7. Decisioning

```text
Pega Case
   |
   +--> local orchestration rules
   |
   +--> IBM ODM Decision API
             |
             +--> policyVersion
             +--> decision
             +--> reasonCodes
             +--> reviewRequired
```

Règle : une décision à fort impact doit rester explicable, versionnée et auditable. Le résultat AI peut enrichir l’entrée d’une décision mais ne remplace pas la policy déterministe lorsqu’elle est obligatoire.

## 8. AI / GenAI / Agentic AI

### Capacités prévues

- case summarization ;
- next-best-investigation-step ;
- document classification/extraction ;
- RAG procédures ;
- recherche d’historique synthétique ;
- corrélation événements/logs ;
- génération de brouillon de résolution ;
- priorisation des dossiers ;
- outils MCP strictement allow-listés.

### AI Control Plane

```text
Pega
 |
 v
AI Gateway
 |
 +--> Model Router
 +--> Prompt Registry
 +--> RAG Service
 +--> Agent Orchestrator
 +--> MCP Tool Gateway
 +--> Evaluation
 +--> Guardrails
 +--> Audit
 +--> Cost/Token Metrics
```

### Guardrails obligatoires

- no autonomous financial execution ;
- tool allow-list ;
- scope/RBAC par tool ;
- confidence threshold ;
- provenance/citations dans les réponses RAG ;
- prompt injection controls ;
- redaction/minimisation ;
- human-in-the-loop pour actions sensibles ;
- journalisation des prompts/model/tool calls selon politique de sécurité ;
- modèle/provider abstrait du domaine métier.

## 9. OpenShift target architecture

### 9.1 Lab local

```text
OpenShift Local / CRC
  - Pega component(s) si licence/images autorisées
  - integration adapter(s)
  - mock payment services
  - PostgreSQL lab
  - Kafka-compatible lab si nécessaire
  - Keycloak lab
  - observability lab
```

CRC sert à tester déploiement, API, workflow, sécurité de base et scénarios applicatifs. **Pas de revendication HA node/zone/site.**

### 9.2 Cible entreprise

```text
                     OpenShift Cluster
+-------------------------------------------------------+
| Ingress / Routes / API Gateway                       |
|                                                       |
| Pega web / case workloads                             |
| Integration services                                  |
| AI adapters                                           |
|                                                       |
| Operators / platform services where supported         |
| GitOps / policy / observability agents                |
+-------------------------------------------------------+
       |              |              |             |
       v              v              v             v
   External DB    Kafka/Streams    IBM MQ       AI/ODM
```

Prévoir :
- namespaces par environnement ;
- quotas/LimitRanges ;
- requests/limits ;
- PodDisruptionBudget ;
- anti-affinity/topology spread ;
- NetworkPolicies ;
- secrets externalisés ;
- TLS ;
- image registry/scanning/signature ;
- operator compatibility vérifiée avant usage ;
- storage classes adaptées ;
- backup/restore ;
- route/ingress HA ;
- multi-zone seulement sur infrastructure qui le permet.

## 10. Data architecture

Séparer :
- base/runtime Pega ;
- systèmes de record business ;
- event store/logs ;
- documents/object storage ;
- RAG/vector index ;
- observability data ;
- audit compliance.

Le POC utilise uniquement des données synthétiques.

Les règles de rétention doivent être définies par type : case, audit, document, event, logs, traces, embeddings, prompts.

## 11. IAM et sécurité

```text
User / Service
   -> Identity Provider
   -> OIDC/OAuth2
   -> API Gateway / Pega
   -> RBAC / ABAC where justified
   -> downstream token / workload identity
```

À couvrir :
- SSO ;
- MFA pour personas sensibles ;
- least privilege ;
- service identities ;
- secrets rotation ;
- TLS/mTLS ;
- NetworkPolicies ;
- audit security events ;
- no hard-coded credentials ;
- dependency/image scanning ;
- SBOM/signature/admission selon cible ;
- séparation dev/preprod/prod.

## 12. Observabilité

Trois niveaux corrélés par `correlationId`, `caseId`, `paymentId/claimId` :

1. **Technique** : metrics, logs, traces, health, saturation.
2. **Integration** : API latency/error, Kafka lag, MQ depth/backout/DLQ.
3. **Métier** : cases créés, backlog, age, SLA breached, MTTR case, resolutions, manual-review rate, AI recommendation acceptance.

SLI/SLO candidats à définir après baseline mesurée.

## 13. Résilience / HA / PRA

Scénarios à tester lorsque l’infrastructure existe :
- pod Pega indisponible ;
- DB indisponible ;
- Kafka indisponible ;
- MQ indisponible ;
- Keycloak/IdP indisponible ;
- AI provider indisponible ;
- ODM indisponible ;
- API core timeout ;
- duplicate event ;
- out-of-order event ;
- poison message ;
- perte de zone ;
- perte de site.

Principe de dégradation : **l’indisponibilité de l’AI ne doit pas empêcher le traitement manuel essentiel du case**.

RPO/RTO doivent être définis par composant et validés par tests ; ne jamais transformer un objectif d’architecture en résultat mesuré.

## 14. GitOps / CI/CD

```text
Git
 -> CI
    -> lint / unit tests
    -> OpenAPI/AsyncAPI validation
    -> SAST/dependency scan
    -> image build
    -> SBOM/signature where available
 -> Registry
 -> Argo CD
 -> OpenShift
 -> smoke/E2E/security/resilience tests
 -> evidence
```

Environnements : `crc`, `dev`, `preprod`, `prod` avec base commune + overlays.

## 15. Sizing / Capacity

Entrées métier :
- nouveaux cases/jour ;
- pic cases/min ;
- nombre d’opérateurs simultanés ;
- étapes/case ;
- documents/case ;
- événements/case ;
- appels AI/case ;
- SLA ;
- croissance ;
- rétention.

Dimensions techniques :
- replicas ;
- CPU/RAM ;
- DB connections/IOPS/storage ;
- Kafka partitions/retention/lag ;
- MQ queues/depth/rates ;
- object storage ;
- AI requests/tokens/embedding volume.

Scénarios : x1 / x2 / x5 / x10. Les chiffres doivent être mesurés ou clairement marqués comme hypothèses.

## 16. FinOps / GreenOps

Mesures candidates :
- €/1000 cases ;
- €/investigation ;
- €/1000 API calls ;
- €/million events ;
- €/1000 AI calls ;
- token cost/case ;
- compute utilisation ;
- idle capacity ;
- storage growth ;
- non-prod shutdown ;
- retention optimisation ;
- right-sizing.

Aucune estimation carbone ne doit être présentée comme mesure réelle sans méthode et source explicites.

## 17. Azure portability

Après preuve locale :

```text
OpenShift Local / Enterprise OCP
        |
        | portable contracts
        v
Azure target
  - AKS or ARO depending architecture decision
  - Entra ID
  - APIM
  - Event Hubs / Service Bus where appropriate
  - Azure Database for PostgreSQL where appropriate
  - Key Vault
  - Azure Monitor / OpenTelemetry
  - Azure AI / Foundry services via adapter
```

Le domaine métier ne doit pas connaître le provider. Utiliser interfaces, adapters et configuration externe.

## 18. ServiceNow / ITOM

Intégration future :
- application/service inventory ;
- CMDB CI relationships ;
- incidents liés à un case technique ;
- change request pour opérations contrôlées ;
- service mapping ;
- observability -> event/incident flow ;
- aucun auto-change critique déclenché directement par AI.

## 19. Insurance reuse

Second vertical :

```text
FNOL / Claim
 -> Pega Claim Investigation Case
 -> document ingestion
 -> policy retrieval
 -> fraud score
 -> ODM coverage/eligibility rules
 -> AI summary/RAG
 -> human claims handler
 -> deterministic claims core action
 -> case closure/audit
```

Même plateforme, mêmes patterns IAM/API/Event/AI/HITL/observability. Ne pas créer une seconde infrastructure complète.

## 20. Vues d’architecture à produire

- context diagram ;
- container/application diagram ;
- deployment OpenShift ;
- payment investigation sequence ;
- claims investigation sequence ;
- case state machine ;
- integration decision matrix REST/Kafka/MQ ;
- security trust boundaries ;
- data classification/retention ;
- HA/PRA view ;
- GitOps deployment view ;
- AI control plane view ;
- observability correlation view ;
- sizing/capacity view ;
- current/transition/target roadmap ;
- ArchiMate viewpoints ;
- ADR set.

## 21. Architecture Decision Records prévus

- ADR-001 — Pega as orchestration/case layer, not payment system of record
- ADR-002 — OpenShift as primary container platform
- ADR-003 — REST vs Kafka vs IBM MQ integration criteria
- ADR-004 — External deterministic decision service / ODM boundary
- ADR-005 — AI assistance with mandatory guardrails and HITL
- ADR-006 — Provider-neutral AI interface
- ADR-007 — PostgreSQL/data topology for lab vs enterprise
- ADR-008 — GitOps deployment model
- ADR-009 — HA/PRA strategy
- ADR-010 — AKS vs ARO for Azure target
- ADR-011 — ServiceNow integration boundary
- ADR-012 — Pega legacy baseline reuse vs clean cloud-native deployment

## 22. Preuve attendue en fin de programme

Une soutenance doit pouvoir montrer :

```text
Business problem
 -> case model
 -> architecture
 -> live/simulated event
 -> Pega case creation
 -> API/MQ/Kafka integration
 -> decision
 -> AI recommendation
 -> human approval
 -> deterministic execution
 -> observability
 -> audit
 -> failure scenario
 -> GitOps
 -> sizing / cost / resilience evidence
```

Le dépôt est un **programme de travail à réaliser ultérieurement**. Cette architecture est la cible et ne constitue pas à elle seule une preuve d’exécution.