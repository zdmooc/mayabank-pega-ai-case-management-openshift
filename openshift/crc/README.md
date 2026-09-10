# OpenShift Local / CRC — I3

Ce dossier contient uniquement les objets **possédés par le POC** autour du chart Pega officiel.

## Fichiers

- `namespace.yaml` — namespace et labels de classification ;
- `resourcequota.yaml` — plafond du lab, pas une réservation de capacité ;
- `limitrange.yaml` — défauts/garde-fous de ressources ;
- `rbac-observer.yaml` — ServiceAccount de lecture pour diagnostic ;
- `postgres-lab.yaml.tpl` — option PostgreSQL locale conditionnée par compatibilité ;
- `networkpolicies-staged.yaml` — hardening préparé mais non appliqué automatiquement.

## Ce qui appartient au chart officiel Pega

Le chart `pega/pega` reste responsable des workloads Pega, services, probes et Route OpenShift générés à partir de `openshift/helm/pega-values-crc.overlay.yaml.tpl`.

Le dépôt ne duplique pas les templates internes Pegasystems.

## Sécurité

Aucun secret réel ne doit être ajouté dans ce dossier. Les secrets sont créés par `scripts/i3/create-secrets.sh` à partir de valeurs locales ignorées par Git.

## CRC vs production

```text
CRC = validation fonctionnelle mono-nœud
Production = architecture multi-worker, DB HA, backing services dimensionnés,
             sécurité entreprise, observabilité et PRA validés séparément
```

Ne jamais utiliser les valeurs de quota/ressources CRC comme sizing de production.
