# I1 — Acceptance & Traceability

## Résultat

I1 est une itération **de conception métier et Solution Architecture**. Elle ne nécessite pas de runtime Pega. Le statut attendu est `DESIGNED`, pas `RUNTIME VALIDATED`.

## Checklist de complétude

| Exigence I1 | Preuve | Statut |
|---|---|---|
| Customer Journey « paiement non reçu » | `docs/domain/CUSTOMER_JOURNEY_PAYMENT_NOT_RECEIVED.md` | DONE |
| Personas et rôles | Customer Journey + Case Model | DONE |
| Customer 360 synthétique | `docs/crm/CUSTOMER_360_MODEL.md` | DONE |
| Interactions / Service Requests | Customer Journey + Use Case Catalog | DONE |
| Canaux simulés | Customer Journey | DONE |
| Interaction -> Service Case -> Investigation | Customer Journey + Case Model | DONE |
| Work queues / routing / SLA | `docs/domain/CASE_MODEL.md` | DONE |
| KPI métier | Customer Journey | DONE |
| Rétention/audit | Customer 360 + Data Ownership | DONE |
| Case Types principaux | Case Model + Use Case Catalog | DONE |
| Stages / steps / assignments | Case Model | DONE |
| State machine | `docs/domain/STATE_MACHINE.md` | DONE |
| Process flow | `docs/domain/PROCESS_MODEL.md` | DONE |
| Data model du Case | Case Model | DONE |
| Clôture/reopen/duplicate/cancel | Case Model + State Machine | DONE |
| Audit requirements | Case Model + Data Ownership | DONE |
| System of Record | `docs/domain/DATA_OWNERSHIP.md` | DONE |
| Frontières Pega/Core/ODM/AI | Data Ownership + ADR-001 | DONE |
| Sync vs async | ADR-002 | DONE |
| Customer 360 access strategy | ADR-003 | DONE |

## Décisions validées par conception

1. Pega est SoR du Case, pas du ledger.
2. Customer 360 est agrégée et minimisée.
3. Les attentes longues deviennent des états du Case.
4. `UNKNOWN` est un état métier à investiguer, pas un échec supposé.
5. Les actions sensibles restent déterministes et/ou soumises à approbation humaine.
6. Les données de démonstration sont synthétiques.

## Ce qui n'est volontairement PAS revendiqué à I1

- Customer Service installé ;
- Constellation installé ;
- CDH disponible ;
- Case Types créés dans un runtime Pega ;
- SLA exécutés ;
- APIs/Kafka/MQ intégrés ;
- OpenShift validé.

Ces preuves appartiennent aux itérations I2+.

## Gate I1

**PASS — DESIGN COMPLETE** si tous les fichiers référencés sont présents dans la même révision Git et si aucune revendication de runtime n'est faite.

## Prochaine étape

I2 doit maintenant décider la baseline runtime : version Pega cible, entitlement/licence, produits accessibles, images autorisées, méthode Helm/OpenShift et stratégie de base de données.
