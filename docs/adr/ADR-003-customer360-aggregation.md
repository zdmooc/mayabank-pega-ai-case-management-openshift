# ADR-003 — Customer 360 agrégée, pas de duplication du MDM

- **Status**: Accepted
- **Iteration**: I1
- **Date**: 2026-09-10

## Context

Un écran Customer Service doit donner une vue suffisamment riche pour résoudre la demande. Une copie complète de Customer/Account/Payment dans Pega créerait duplication, problèmes de fraîcheur et gouvernance inutile.

## Decision

Customer 360 est une **vue logique agrégée**. Les données sont classées en trois catégories :

1. **Case-owned** : interaction, service request, investigation, notes, assignments, SLA — conservées dans Pega ;
2. **Reference/read-through** : identité, comptes, cartes, contrats — lues depuis leurs systèmes de record et minimisées ;
3. **Case snapshot** : données externes qui ont matériellement contribué à une décision — snapshot horodaté et référencé pour audit lorsque nécessaire.

Le chargement est progressif : les sections coûteuses sont chargées selon l'intention agent plutôt qu'en cascade systématique.

## Consequences

- le POC doit fournir des mocks/API pour les sources externes ;
- les écrans doivent afficher la fraîcheur des snapshots lorsque pertinente ;
- la perte temporaire d'une source doit être visible et ne pas être masquée par une donnée obsolète présentée comme actuelle ;
- aucune donnée personnelle réelle n'est stockée dans le dépôt.

## Rejected alternatives

### Répliquer toutes les données dans Pega

Rejeté : duplication, cohérence, rétention et sécurité plus difficiles.

### Toujours appeler toutes les sources à l'ouverture

Rejeté : latence, fragilité en cascade et charge inutile.

## Verification

I4 devra montrer une vue Customer 360 synthétique ; I5 ajoutera sécurité et contrats API ; I10 mesurera latence/erreurs et corrélation.
