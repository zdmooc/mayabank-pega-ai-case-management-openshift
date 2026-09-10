# I3 — Runbook Pega Platform sur OpenShift Local / CRC

## Statut

Ce runbook rend I3 **prêt à exécuter**. Il ne déclare pas Pega installé tant qu'un opérateur n'a pas exécuté les scripts avec des artefacts Pega autorisés et conservé les preuves.

## Architecture du lab

```text
Browser
  -> OpenShift Router / HTTPS Route
      -> Pega web/runtime tier (CRC profile)
          -> PostgreSQL supported target
          -> Clustering Service
          -> optional future Kafka/SRS/ODM/API integrations
```

CRC est mono-nœud : ce lab valide packaging, chart, configuration, routage, connectivité et accès fonctionnel. Il **ne valide pas** HA multi-worker, multi-zone ou PRA.

## 1. Préparer les variables locales

```bash
cp .env.example .env
```

Renseigner au minimum :

- `PEGA_WEB_IMAGE` — image Pega autorisée ;
- `PEGA_INSTALLER_IMAGE` — image installer autorisée ;
- `PEGA_CLUSTERING_SERVICE_IMAGE` — image clustering-service adaptée ;
- `PEGA_JDBC_DRIVER_URI` — JDBC driver correspondant au PostgreSQL retenu ;
- éventuellement `PEGA_HELM_CHART_VERSION` après revue de `helm search repo pega --versions` ;
- informations registry si un pull secret doit être créé.

Ne jamais committer `.env`.

## 2. Vérifier la compatibilité Pega / DB / services

La baseline I2 préfère **Pega Infinity 26.1.1**. Avant le premier `install-deploy`, vérifier dans la documentation de support correspondant au patch réellement obtenu :

- version PostgreSQL ;
- version JDBC ;
- version Clustering Service ;
- exigences Search and Reporting Service / backing services ;
- exigences Customer Service/Constellation si ces produits sont utilisés.

Le dépôt ne fige volontairement pas une version PostgreSQL arbitraire comme vérité de production.

## 3. Validation statique

```bash
bash scripts/i3/static-validate.sh
```

Cette étape valide les manifests du dépôt et rend le chart officiel avec des placeholders non sensibles. Elle ne prouve ni entitlement ni exécution Pega.

## 4. Préflight CRC

```bash
bash scripts/i3/preflight.sh
```

Le script vérifie :

- CRC démarré ;
- `oc`, Helm, Git, Python ;
- identité et version du cluster ;
- nœuds / StorageClass / apps domain ;
- droits namespace ;
- disponibilité du dépôt Helm Pega ;
- métadonnées des images et JDBC ;
- snapshot de capacité ;
- état du pull secret.

Les sorties brutes vont dans `evidence/runtime/raw/<timestamp>/` et sont ignorées par Git jusqu'à revue.

## 5. Créer les secrets

```bash
bash scripts/i3/create-secrets.sh
```

Le script :

- crée/applique le namespace ;
- génère les mots de passe locaux manquants ;
- écrit les valeurs uniquement dans `.generated/credentials.env` (`chmod 600`, gitignored) ;
- crée `pega-postgres-secret` ;
- crée le pull secret si les credentials registry sont fournis.

Les mots de passe ne sont pas imprimés.

## 6. Base PostgreSQL

### Option recommandée

Utiliser une instance PostgreSQL déjà préparée et **explicitement compatible avec le patch Pega sélectionné**, puis renseigner `PEGA_JDBC_URL`.

### Option lab locale

Seulement après validation de compatibilité :

```text
DEPLOY_LOCAL_POSTGRES=true
POSTGRES_IMAGE=<image OpenShift-compatible et version vérifiée>
```

Le manifest `openshift/crc/postgres-lab.yaml.tpl` crée un StatefulSet et un PVC. Cette option reste un lab, pas une architecture DB HA.

## 7. Premier déploiement Pega

Le premier run installe le schéma puis le runtime ; il est donc protégé par une confirmation explicite :

```bash
export CONFIRM_INITIAL_PEGA_INSTALL=yes
bash scripts/i3/deploy.sh
```

Le script utilise le chart officiel Pegasystems, l'overlay CRC, un fichier temporaire chmod 600 pour les valeurs sensibles et `global.actions.execute=install-deploy` pour le premier déploiement.

Les runs suivants utilisent `helm upgrade` et ne redemandent pas l'installation initiale du schéma.

## 8. TLS / Route

Pour OpenShift, le chart officiel Pega génère une ressource `Route`. Avec TLS backend désactivé, son template OpenShift utilise une terminaison **edge** avec redirection HTTP -> HTTPS. `ensure-route-tls.sh` contrôle ce résultat et corrige uniquement l'absence inattendue de terminaison TLS.

```bash
bash scripts/i3/ensure-route-tls.sh
oc -n mayabank-pega get route
```

Pour une cible entreprise avec chiffrement route -> pod, préférer une configuration `reencrypt` compatible avec la configuration certificat Pega.

## 9. NetworkPolicies

Le fichier `networkpolicies-staged.yaml` contient un **default deny**. Il n'est donc pas appliqué automatiquement.

Avant activation, recenser précisément les flux vers DB, SRS, Kafka, IAM, ODM, API Gateway et autres dépendances.

Puis uniquement après revue :

```bash
export APPLY_NETWORK_POLICIES=true
export CONFIRM_NETWORK_POLICY_APPLY=yes
bash scripts/i3/apply-network-policies.sh
```

## 10. Vérification

```bash
bash scripts/i3/verify.sh
```

Le script contrôle :

- Helm release ;
- pods non terminés `Running/Ready` ;
- services, routes, PVC, jobs, événements ;
- réponse HTTPS sur plusieurs chemins Pega candidats ;
- snapshot de configuration technique.

Il produit `evidence/runtime/I3_RUNTIME_STATUS.md`.

### Après un vrai login Pega réussi

Une réponse HTTP seule ne prouve pas que l'application est fonctionnelle. Après avoir réellement ouvert le runtime et validé le login :

```bash
export CONFIRM_PEGA_LOGIN=yes
bash scripts/i3/verify.sh
```

Le statut peut alors devenir `RUNTIME_VALIDATED_BY_USER_LOGIN` si les autres contrôles restent verts.

## 11. Critères de preuve à conserver

Versionner après revue/redaction uniquement :

- version CRC/OpenShift ;
- version Helm chart ;
- version Pega / image digest ;
- architecture DB retenue ;
- `oc get pods` ;
- Route HTTPS ;
- capture d'écran du login/application si autorisée ;
- résultats smoke test ;
- anomalies et corrections.

Ne jamais versionner : secrets, mots de passe, `.dockerconfigjson`, kubeconfig, valeurs Helm brutes contenant des credentials.

## 12. Désinstallation

```bash
export CONFIRM_UNINSTALL=yes
bash scripts/i3/cleanup.sh
```

Par défaut, les données/PVC/secrets sont conservés. Pour les supprimer explicitement :

```bash
export CONFIRM_UNINSTALL=yes
export CONFIRM_DELETE_DATA=yes
bash scripts/i3/cleanup.sh
```

Le namespace reste volontairement présent pour inspection.

## 13. Références officielles utilisées

- Pegasystems Helm charts : `https://github.com/pegasystems/pega-helm-charts`
- OpenShift deployment guide : `https://github.com/pegasystems/pega-helm-charts/blob/master/docs/Deploying-Pega-on-openshift.md`
- Pega installation/update information : `https://support.pega.com/installation-and-update-information-pega-products`

## Gate I3

```text
CONFIGURATION VERSIONED         = YES
DEPLOYMENT AUTOMATION VERSIONED = YES
STATIC VALIDATION SCRIPT        = YES
RUNTIME VALIDATED ON CRC        = NO until operator execution succeeds
```
