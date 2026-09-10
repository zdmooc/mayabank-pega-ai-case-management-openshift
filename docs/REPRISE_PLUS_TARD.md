# Point de reprise — à faire plus tard

Ce fichier est le point d’entrée pour reprendre le POC sans relire tout le dépôt.

## État actuel

- Dépôt initialisé.
- Architecture cible définie dans `docs/ARCHITECTURE.md`.
- Backlog I0 -> I17 défini dans `BACKLOG.md`.
- Aucun runtime Pega n’est déclaré installé ou validé dans ce dépôt.
- Aucun test OpenShift/Pega n’est déclaré exécuté.
- Le projet est volontairement **PARKED** jusqu’à reprise.

## Première action lors de la reprise

Commencer par **I1 — Domaine métier / Case Management**, pas par l’installation technique.

Ordre :

```text
1. Payment Investigation use cases
2. Case types / stages / states / SLA / work queues
3. BPMN + state machine + data model
4. Pega version / licence / images / prérequis
5. OpenShift Local / CRC deployment
6. Payment Investigation E2E
7. API + Security
8. Kafka
9. IBM MQ
10. IBM ODM
11. AI/RAG/Agent + HITL
12. Observability
13. GitOps
14. HA/PRA
15. Sizing / performance
16. FinOps / GreenOps
17. Insurance Claims reuse
18. Azure portability
19. Final DAT/HLD/LLD/Architecture Board pack
```

## Dépôts à relire avant de coder

- `zdmooc/pega-docker-repo` — baseline historique Pega/Tomcat/PostgreSQL ; ne pas copier aveuglément.
- `zdmooc/wero-organisme-poc` — modèle paiement, UNKNOWN, ledger, réconciliation, sécurité, observabilité, GitOps et résilience.
- `zdmooc/mayabank-api-management-architecture` — API governance/security.
- `zdmooc/mayabank-ibm-mq-native-ha-openshift-eda-platform` — MQ/JMS/backout/retry/HA.
- `zdmooc/mayabank-ibm-odm-ai-decision-architecture` — ODM/ML/GenAI/MCP/HITL.
- `zdmooc/TradeOps-GenAI-Integration` — RAG/agents/MCP/observability patterns.
- `zdmooc/keycloak-enterprise-roadmap-v7` — IAM.
- `zdmooc/argocd-expert-pack` — GitOps.
- `zdmooc/mayabank-carbon-aware-decision-architecture` — FinOps/GreenOps/decision patterns.
- `zdmooc/mayabank-azure-cloud-ai-platform` — Azure target.

## Questions à résoudre au moment de la reprise

1. Quelle version Pega est disponible et légalement utilisable pour le lab ?
2. Quels artefacts/images et quelle documentation de déploiement sont applicables à cette version ?
3. Quel composant de base de données est supporté dans le scénario retenu ?
4. Quelles dépendances Pega doivent être externes ?
5. Quelle partie est démontrable sur CRC, et quelle partie nécessite un vrai cluster multi-worker ?
6. Quels scénarios sont les plus vendeurs pour les missions Banque/Assurance du moment ?
7. Le premier vertical reste-t-il `PAYMENT_UNKNOWN`, ou le marché justifie-t-il de commencer par fraude/dispute/claims ?

## Critère pour reprendre le runtime

Ne lancer un déploiement Pega que lorsque :

- la version est choisie ;
- les droits/licences sont compris ;
- les images/artefacts autorisés sont accessibles ;
- la méthode de déploiement supportée est vérifiée ;
- le cluster dispose des ressources nécessaires ;
- les coûts éventuels sont connus ;
- les secrets ne seront pas commités.

## Cible portfolio

À terme, le dépôt doit permettre de démontrer en entretien :

```text
Architecture Solution
 -> Case Management Pega
 -> Payment/Claims domain
 -> API + Kafka + IBM MQ
 -> ODM Decisioning
 -> AI/RAG/Agent governed
 -> Human-in-the-loop
 -> OpenShift
 -> Security / Observability / GitOps
 -> HA/PRA
 -> Sizing / FinOps / GreenOps
 -> Azure portability
```

La priorité n’est pas d’accumuler les composants : la priorité est de produire **un parcours métier E2E démontrable avec preuves**, puis d’ajouter les capacités une par une.