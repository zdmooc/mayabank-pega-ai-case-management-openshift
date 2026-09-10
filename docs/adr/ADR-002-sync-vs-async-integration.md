# ADR-002 — Choix synchrone vs asynchrone

- **Status**: Accepted
- **Iteration**: I1
- **Date**: 2026-09-10

## Context

Le parcours CRM/Payment Investigation doit combiner interactions agent, lectures métier, événements et traitements potentiellement longs. Utiliser un seul style d'intégration augmenterait soit le couplage, soit la complexité.

## Decision

### Synchrone

REST/API est privilégié quand l'utilisateur ou le workflow a besoin d'une réponse immédiate et bornée :

- recherche/lecture Customer 360 ;
- lecture d'un paiement ;
- appel d'une décision déterministe ;
- commande de résolution lorsque la sémantique permet une réponse immédiate.

Contraintes : timeout explicite, erreur métier distincte de l'erreur technique, correlation ID, idempotency key pour commandes sensibles, retry uniquement si sûr.

### Asynchrone

Kafka/Event ou IBM MQ est privilégié pour :

- détection `PaymentUnknownDetected` ;
- callbacks/outcomes tardifs ;
- intégration legacy ;
- découplage de traitements longs ;
- notifications et convergence ;
- audit/event propagation lorsqu'approprié.

Contraintes : contrat versionné, idempotence consumer, gestion duplicate/out-of-order, retry borné, DLQ/backout/quarantine selon technologie.

## Decision table

| Besoin | Pattern préféré |
|---|---|
| Customer read | REST |
| Payment read | REST |
| Create/query Case depuis canal externe | REST ou API Pega selon cible |
| PaymentUnknown event | Kafka/MQ |
| Resolution command | REST si immédiat ; MQ/event command si long/legacy |
| Resolution outcome tardif | event/message |
| ODM decision | REST synchrone avec fallback explicite |
| AI assistance | API asynchrone ou synchrone bornée ; jamais bloquante pour traitement essentiel |

## Consequences

Le Case doit représenter les attentes longues (`WAITING_EXTERNAL`) au lieu de garder une transaction technique ouverte.

## Verification

I5 définit OpenAPI et politiques de timeout/idempotence ; I6/I7 définissent AsyncAPI/MQ et tests de replay, doublons et poison messages.
