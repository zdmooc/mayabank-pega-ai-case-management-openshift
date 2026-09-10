# I3 — Runbook runtime Pega : legacy 8.4 + cible OpenShift moderne

## Statut

I3 est **prêt à exécuter**, avec deux tracks. Aucun track n'est déclaré `RUNTIME VALIDATED` sans preuve d'exécution réelle.

```text
Track A = Pega Personal Edition 8.4.0 local, réellement disponible
Track B = Pega Infinity 26.1.1 sur OpenShift/Helm, cible moderne sans entitlement actuel
```

## Track A — Pega 8.4 Personal Edition local

### Objectif

Établir d'abord la vérité technique du patrimoine réellement disponible avant toute containerisation : versions, artefacts, base, démarrage, login et configuration.

### 1. Collecte automatique sans secret

Depuis la racine du dépôt sous PowerShell :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\i3-legacy\collect-pe84-evidence.ps1
```

Le chemin par défaut est :

```text
C:\workspaces\paga\116674_PE8.4.0\PRPC_PE\PersonalEdition
```

Si la copie réellement utilisée est différente :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\i3-legacy\collect-pe84-evidence.ps1 `
  -Pe84Root 'C:\workspaces\paga\PersonalEdition'
```

Le script relève version Java, Tomcat, PostgreSQL, hashes/tailles d'artefacts, présence de l'application explosée, ports et réponse HTTP. Il ne copie aucun WAR/JAR ni contenu de configuration.

### 2. Démarrage historique

Utiliser les scripts du package local uniquement si les droits/licences permettent encore cet usage :

```text
PersonalEdition\scripts\startup.bat
PersonalEdition\scripts\shutdown.bat
PersonalEdition\scripts\pg_env.bat
```

Ne pas modifier la base avant d'avoir sauvegardé son état et identifié sa version.

### 3. Validation locale minimale

Pour déclarer `PE84 LOCAL RUNTIME VALIDATED`, conserver après redaction :

- version Java ;
- version Tomcat exacte ;
- version PostgreSQL exacte ;
- processus/ports attendus ;
- réponse HTTP `/prweb` ;
- capture/login Pega réussi ;
- état de la base ;
- anomalies observées.

Une réponse HTTP sans login ne suffit pas.

### 4. Avant containerisation

Vérifier :

- taille et structure réelle de `prweb.war` ;
- présence éventuelle d'un `webapps/prweb` explosé dans la copie active ;
- JNDI/DataSource dans Tomcat ;
- DB host/port/database/schema sans publier les credentials ;
- dépendances non incluses dans le WAR ;
- conditions de licence autorisant le lab local.

Le dépôt ne prétend pas encore que le WAR est autonome.

### 5. Portage Docker/OpenShift legacy

Seulement après validation locale :

```text
Pega 8.4 local validé
  -> reproduire Tomcat/Java compatibles
  -> externaliser JDBC/secret
  -> connecter à une copie contrôlée de la DB
  -> container local
  -> smoke test
  -> OpenShift CRC expérimental
```

Cette voie est un **POC de modernisation legacy**, pas la cible de production recommandée.

---

## Track B — Pega Infinity 26.1.1 / OpenShift

### Architecture

```text
Browser
  -> OpenShift Router / HTTPS Route
      -> Pega web/runtime tier
          -> PostgreSQL supporté
          -> Clustering Service
          -> futurs SRS/Kafka/ODM/API
```

CRC est mono-nœud : il valide packaging, manifests, routing et flux fonctionnels, pas HA/PRA.

### 1. Préparer les variables

```bash
cp .env.example .env
```

Renseigner uniquement lorsque les artefacts autorisés sont disponibles :

- `PEGA_WEB_IMAGE` ;
- `PEGA_INSTALLER_IMAGE` ;
- `PEGA_CLUSTERING_SERVICE_IMAGE` ;
- `PEGA_JDBC_DRIVER_URI` ;
- registry/pull secret ;
- version chart après vérification.

Ne jamais committer `.env`.

### 2. Validation statique

```bash
bash scripts/i3/static-validate.sh
```

### 3. Préflight CRC

```bash
bash scripts/i3/preflight.sh
```

Le script relève CRC/OpenShift, `oc`, Helm, StorageClass, capacité, domaine apps, dépôt Helm et paramètres runtime nécessaires.

### 4. Secrets

```bash
bash scripts/i3/create-secrets.sh
```

Les valeurs locales restent dans `.generated/` et dans des Secrets OpenShift ; elles ne sont pas versionnées.

### 5. PostgreSQL

La version PostgreSQL et le driver doivent correspondre au patch Pega réellement obtenu. Le template local :

```text
openshift/crc/postgres-lab.yaml.tpl
```

reste un lab mono-instance, pas une DB HA.

### 6. Premier déploiement moderne

Quand l'entitlement existe :

```bash
export CONFIRM_INITIAL_PEGA_INSTALL=yes
bash scripts/i3/deploy.sh
```

Le script utilise `pega/pega`, l'overlay CRC et `global.actions.execute=install-deploy` pour le premier schéma. Les déploiements ultérieurs utilisent `helm upgrade`.

### 7. Route TLS

```bash
bash scripts/i3/ensure-route-tls.sh
oc -n mayabank-pega get route
```

### 8. NetworkPolicies

Le default-deny reste volontairement staged. Après cartographie DB/SRS/Kafka/IAM/ODM/API :

```bash
export APPLY_NETWORK_POLICIES=true
export CONFIRM_NETWORK_POLICY_APPLY=yes
bash scripts/i3/apply-network-policies.sh
```

### 9. Vérification

```bash
bash scripts/i3/verify.sh
```

Après un vrai login :

```bash
export CONFIRM_PEGA_LOGIN=yes
bash scripts/i3/verify.sh
```

### 10. Cleanup

```bash
export CONFIRM_UNINSTALL=yes
bash scripts/i3/cleanup.sh
```

Les données ne sont supprimées que si `CONFIRM_DELETE_DATA=yes` est également fourni.

## Gate I3

```text
INFRA/CONFIG VERSIONED            = YES
MODERN DEPLOY AUTOMATION          = YES
LEGACY LOCAL EVIDENCE TOOLING     = YES
PEGA 8.4 LOCAL RUNTIME VALIDATED  = NO — operator run required
PEGA 8.4 ON CRC VALIDATED         = NO
PEGA 26 ON CRC VALIDATED          = NO — entitlement required
```

## Références modernes

- Pegasystems Helm charts : `https://github.com/pegasystems/pega-helm-charts`
- OpenShift deployment guide : `https://github.com/pegasystems/pega-helm-charts/blob/master/docs/Deploying-Pega-on-openshift.md`
- Pega installation/update information : `https://support.pega.com/installation-and-update-information-pega-products`
