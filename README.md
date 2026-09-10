# MayaBank — Pega AI Case Management on OpenShift

Référentiel d’architecture et futur POC démontrable pour concevoir une plateforme de **Case Management Pega** orientée **banque / assurance**, intégrée à **OpenShift**, **API Management**, **Kafka / IBM MQ**, **IBM ODM** et à une couche **AI/GenAI gouvernée**.

> **Statut au 10 septembre 2026 : CADRAGE / ARCHITECTURE À CONSTRUIRE.**
> Aucun runtime Pega, OpenShift multi-nœuds, Kafka, IBM MQ, ODM ou composant AI n’est déclaré validé dans ce dépôt tant qu’une preuve d’exécution n’est pas versionnée.

## Positionnement

**Architecte Solution — Pega / Case Management / OpenShift / Integration / AI — Banque & Assurance**

Le dépôt doit démontrer la chaîne suivante :

```text
Business Case
  -> Case Management / BPMN / State Model
  -> Pega workflows + human tasks
  -> Rules / Decisioning
  -> APIs + Events + Messaging
  -> AI assistance / RAG / Agents gouvernés
  -> OpenShift
  -> Security / Observability / GitOps
  -> HA / PRA / Capacity / FinOps / GreenOps
```

## Cas d’usage fil rouge

Le cas principal sera **Payment Investigation & Exception Management** autour de la banque fictive **MayaBank** :

```text
Wero / SCT Inst / Payment Core
            |
            v
      API / Kafka / MQ
            |
            v
        Pega Case
            |
   +--------+---------+----------------+
   |                  |                |
 UNKNOWN Payment  Fraud Review   Reconciliation Break
   |                  |                |
   +------------------+----------------+
            |
            v
     Investigation Agent
            |
     Rules / ODM / RAG
            |
            v
        Human Review
            |
            v
     Resolution / Audit
```

Une seconde déclinaison doit réutiliser la même architecture pour **Insurance Claims Investigation**.

## Principes d’architecture

1. **Pega orchestre le case management ; le core bancaire/assurance reste le système de record.**
2. **Aucune décision financière irréversible n’est confiée à un LLM ou à un agent autonome.**
3. AI proposes -> rules validate -> human approves when required -> deterministic core executes.
4. Les intégrations synchrones et asynchrones sont choisies explicitement selon le besoin : REST/API, Kafka/Event Streaming ou IBM MQ.
5. Idempotence, correlation ID, audit trail, timeout, retry borné, DLQ/backout et traitement des états `UNKNOWN` sont obligatoires sur les flux critiques.
6. OpenShift Local/CRC peut servir aux preuves locales compatibles ; il ne prouve pas une HA multi-worker/multi-zone.
7. Les composants Pega propriétaires ne sont jamais embarqués dans Git sans droit/licence approprié.
8. Les secrets, kubeconfigs, pull secrets, mots de passe et états Terraform ne sont jamais versionnés.
9. Toute affirmation `VALIDATED`, `TESTED`, `HA`, `RPO` ou `RTO` doit être accompagnée d’evidence reproductible.

## Articulation avec les autres dépôts

Ce dépôt ne doit pas dupliquer les autres POC. Il doit les intégrer :

- `pega-docker-repo` : **baseline legacy/local** à analyser et éventuellement réutiliser comme point de départ historique ;
- `wero-organisme-poc` : source du domaine Payment / SCT Inst / Wero et des scénarios `UNKNOWN`, fraude, réconciliation et résilience ;
- `mayabank-api-management-architecture` : gouvernance API, OpenAPI, OAuth/OIDC, mTLS ;
- `mayabank-kafka-ddd-openshift` et `kafka-expert` : DDD, Event-Driven et Kafka ;
- `mayabank-ibm-mq-native-ha-openshift-eda-platform` : messaging IBM MQ, backout/retry, HA et intégration JMS ;
- `mayabank-ibm-odm-ai-decision-architecture` : règles déterministes, scoring/ML, GenAI documentaire, MCP et human review ;
- `keycloak-enterprise-roadmap-v7` : IAM/OIDC ;
- `dynatrace-observability-senior-project` : observabilité/SRE ;
- `mayabank-servicenow-csdm-cmdb-architecture` : exploitation, CMDB/CSDM/ITOM et intégration ITSM ;
- `mayabank-azure-cloud-ai-platform` : cible Azure/AKS/AI après validation locale ;
- `cadrage_202682030` : référentiel maître et priorisation portfolio.

## Architecture cible

La description détaillée est dans [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Roadmap

La construction est volontairement différée. Le dépôt doit être repris par itérations, sans déclarer de composant validé avant exécution :

- I0 — cadrage, architecture, backlog, Definition of Done ;
- I1 — domaine Case Management + modèle de données + BPMN/state model ;
- I2 — baseline Pega locale / stratégie d’accès aux artefacts autorisés ;
- I3 — déploiement Pega sur OpenShift ;
- I4 — Payment Investigation Case ;
- I5 — API Management / sécurité ;
- I6 — Kafka / EDA ;
- I7 — IBM MQ ;
- I8 — ODM / Decisioning ;
- I9 — AI/RAG/Agent assistant avec guardrails et HITL ;
- I10 — observabilité / audit / SLO ;
- I11 — GitOps / CI/CD / supply chain ;
- I12 — HA / résilience / RTO-RPO / PRA ;
- I13 — sizing / capacity / performance ;
- I14 — FinOps / GreenOps ;
- I15 — Insurance Claims reuse ;
- I16 — Azure AKS/ARO comparison / portability ;
- I17 — DAT/HLD/LLD, architecture board, démonstration et evidence finale.

Voir [`BACKLOG.md`](BACKLOG.md) pour la checklist complète.

## Definition of Done globale

Le POC ne sera considéré terminé que si :

- le parcours métier est documenté et testable ;
- les frontières Pega/Core/ODM/AI sont explicites ;
- les APIs/events/messages sont contractuels et versionnés ;
- la sécurité et l’audit sont démontrés ;
- les scénarios de panne sont documentés et, lorsqu’une infrastructure adaptée existe, testés ;
- les sizing hypotheses sont séparées des mesures ;
- une preuve reproductible existe pour chaque étape déclarée exécutée ;
- aucun nom, secret, donnée ou architecture interne d’une entreprise réelle n’est publié.
