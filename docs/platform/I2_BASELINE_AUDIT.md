# I2 — Audit de la baseline `pega-docker-repo`

## Résumé

Le dépôt `zdmooc/pega-docker-repo` est conservé comme **baseline historique / laboratoire legacy**, mais il n'est pas retenu comme cible principale 2026 pour `mayabank-pega-ai-case-management-openshift`.

## État observé au 10 septembre 2026

### Runtime

- `tomcat:8.5-jdk8-temurin` ;
- application Pega fournie manuellement sous forme `prweb.war` / `prhelp.war` ;
- PostgreSQL 13 ;
- Docker Compose ;
- un seul conteneur Pega ;
- `JAVA_OPTS` avec heap 2 GiB ;
- plusieurs NodeTypes (`Stream,BackgroundProcessing,WebUser,Search`) co-localisés dans le même runtime ;
- JNDI `jdbc/PegaRULES` et `jdbc/AdminPegaRULES` ;
- scripts de restauration PostgreSQL.

## Classification

| Élément | Décision | Justification |
|---|---|---|
| Modèle `.env.example` | REUSE PATTERN | utile comme convention de configuration locale, sans secret réel |
| `.gitignore` secrets/artefacts | REUSE PATTERN | garde-fou nécessaire |
| PostgreSQL healthcheck | REUSE CONCEPT | pattern utile, implémentation à adapter à OpenShift |
| scripts `pg_restore` | REUSE CONCEPT | utile pour restauration de lab, à adapter et documenter |
| JNDI datasource concepts | REFERENCE ONLY | le mécanisme concret dépend du runtime/chart Pega retenu |
| `prweb.war` copié dans image Tomcat | LEGACY | ne pas utiliser comme cible moderne par défaut |
| Tomcat 8.5 + Java 8 | LEGACY | ne doit pas représenter la cible Infinity '26 |
| Docker Compose | LEGACY/LAB | pratique pour historique, pas pour la cible OpenShift |
| NodeTypes tous co-localisés | DO NOT REUSE | contraire à l'objectif d'architecture scalable et observable |
| mot de passe PostgreSQL par défaut `pega` | DO NOT REUSE | acceptable uniquement comme squelette historique ; interdit pour le nouveau lab |
| port PostgreSQL publié sur host | DO NOT REUSE BY DEFAULT | inutile et élargit la surface d'exposition dans le nouveau lab |

## Risques si réutilisé tel quel

1. **Obsolescence technique** : le Dockerfile est centré Tomcat 8.5 / Java 8.
2. **Couplage des rôles** : web, background, stream et search sont regroupés.
3. **Sécurité** : valeur de mot de passe par défaut dans Compose ; absence de modèle secret OpenShift.
4. **HA inexistante** : un conteneur Pega, un PostgreSQL local.
5. **Observabilité limitée** : aucune preuve de métriques/traces structurées intégrées.
6. **Déploiement non représentatif** : pas de Helm Pega ni d'objets OpenShift.
7. **Search/stream architecture historique** : doit être recalée sur les dépendances et recommandations de la version Pega choisie.

## Décision

Le nouveau dépôt utilise un **déploiement OpenShift propre basé sur les mécanismes officiellement maintenus par Pegasystems**, avec valeurs/artefacts fournis par l'utilisateur selon ses droits.

`pega-docker-repo` reste utile pour :

- expliquer l'évolution d'une installation WAR/Tomcat vers un runtime containerisé orchestré ;
- récupérer les idées de restauration DB et de configuration externalisée ;
- comparer une architecture mono-runtime avec une architecture de plateforme moderne ;
- démontrer la capacité à auditer et moderniser un patrimoine Pega historique.

## Action sur l'ancien dépôt

Ne pas supprimer. Ajouter ultérieurement un bandeau README `LEGACY BASELINE / NOT TARGET ARCHITECTURE` si on souhaite éviter toute ambiguïté publique.

## Gate

**Audit terminé.** Aucun fichier binaire propriétaire Pega n'a été copié dans le nouveau dépôt.
