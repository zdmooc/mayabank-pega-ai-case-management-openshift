# Runtime Evidence

Ce répertoire définit comment prouver les étapes exécutées sans publier de secrets.

## Raw evidence

`scripts/i3/preflight.sh` et `scripts/i3/verify.sh` écrivent leurs sorties brutes dans :

```text
evidence/runtime/raw/<UTC timestamp>/
```

Ce chemin est **gitignored**. Les sorties brutes peuvent contenir des noms internes, métadonnées de cluster ou valeurs de configuration qui nécessitent une revue avant publication.

## Curated evidence

Après revue/redaction, créer des preuves synthétiques versionnables sous :

```text
evidence/runtime/curated/
```

Exemples :

- `VERSIONS.md`
- `PODS.md`
- `ROUTE.md`
- `SMOKE_TEST.md`
- `LOGIN_VALIDATION.md`
- `KNOWN_LIMITATIONS.md`

`I3_RUNTIME_STATUS.md` peut être généré par `verify.sh`. Le relire avant commit.

## Forbidden evidence

Ne jamais versionner :

- `.env` ;
- mots de passe ;
- tokens ;
- kubeconfig ;
- pull secrets / `.dockerconfigjson` ;
- private keys ;
- valeurs Helm brutes contenant credentials ;
- dumps Pega ou données client réelles ;
- images/binaires Pega propriétaires non redistribuables.

## Claim levels

| Claim | Minimum evidence |
|---|---|
| `DESIGNED` | architecture/versioned configuration |
| `CONFIGURED` | configuration rendered and reviewed |
| `DEPLOYED` | Helm/OpenShift resources exist |
| `DEPLOYED_TRANSPORT_VALIDATED` | release exists + pods Ready + HTTPS responds |
| `RUNTIME_VALIDATED_BY_USER_LOGIN` | previous checks + real login confirmed by operator |
| `HA VALIDATED` | multi-node failure test evidence — impossible to infer from CRC single-node |

## Rule

A README/CV statement must not be stronger than the highest evidence level available in this directory.
