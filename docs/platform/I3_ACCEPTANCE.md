# I3 — Acceptance / Definition of Done

## Scope

I3 a deux niveaux de complétude :

1. **DEPLOYMENT READY** — manifests, templates, scripts, sécurité et runbook versionnés ;
2. **RUNTIME VALIDATED** — ces éléments ont réellement été exécutés sur le CRC de l'opérateur avec des artefacts Pega autorisés.

Le premier niveau peut être terminé dans GitHub. Le second exige le cluster local et les entitlements Pega du propriétaire.

## Matrice

| Exigence I3 | Preuve versionnée | Statut |
|---|---|---|
| Namespace/projet lab | `openshift/crc/namespace.yaml` | DONE |
| ResourceQuota | `openshift/crc/resourcequota.yaml` | DONE |
| LimitRange | `openshift/crc/limitrange.yaml` | DONE |
| ServiceAccount/RBAC least privilege | `openshift/crc/rbac-observer.yaml` | DONE |
| Secret pattern sans valeur réelle dans Git | `.gitignore`, `.env.example`, `scripts/i3/create-secrets.sh` | DONE |
| Storage/PVC | template PostgreSQL + chart Pega | DONE AS DESIGN |
| Database lab | `openshift/crc/postgres-lab.yaml.tpl` | READY, COMPATIBILITY GATE |
| Déploiement Pega supporté | `pega/pega` overlay + `scripts/i3/deploy.sh` | READY, ENTITLEMENT GATE |
| Service / Route TLS | chart officiel + `ensure-route-tls.sh` | READY |
| Readiness/liveness | chart Pega + DB probes | READY |
| NetworkPolicies | staged policy + guarded apply script | READY, ENDPOINT MAPPING REQUIRED |
| Requests/limits | Helm overlay + ResourceQuota/LimitRange | DONE AS LAB CONFIG |
| Smoke test UI/API | `scripts/i3/verify.sh` | READY TO RUN |
| Limites CRC mono-nœud documentées | I2 prerequisites + I3 runbook | DONE |
| Evidence | `evidence/README.md` + verify/preflight | READY TO CAPTURE |
| Cleanup / data-safety | `scripts/i3/cleanup.sh` | DONE |
| Static validation | `scripts/i3/static-validate.sh` | READY TO RUN |

## Explicitly pending runtime facts

The repository must **not** claim these until evidence exists:

- Pega 26.1.1 image successfully pulled ;
- Pega schema successfully installed ;
- runtime pods Ready on the user's CRC ;
- HTTPS Route responding ;
- Pega login successful ;
- Customer Service product installed ;
- Constellation/CDH available ;
- any HA/RPO/RTO result.

## Gate status

**I3 IMPLEMENTATION: PASS — DEPLOYMENT READY.**

**I3 RUNTIME VALIDATION: PENDING OPERATOR EXECUTION.**

To close the runtime gate:

```bash
cp .env.example .env
# fill authorized image/JDBC/registry values
bash scripts/i3/static-validate.sh
bash scripts/i3/preflight.sh
bash scripts/i3/create-secrets.sh
export CONFIRM_INITIAL_PEGA_INSTALL=yes
bash scripts/i3/deploy.sh
# login manually to Pega
export CONFIRM_PEGA_LOGIN=yes
bash scripts/i3/verify.sh
```

Only after successful execution and evidence review can the backlog item “Pega réellement accessible sur CRC” be checked.
