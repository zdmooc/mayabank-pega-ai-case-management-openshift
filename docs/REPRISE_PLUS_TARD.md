# Point de reprise — Architecte Solution Pega

Ce fichier est le point d’entrée pour reprendre le POC sans relire tout le dépôt.

## État actuel

- Dépôt initialisé et repositionné vers **Architecte Solution Pega — CRM / Customer Service / Case Management / Decisioning / OpenShift**.
- Architecture cible définie dans `docs/ARCHITECTURE.md`.
- Backlog détaillé I0 -> I17 défini dans `BACKLOG.md`.
- Les travaux sont regroupés en 4 POC : CRM/Customer Service, Payment Investigation, Pega/OpenShift, Constellation/Decisioning/AI.
- Aucun runtime Pega n’est déclaré installé ou validé dans ce dépôt.
- Aucun composant Customer Service/CDH/Constellation n’est déclaré validé sans preuve.
- Aucun test OpenShift/Pega n’est déclaré exécuté.
- Le projet reste **PARKED** jusqu’à reprise effective.

## Première action lors de la reprise

Commencer par **I1 — CRM / Customer Service / Domaine métier / Case Model**. Ne pas commencer par l’AI ni par l’infrastructure.

Ordre recommandé :

```text
1. Customer Journey : "payment not received"
2. Personas / Customer 360 / Customer Interaction
3. Service Requests / Complaints / SLA / Work Queues
4. PAYMENT_UNKNOWN Case : stages / states / data model / audit
5. BPMN + state machine + data ownership
6. Pega version / licence / images / prérequis
7. OpenShift Local / CRC deployment
8. Customer Service + Payment Investigation E2E
9. API + IAM + Security
========= N1 CV DEMONTRABLE =========
10. Kafka
11. IBM MQ
12. Decisioning : Pega rules / ODM / CDH
13. Observability / PDC / SRE
14. GitOps / CI-CD
15. HA/PRA
16. Sizing / performance
========= N2 SOLUTION ARCHITECT =========
17. Constellation + UX moderne
18. AI/RAG/Agent + HITL
19. FinOps / GreenOps
20. Insurance Claims reuse
21. Azure portability
22. Final DAT/HLD/LLD/Architecture Board pack
========= N3 PORTFOLIO PREMIUM =========
```

## Les 4 POC à démontrer

### POC-A — CRM / Customer Service / Customer 360

```text
Customer
 -> Interaction
 -> Customer 360
 -> Service Request / Complaint
 -> SLA / Routing / Work Queue
 -> Investigation Case
```

### POC-B — Payment Investigation Case Management

```text
Wero / SCT Inst / Core simulé
 -> Payment UNKNOWN
 -> Pega Case
 -> Investigation
 -> Decision
 -> Human Approval
 -> Core Resolution
 -> Closure / Audit
```

### POC-C — Pega Platform sur OpenShift

```text
Pega runtime
 -> OpenShift
 -> TLS / RBAC / NetworkPolicy / Storage
 -> GitOps / CI-CD
 -> Observability
 -> Backup / Restore
 -> Capacity / Resilience
```

### POC-D — Pega moderne

```text
Constellation
 + Customer Decision Hub / Next Best Action
 + Pega rules / IBM ODM
 + AI / RAG assistant
 + Human-in-the-loop
```

## Dépôts à relire avant de coder

- `zdmooc/pega-docker-repo` — baseline historique Pega/Tomcat/PostgreSQL ; à auditer, pas à présenter comme cible 2026 par défaut.
- `zdmooc/wero-organisme-poc` — domaine Payment, UNKNOWN, fraude, réconciliation, résilience.
- `zdmooc/mayabank-api-management-architecture` — API governance, OAuth/OIDC, mTLS.
- `zdmooc/mayabank-kafka-ddd-openshift` et `zdmooc/kafka-expert` — Event-Driven / Kafka.
- `zdmooc/mayabank-ibm-mq-native-ha-openshift-eda-platform` — MQ/JMS/backout/retry/HA.
- `zdmooc/mayabank-ibm-odm-ai-decision-architecture` — règles déterministes / decisioning / AI governance.
- `zdmooc/TradeOps-GenAI-Integration` — RAG/agents/MCP/observability patterns.
- `zdmooc/keycloak-enterprise-roadmap-v7` — IAM/OIDC.
- `zdmooc/dynatrace-observability-senior-project` — Observability / SRE.
- `zdmooc/argocd-expert-pack` et `zdmooc/openshift-platform-blueprints` — GitOps / OpenShift.
- `zdmooc/mayabank-carbon-aware-decision-architecture` — FinOps/GreenOps.
- `zdmooc/mayabank-azure-cloud-ai-platform` — Azure target.

## Questions à résoudre au moment de la reprise

1. Quelle version Pega est disponible et légalement utilisable pour le lab ?
2. Quels artefacts/images et quelle documentation de déploiement sont applicables à cette version ?
3. Customer Service est-il accessible pour le POC ?
4. Constellation est-il accessible et pertinent pour la version retenue ?
5. Customer Decision Hub est-il accessible ? Si non, garder la partie `DESIGNED ONLY`.
6. Quel composant de base de données est supporté dans le scénario retenu ?
7. Quelles dépendances Pega doivent être externes ?
8. Quelle partie est démontrable sur CRC, et quelle partie nécessite un vrai cluster multi-worker ?
9. Quels scénarios sont les plus vendeurs pour les missions Banque/Assurance du moment ?
10. Le vertical principal reste-t-il `PAYMENT_UNKNOWN` ou faut-il prioriser complaint/fraud/dispute selon le marché ?

## Critère pour lancer le runtime

Ne lancer un déploiement Pega que lorsque :

- la version est choisie ;
- les droits/licences sont compris ;
- les images/artefacts autorisés sont accessibles ;
- la méthode de déploiement supportée est vérifiée ;
- le cluster dispose des ressources nécessaires ;
- les coûts éventuels sont connus ;
- les secrets ne seront pas commités.

## Charge indicative

- **N1 — CV démontrable : 25–35 h** ;
- **N2 — Architecte Solution solide : 50–70 h cumulées** ;
- **N3 — Portfolio premium : 70–100 h cumulées**.

Ces valeurs sont des estimations de planification à recalibrer après accès réel au runtime et aux composants Pega.

## Cible portfolio

À terme, le dépôt doit permettre de démontrer en entretien :

```text
Customer Journey
 -> CRM / Customer Service / Customer 360
 -> Case Management Pega
 -> Payment / Claims domain
 -> API + Kafka + IBM MQ
 -> Pega Rules / ODM / CDH Decisioning
 -> Constellation
 -> AI/RAG/Agent governed
 -> Human-in-the-loop
 -> OpenShift
 -> Security / Observability / GitOps
 -> HA/PRA
 -> Sizing / FinOps / GreenOps
 -> Azure portability
 -> DAT / HLD / LLD / Architecture Board
```

La priorité n’est pas d’accumuler les composants. La priorité est de produire **un parcours CRM + Case Management E2E démontrable avec preuves**, puis d’ajouter les capacités une par une.