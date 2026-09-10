# I1 — Case Model MayaBank

## Objectif

Définir le modèle de Case Management du scénario CRM + Payment Investigation. Ce modèle est volontairement indépendant de l'implémentation Pega exacte afin de pouvoir être transposé proprement vers la version retenue en I2.

## Hiérarchie fonctionnelle

```text
Customer Interaction
  |
  +--> Service Request: PAYMENT_NOT_RECEIVED
          |
          +--> Investigation: PAYMENT_UNKNOWN
          +--> Investigation: FRAUD_REVIEW           (si nécessaire)
          +--> Investigation: RECONCILIATION_BREAK  (si nécessaire)
          +--> Investigation: DUPLICATE_PAYMENT     (si nécessaire)
          +--> Service Request: REFUND_REQUEST      (si besoin)
          +--> Service Request: RECALL_REQUEST      (si besoin)
```

Les relations ne sont pas toutes des relations parent/enfant Pega. La décision parent-child vs référence est prise selon le couplage du cycle de vie : un dossier qui doit vivre, être routé ou audité indépendamment doit pouvoir être référencé sans être artificiellement bloqué par le parent.

## Case Types

### 1. PAYMENT_NOT_RECEIVED

**But** : représenter la demande de service initiée depuis Customer Service.

**Déclencheur** : client signale qu'un paiement n'est pas reçu.

**Stages** :

1. `INTAKE`
2. `VERIFY_CUSTOMER`
3. `CHECK_PAYMENT`
4. `INVESTIGATE_OR_EXPLAIN`
5. `RESOLVE`
6. `CLOSE`

**Sorties** : explication, investigation liée, résolution, clôture.

### 2. PAYMENT_UNKNOWN

**But** : traiter un statut transactionnel ambigu sans supposer succès ou échec.

**Déclencheurs** : statut `UNKNOWN`, timeout sans résultat déterministe, événement de détection d'incohérence.

**Stages** :

1. `INTAKE`
2. `TRIAGE`
3. `INVESTIGATE`
4. `DECIDE`
5. `APPROVE_IF_REQUIRED`
6. `RESOLVE`
7. `VERIFY_OUTCOME`
8. `CLOSE`

**Assignments** : Payment Ops, Fraud Analyst si besoin, Supervisor si approbation/escalade.

### 3. FRAUD_REVIEW

**But** : isoler l'analyse fraude du cycle général.

**Déclencheur** : règle/score/agent signale un risque.

**Stages** : `INTAKE -> ANALYZE -> REQUEST_EVIDENCE -> DECIDE -> ESCALATE_OR_CLEAR -> CLOSE`.

**Sortie** : avis versionné, reason codes, éventuelle exigence d'approbation.

### 4. RECONCILIATION_BREAK

**But** : traiter une divergence entre événements, statut du core, ledger simulé ou réconciliation.

**Stages** : `DETECT -> COLLECT -> MATCH -> INVESTIGATE -> REMEDIATE -> VERIFY -> CLOSE`.

### 5. DUPLICATE_PAYMENT

**But** : traiter une suspicion de doublon sans exécuter automatiquement une correction financière.

**Stages** : `DETECT -> COMPARE -> VALIDATE -> APPROVE_IF_REQUIRED -> REQUEST_RESOLUTION -> VERIFY -> CLOSE`.

### 6. REFUND_REQUEST

**But** : gérer une demande de remboursement comme demande métier distincte.

**Stages** : `INTAKE -> ELIGIBILITY -> REVIEW -> APPROVE_IF_REQUIRED -> REQUEST_CORE_ACTION -> CONFIRM -> CLOSE`.

### 7. RECALL_REQUEST

**But** : orchestrer une demande de rappel de paiement lorsqu'elle est applicable.

**Stages** : `INTAKE -> VALIDATE -> SUBMIT -> WAIT_EXTERNAL -> CONFIRM -> CLOSE`.

## États canoniques

Les Case Types peuvent exposer des statuts métier plus précis, mais ils doivent se projeter sur les états canoniques :

- `NEW`
- `TRIAGE`
- `INVESTIGATING`
- `WAITING_EXTERNAL`
- `WAITING_CUSTOMER`
- `WAITING_APPROVAL`
- `READY_TO_RESOLVE`
- `RESOLVING`
- `RESOLVED`
- `CLOSED`
- `ESCALATED`
- `TECHNICAL_BLOCKED`
- `DUPLICATE`
- `CANCELLED`

## Modèle de données minimal d'un Investigation Case

```yaml
caseId: string
caseType: PAYMENT_UNKNOWN
businessDomain: PAYMENTS
customerIdSynthetic: string
serviceCaseId: string
interactionId: string
paymentId: string
correlationId: string
sourceEventId: string
sourceSystem: string
priority: P1|P2|P3|P4
severity: HIGH|MEDIUM|LOW
status: string
owner: string|null
workQueue: string
slaTargetAt: datetime
createdAt: datetime
updatedAt: datetime
paymentSnapshot:
  scheme: string
  amount: decimal
  currency: string
  status: string
  beneficiaryMasked: string
evidence: []
documents: []
decisions: []
approvals: []
resolution:
  code: string|null
  text: string|null
  coreCommandId: string|null
  outcomeEventId: string|null
auditRefs: []
```

## Work Queues

| Queue | Responsabilité |
|---|---|
| `CS-GENERAL` | demandes Customer Service non spécialisées |
| `PAYMENT-OPS` | investigations paiement |
| `FRAUD-OPS` | analyses fraude |
| `RECON-OPS` | divergences de réconciliation |
| `SUPERVISOR-APPROVAL` | approbations et escalades |
| `TECHNICAL-REVIEW` | dossiers bloqués par dépendance technique, sans décision métier |

## Routage

1. router par Case Type et criticité ;
2. appliquer compétences/entitlements lorsque disponibles ;
3. ne pas router un Case métier vers le SRE comme propriétaire de décision ;
4. réaffecter au Supervisor si SLA menacé ou règle d'escalade déclenchée ;
5. conserver l'historique de routage.

## SLA de démonstration

Valeurs **hypothétiques pour le POC**, non présentées comme SLA d'une banque réelle.

| Case Type | Goal | Deadline | Escalade |
|---|---:|---:|---|
| PAYMENT_NOT_RECEIVED | 30 min | 4 h | Supervisor à 80 % du deadline |
| PAYMENT_UNKNOWN P1 | 15 min | 1 h | immédiate si risque financier élevé |
| PAYMENT_UNKNOWN P2 | 1 h | 8 h | Supervisor à 6 h |
| FRAUD_REVIEW | 30 min | 2 h | Fraud Lead |
| RECONCILIATION_BREAK | 2 h | 1 jour ouvré | Recon Lead |

## Règles de clôture

Un Investigation Case ne peut être `CLOSED` que si :

- le résultat métier est connu ou le motif d'impossibilité est explicite ;
- toute action sensible requise a une approbation ;
- toute commande envoyée au core possède un identifiant idempotent ;
- le résultat de la commande est confirmé ;
- les décisions ont version/reason codes ;
- les preuves minimales sont attachées ou référencées ;
- l'audit contient les transitions principales.

## Réouverture

Réouverture autorisée si :

- nouvelle preuve contredit la résolution ;
- callback tardif modifie le statut financier ;
- plainte client post-résolution ;
- erreur de traitement confirmée.

La réouverture conserve le lien vers la résolution précédente et incrémente un compteur de réouverture.

## Duplicate / cancel

- `DUPLICATE` : relier au Case canonique ; ne pas supprimer l'historique.
- `CANCELLED` : uniquement avec motif explicite ; une action financière déjà soumise au core doit être traitée séparément.

## Audit minimal

Chaque événement important enregistre : acteur/service, timestamp, action, état avant/après, correlationId, reason code, référence de décision/approbation et identifiant de commande externe si applicable.

**Statut : DESIGNED — I1.**