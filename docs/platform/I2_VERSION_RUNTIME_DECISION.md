# I2 — Version / Runtime / Deployment Decision

## Decision date

2026-09-10 — mise à jour après audit du package local Pega 8.4 Personal Edition.

## Décision : deux baselines distinctes

Le projet sépare désormais strictement :

1. **baseline legacy réellement possédée par l'opérateur** : Pega Personal Edition **8.4.0**, candidate pour un lab local/reconstruction ;
2. **architecture cible moderne** : Pega Infinity **26.1.1** sur OpenShift via mécanismes Helm officiels, **DESIGNED ONLY** tant qu'aucun entitlement/image Pega moderne n'est disponible.

Cette séparation évite de présenter une architecture Pega 26 comme réellement exécutée alors que l'opérateur ne possède actuellement que les anciens artefacts Pega 8.

## Baseline legacy disponible

Audit source privé : `zdmooc/pega-8.4-personal-edition-audit`.

Faits confirmés par inventaire :

- package racine `116674_PE8.4.0` ;
- JDK/JRE `1.8.0_121` ;
- Apache Tomcat **8.x** confirmé par la présence de `tomcat8w.exe` ; patch exact à relever localement ;
- distribution PostgreSQL Windows embarquée ; version exacte à relever localement ;
- driver JDBC PostgreSQL `postgresql-42.0.0.jar` ;
- `prweb.war` et `prhelp.war` présents ;
- `PRPC_PE.jar` et `PersonalEdition.zip` présents ;
- scripts `startup.bat`, `shutdown.bat`, `pg_env.bat` ;
- configuration Tomcat `server.xml`, `context.xml`, `catalina.properties`, `web.xml`.

Empreintes confirmées :

- `prweb.war` SHA-256 : `434e2063f00fc36c17c1277292681c23fe2495789743cb33339f2f505329f691` ;
- `postgresql-42.0.0.jar` SHA-256 : `3bec21d1677f6cfce3e49d3578d4c84365264841753941197edf50363de28798`.

### Limites de preuve de la baseline legacy

L'inventaire confirme l'existence des artefacts mais **ne prouve pas** encore qu'ils constituent à eux seuls un runtime Pega 8.4 reconstruisible dans un conteneur.

En particulier :

- version exacte Tomcat à relever par `version.bat` ;
- version exacte PostgreSQL à relever par `postgres.exe --version` ;
- état et localisation de la base Pega existante à identifier ;
- contenu/configuration JNDI réelle à relever sans publier de secret ;
- aucun `prconfig.xml` ou `prbootstrap.properties` n'a été identifié dans la recherche d'inventaire actuelle ;
- le package audité expose le WAR mais aucune arborescence `webapps/prweb/WEB-INF/lib` n'a été identifiée dans l'inventaire binaire ;
- un démarrage/login réel reste nécessaire avant tout statut `RUNTIME VALIDATED`.

## Architecture cible moderne

### Cible

**Pega Infinity 26.1.1** reste la cible d'architecture et de modernisation.

Elle reste :

```text
TARGET ARCHITECTURE = Pega Infinity 26.1.1
EXECUTION STATUS    = DESIGNED ONLY / ENTITLEMENT REQUIRED
```

Le déploiement moderne utilise le dépôt officiel Pegasystems `pega-helm-charts`, OpenShift, une base supportée, les images autorisées, Clustering Service/SRS selon compatibilité, TLS, secrets et observabilité.

## Runtime tracks

| Track | Usage | Statut |
|---|---|---|
| `legacy-pe84-local` | audit/reconstruction Pega PE 8.4.0 existant | CANDIDATE — local verification required |
| `modern-pega26-openshift` | architecture cible entreprise | DEPLOYMENT READY DESIGN — entitlement required |

## Database decision

Pour le track legacy, conserver d'abord la base PostgreSQL historiquement associée au package afin de comprendre la configuration réelle. Ne pas migrer arbitrairement vers PostgreSQL 13/16 avant d'avoir identifié la version et le schéma d'origine.

Pour le track moderne, PostgreSQL reste le choix de lab, mais la version majeure/JDBC doit être vérifiée dans la matrice de compatibilité du patch Pega réellement obtenu.

## Sécurité / propriété intellectuelle

Aucun WAR/JAR/ZIP propriétaire Pega n'est versionné dans ce dépôt public. Les binaires legacy restent localement chez l'opérateur et ne sont référencés que par métadonnées/hashes.

## Gate I2

**I2 ARCHITECTURE DECISION: PASS.**

**LEGACY PACKAGE AUDIT: PASS — inventory confirmed.**

**LEGACY RUNTIME EXECUTION: PENDING LOCAL VERIFICATION.**

**MODERN PEGA 26 ENTITLEMENT: PENDING.**
