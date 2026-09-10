# I2 — Audit de baseline legacy Pega

## Sources auditées

Deux sources historiques sont conservées :

- `zdmooc/pega-docker-repo` : squelette Docker/Tomcat/PostgreSQL historique ;
- `zdmooc/pega-8.4-personal-edition-audit` : inventaire privé du package local **Pega Personal Edition 8.4.0** réellement possédé par l'opérateur.

## 1. `pega-docker-repo`

Ce dépôt reste un **lab legacy / référence de patterns**, pas la cible moderne.

Éléments utiles :

- Tomcat 8.5 / Java 8 ;
- chargement manuel de `prweb.war` ;
- PostgreSQL ;
- JNDI `jdbc/PegaRULES` / `jdbc/AdminPegaRULES` ;
- scripts de restauration ;
- configuration externalisée par variables.

À ne pas reprendre tel quel : mot de passe par défaut, port DB exposé, co-localisation des NodeTypes, mono-runtime, absence de HA et de mécanismes OpenShift/GitOps.

## 2. Package local Pega PE 8.4.0

L'inventaire privé confirme :

```text
116674_PE8.4.0/
  PRPC_PE/
    PersonalEdition/
      jre1.8.0_121/
      pgsql/
      scripts/
      tomcat/
```

Faits utiles pour la reconstruction :

| Élément | Observation | Décision |
|---|---|---|
| Pega | package identifié `PE8.4.0` | BASELINE LEGACY CONFIRMED |
| Java | 1.8.0_121 | LEGACY, conserver pour audit uniquement |
| Tomcat | 8.x (`tomcat8w.exe`) | patch exact à mesurer |
| PostgreSQL | distribution embarquée | version exacte à mesurer |
| JDBC | `postgresql-42.0.0.jar` | référence historique |
| `prweb.war` | présent, SHA-256 versionné | artefact local uniquement |
| `prhelp.war` | présent | artefact local uniquement |
| `PRPC_PE.jar` | présent | artefact local uniquement |
| `PersonalEdition.zip` | présent | artefact local uniquement |
| scripts | startup/shutdown/pg_env | à analyser localement |
| Tomcat conf | server/context/catalina/web | à relever après redaction |

## Point important

L'existence de `prweb.war` ne suffit pas à prouver que le WAR est autonome ou directement containerisable. Le prochain contrôle doit mesurer : taille, version Tomcat/PostgreSQL, JNDI, état de la base, capacité à démarrer localement et login Pega.

La recherche d'inventaire actuelle n'a pas identifié `prconfig.xml` ou `prbootstrap.properties`, ni de bibliothèque sous `webapps/prweb/WEB-INF/lib`. Cela doit être revérifié sur l'installation réellement démarrée `C:\workspaces\paga\PersonalEdition` si elle diffère du package source.

## Stratégie retenue

```text
PEGA 8.4 PERSONAL EDITION
  -> audit local réel
  -> preuve de démarrage
  -> documentation de la configuration
  -> reconstruction contrôlée Docker si licence compatible
  -> portage expérimental OpenShift/CRC si techniquement et juridiquement permis

PEGA INFINITY 26
  -> architecture cible
  -> Helm officiel / OpenShift
  -> aucune revendication d'exécution sans entitlement
```

## Gate

**Audit legacy : PASS.**

**Reconstruction runtime : PENDING LOCAL EVIDENCE.**

Aucun binaire propriétaire n'est copié dans ce dépôt public.
