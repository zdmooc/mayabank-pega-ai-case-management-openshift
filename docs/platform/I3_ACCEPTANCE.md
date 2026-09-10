# I3 — Acceptance / Definition of Done

## Scope

I3 comporte désormais deux tracks complémentaires :

1. **Track A — legacy-pe84-local** : exploiter le package Pega Personal Edition 8.4.0 réellement disponible pour obtenir des preuves locales ;
2. **Track B — modern-pega26-openshift** : conserver l'infrastructure-as-code OpenShift/Helm prête pour Pega Infinity 26 lorsque les images/licences seront disponibles.

## Track B — Modern OpenShift

| Exigence | Preuve | Statut |
|---|---|---|
| Namespace | `openshift/crc/namespace.yaml` | DONE |
| ResourceQuota | `openshift/crc/resourcequota.yaml` | DONE |
| LimitRange | `openshift/crc/limitrange.yaml` | DONE |
| RBAC | `openshift/crc/rbac-observer.yaml` | DONE |
| Secrets | `.gitignore`, `.env.example`, scripts I3 | DONE |
| PostgreSQL template | `openshift/crc/postgres-lab.yaml.tpl` | READY / compatibility gate |
| Helm Pega | `openshift/helm/pega-values-crc.overlay.yaml.tpl` | READY / entitlement gate |
| Route TLS | `ensure-route-tls.sh` | READY |
| NetworkPolicies | staged policy | READY |
| Validation statique | `static-validate.sh` | READY |
| Preflight | `preflight.sh` | READY |
| Deploy | `deploy.sh` | READY |
| Verify/evidence | `verify.sh` + `evidence/README.md` | READY |
| Cleanup | `cleanup.sh` | DONE |

**Track B status: PASS — DEPLOYMENT READY DESIGN.**

Il reste bloqué à l'exécution parce qu'aucune image/licence Pega Infinity 26 n'est actuellement disponible.

## Track A — Pega 8.4 local

L'inventaire confirme Pega PE 8.4.0, Java 8u121, Tomcat 8.x, PostgreSQL embarqué, `prweb.war`, `prhelp.war` et le driver PostgreSQL 42.0.0.

Les scripts `scripts/i3-legacy/collect-pe84-evidence.ps1` et `scripts/i3-legacy/README.md` servent à relever sans secret :

- version Java ;
- version Tomcat exacte ;
- version PostgreSQL exacte ;
- tailles et SHA-256 des artefacts ;
- présence du dossier `webapps/prweb` ;
- état des processus/ports si le runtime est démarré ;
- preuve de réponse HTTP locale.

### Track A runtime gate

Pour passer à `RUNTIME VALIDATED`, il faut encore exécuter localement :

```powershell
powershell -ExecutionPolicy Bypass -File scripts\i3-legacy\collect-pe84-evidence.ps1
```

Puis :

1. démarrer Personal Edition avec ses scripts historiques ;
2. vérifier la base PostgreSQL ;
3. ouvrir Pega dans le navigateur ;
4. confirmer un login réel ;
5. conserver les preuves nettoyées.

## Ce qui n'est pas encore revendiqué

- Pega 8.4 fonctionnel sur CRC ;
- Pega 8.4 containerisé avec succès ;
- Pega 26 déployé ;
- Customer Service/CDH/Constellation disponibles ;
- HA/PRA validés.

## Gate global I3

```text
I3 INFRA / AUTOMATION            = PASS — DEPLOYMENT READY
I3 LEGACY LOCAL AUDIT TOOLING    = PASS — READY TO RUN
I3 PEGA 8.4 LOCAL RUNTIME        = PENDING OPERATOR EXECUTION
I3 PEGA 8.4 ON OPENSHIFT         = NOT YET VALIDATED
I3 PEGA 26 ON OPENSHIFT          = BLOCKED BY ENTITLEMENT
```

I3 est donc terminé côté **architecture, scripts et préparation**. Le seul travail restant pour le statut runtime est l'exécution sur la machine de l'opérateur.
