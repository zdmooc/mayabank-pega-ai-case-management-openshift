# ADR-001 — Pega orchestre les Cases ; le Payment Core reste autorité financière

- **Status**: Accepted
- **Iteration**: I1
- **Date**: 2026-09-10

## Context

Le POC doit démontrer Customer Service et Case Management autour d'incidents de paiement sans créer une architecture dans laquelle Pega devient implicitement ledger ou moteur de settlement.

## Decision

Pega est le **System of Record du Case et de son workflow**. Le Payment Core simulé reste le **System of Record du paiement, du ledger et des changements financiers irréversibles**.

Pega peut :

- créer et faire évoluer les Cases ;
- router les tâches ;
- gérer SLA, escalades, evidence et approbations ;
- lire les informations nécessaires depuis le core ;
- calculer ou demander des décisions ;
- envoyer une commande contractuelle de résolution ;
- enregistrer le résultat confirmé.

Pega ne modifie pas directement : ledger, settlement, balance ou statut financier autoritatif.

## Consequences

### Positive

- séparation claire des responsabilités ;
- idempotence et audit plus simples ;
- moins de couplage entre workflow et transaction ;
- architecture crédible pour un SI bancaire critique.

### Negative / Cost

- besoin d'API/événements de consultation et de commande ;
- gestion explicite des timeouts et états `UNKNOWN` ;
- nécessité de corréler Case et transaction.

## Rejected alternatives

### Pega comme ledger

Rejeté : mélange orchestration et autorité financière, augmente le risque de double écriture et rend la cohérence plus difficile.

### Mise à jour directe de la base du Payment Core

Rejetée : contourne les contrats du système de record, la logique métier et les contrôles d'accès.

## Verification

Les itérations I4/I5 devront prouver qu'une résolution passe par un contrat externe idempotent et que le Case n'annonce `RESOLVED` qu'après outcome déterministe.
