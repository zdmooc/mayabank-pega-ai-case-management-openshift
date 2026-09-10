# I1 — Use Case Catalog

## UC-CRM-001 — Customer identification and 360

**Actor** : Customer Service Agent  
**Trigger** : nouvelle interaction  
**Preconditions** : client synthétique identifiable, authentification simulée suffisante  
**Flow** : rechercher client -> vérifier contexte -> charger Customer 360 -> afficher dossiers/interactions/paiements pertinents  
**Outcome** : contexte agent prêt  
**Exceptions** : client introuvable, authentification insuffisante, source externe indisponible.

## UC-CRM-002 — Payment not received service request

**Actor** : Customer Service Agent  
**Trigger** : le client déclare un paiement non reçu  
**Flow** : créer interaction -> sélectionner motif -> saisir `paymentId` -> lire statut -> créer `PAYMENT_NOT_RECEIVED` -> créer/corréler investigation si nécessaire  
**Outcome** : Service Case traçable et relié au paiement.

## UC-PAY-001 — PAYMENT_UNKNOWN investigation

**Actor principal** : Payment Ops  
**Trigger** : statut transactionnel `UNKNOWN`, timeout ambigu ou événement d'incohérence  
**Flow** : triage -> collecte des preuves -> consultation core/réconciliation -> décision -> approbation éventuelle -> résolution -> confirmation -> clôture  
**Outcome** : état déterministe et auditable.

## UC-PAY-002 — Fraud review

**Acteur** : Fraud Analyst  
**Trigger** : signal de risque ou règle de triage  
**Flow** : collecter éléments utiles -> analyser -> produire avis/reason codes -> recommander clear/escalate/block selon politique simulée  
**Outcome** : décision de fraude référencée depuis le Case principal.  
**Contrainte** : aucun LLM ne prend seul une décision financière irréversible.

## UC-PAY-003 — Reconciliation break

**Acteur** : Reconciliation Ops  
**Trigger** : divergence entre statut, événement et preuve de réconciliation  
**Flow** : collecter sources -> comparer -> identifier la divergence -> proposer remédiation -> vérifier convergence  
**Outcome** : divergence résolue ou explicitement escaladée.

## UC-PAY-004 — Duplicate payment

**Acteur** : Payment Ops  
**Trigger** : deux transactions potentiellement équivalentes  
**Flow** : comparer clés métier -> vérifier réalité du doublon -> appliquer règle -> approbation si nécessaire -> demander action au core  
**Outcome** : doublon confirmé/réfuté et traitement audité.

## UC-PAY-005 — Refund request

**Acteur** : Customer Service / Payment Ops  
**Trigger** : demande de remboursement  
**Flow** : intake -> contrôle d'éligibilité -> revue -> approbation si nécessaire -> commande au core -> confirmation  
**Outcome** : demande terminée avec résultat externe confirmé.

## UC-PAY-006 — Recall request

**Acteur** : Customer Service / Payment Ops  
**Trigger** : demande de rappel  
**Flow** : intake -> validation -> soumission -> attente externe -> résultat -> clôture  
**Outcome** : rappel accepté, refusé ou expiré avec reason code.

## UC-OPS-001 — SLA escalation

**Actor** : Pega workflow / Supervisor  
**Trigger** : goal/deadline atteint ou criticité élevée  
**Flow** : notifier -> prioriser -> réassigner ou superviser -> tracer l'action  
**Outcome** : traitement renforcé sans perdre l'historique.

## UC-OPS-002 — Technical dependency unavailable

**Actor** : Integration layer / SRE  
**Trigger** : Core/API/MQ/Kafka/ODM indisponible  
**Flow** : classifier erreur -> `TECHNICAL_BLOCKED` ou `WAITING_EXTERNAL` -> retry borné uniquement si sûr -> diagnostic -> reprise -> réconciliation  
**Outcome** : aucun faux résultat métier produit à partir d'une panne technique.

## UC-AUD-001 — Audit a case

**Actor** : Auditor  
**Trigger** : contrôle a posteriori  
**Flow** : ouvrir en lecture seule -> revoir transitions -> décisions -> approbations -> commandes externes -> outcome -> réouvertures  
**Outcome** : chaîne de décision explicable.

## Matrice Case Type / Persona

| Case | CS Agent | Payment Ops | Fraud | Supervisor | Auditor | SRE |
|---|---:|---:|---:|---:|---:|---:|
| PAYMENT_NOT_RECEIVED | R/W | R | - | R/W | R | - |
| PAYMENT_UNKNOWN | R | R/W | R | R/W | R | tech-read |
| FRAUD_REVIEW | limited | R | R/W | R/W | R | - |
| RECONCILIATION_BREAK | R | R/W | - | R/W | R | tech-read |
| DUPLICATE_PAYMENT | R | R/W | R | R/W | R | - |
| REFUND_REQUEST | R/W | R/W | R | approve | R | - |
| RECALL_REQUEST | R/W | R/W | - | approve | R | - |

`R/W` est une intention fonctionnelle ; le modèle d'autorisation concret sera défini en I5.

## Données de test

Tous les identifiants, montants, clients et comptes sont synthétiques. Aucun scénario du dépôt ne doit contenir de donnée client réelle.

**Statut : DESIGNED — I1.**