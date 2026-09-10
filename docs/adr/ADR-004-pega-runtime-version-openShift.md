# ADR-004 — Pega Infinity 26.1.1 + Helm/OpenShift comme cible de référence

- **Status**: Accepted with external entitlement gate
- **Iteration**: I2
- **Date**: 2026-09-10

## Context

Le dépôt historique `pega-docker-repo` utilise Tomcat 8.5 / Java 8, WAR Pega et Docker Compose. Le portfolio 2026 doit démontrer une architecture actuelle, reproductible et cohérente avec OpenShift.

La documentation publique Pega au 10 septembre 2026 liste Pega Infinity '26 26.1.1 publié le 1er septembre 2026 et maintient un dépôt officiel de Helm charts avec provider `openshift`.

## Decision

1. **Version préférée** : Pega Infinity 26.1.1.
2. **Fallback** : Infinity 25.1.3 si une contrainte vérifiée d'entitlement/compatibilité l'impose.
3. **Déploiement** : official Pegasystems Helm charts, provider `openshift`.
4. **Lab** : OpenShift Local / CRC pour déploiement fonctionnel, sans revendication HA.
5. **Database** : PostgreSQL dans le scénario de référence, major version à valider contre la matrice de support avant installation.
6. **Pega images** : jamais reconstruites ou publiées dans ce dépôt ; utiliser uniquement les artefacts auxquels l'utilisateur a légalement accès.
7. **Customer Service/CDH/GenAI** : capacités conditionnelles à leur entitlement ; absence d'accès = `DESIGNED ONLY`, jamais un mock présenté comme produit Pega.

## Rationale

- aligne le portfolio avec la génération Infinity actuelle ;
- exploite la compétence OpenShift ;
- élimine le faux signal d'une architecture cible WAR/Tomcat legacy ;
- garde la reproductibilité via Helm values, scripts et evidence ;
- sépare architecture de référence et droits d'accès propriétaires.

## Consequences

### Positive

- trajectoire claire vers un rôle Architecte Solution Pega ;
- modernisation démontrable ;
- meilleure séparation configuration/secrets/runtime ;
- intégration naturelle avec GitOps et observabilité.

### Constraints

- l'accès aux images Pega ne peut pas être garanti depuis GitHub ;
- le runtime réel dépend de la capacité du CRC ;
- certaines fonctions produits nécessitent des licences distinctes ;
- le chart exact doit être revalidé au moment de l'exécution.

## Verification

I3 fournit le namespace, garde-fous OpenShift, templates Helm, scripts de préflight/deploy/verify et index d'evidence. La mention `RUNTIME VALIDATED` reste interdite tant que ces scripts n'ont pas été exécutés avec succès sur un cluster réel.
