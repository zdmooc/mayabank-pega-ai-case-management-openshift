# I1 — Data Ownership & System of Record

## Principe

Une architecture CRM Pega ne doit pas transformer implicitement Pega en référentiel maître de toutes les données. Ce document fixe la responsabilité de chaque domaine avant toute implémentation.

## Matrice de propriété

| Domaine / objet | System of Record cible | Données conservées dans Pega | Mode d'accès | Commentaire |
|---|---|---|---|---|
| Customer identity | CRM/MDM simulé | référence + snapshot minimal de travail | API | Pega n'est pas MDM |
| Customer preferences | CRM/MDM / consent service simulé | copie nécessaire au Case | API/event | finalité explicite |
| Account | Core Banking simulé | référence + affichage masqué | API | solde = snapshot horodaté si affiché |
| Card | Card Core simulé | référence masquée | API | aucun PAN réel |
| Contract/Product | Contract Core simulé | référence | API | données utiles uniquement |
| Payment | Payment Core simulé | référence + snapshot du paiement investigué | API + event | autorité transactionnelle hors Pega |
| Ledger/Settlement | Payment/Ledger Core simulé | aucune autorité ; preuves/références seulement | API/event | jamais modifié directement par Pega |
| Customer Interaction | Pega Customer Service / CRM de service | oui | local/API | Pega peut être SoR de l'interaction dans le POC |
| Service Case | Pega | oui | local/API | Pega est SoR du Case |
| Investigation Case | Pega | oui | local/API/event | Pega est SoR du cycle de vie |
| Decision policy | Pega rules / ODM selon ADR futur | version + résultat + reason codes | API/local | source de politique explicite |
| Approval | Pega | oui | local | acteur, décision, timestamp, justification |
| Documents | DMS/Object Storage simulé | métadonnées + liens | API/object storage | séparation contenu/métadonnées |
| Audit Case | Pega + plateforme d'audit/log selon besoin | événements métier critiques | local/event | immutabilité à renforcer en cible |
| Observability | OTel/Dynatrace/stack logs | correlation IDs seulement | telemetry | pas de données sensibles inutiles |
| AI prompts/results | AI platform gouvernée | références/résumé selon politique | API | aucune autorité financière |

## Frontières d'écriture

### Pega peut écrire directement

- Case state ;
- assignments ;
- work queues ;
- SLA/escalation metadata ;
- interaction/service-request data appartenant à la couche de service ;
- notes/evidence references ;
- decision/approval references ;
- audit métier du dossier.

### Pega ne doit pas modifier directement

- ledger ;
- settlement ;
- solde bancaire ;
- statut financier autoritatif ;
- référentiel client maître ;
- politiques externes ODM sans processus de déploiement dédié.

Pour ces objets, Pega envoie une commande contractuelle au système propriétaire et attend un résultat déterministe.

## Cohérence et fraîcheur

Chaque snapshot externe utilisé dans une décision doit porter :

- `sourceSystem` ;
- `sourceRecordId` ;
- `retrievedAt` ;
- `sourceVersion` ou ETag lorsque disponible ;
- `correlationId` ;
- éventuellement `validAsOf`.

## Gestion de l'état UNKNOWN

`UNKNOWN` appartient au domaine paiement et signifie « résultat non déterminé ». Il ne doit pas être normalisé en erreur technique ni considéré comme échec définitif.

```text
Pega Case
 -> query Payment Core
 -> UNKNOWN
 -> collect evidence / reconcile / await callback
 -> deterministic outcome
 -> close case
```

## Documents

Le POC sépare :

```text
Case
  -> DocumentMetadata
       -> documentId
       -> classification
       -> checksum
       -> retentionClass
       -> objectStorageRef
```

Le dépôt Git ne contient aucun document client réel.

## Audit

Une décision significative doit permettre de retrouver :

- le Case et son état ;
- les données/snapshots utilisées ;
- la policy/rule version ;
- les reason codes ;
- l'acteur humain si approbation ;
- la commande envoyée au système de record ;
- le résultat reçu ;
- le timestamp et correlation ID.

## Rétention de démonstration

Les durées précises sont **TBD** car elles dépendent des exigences légales/entreprise. Le POC définit des classes (`OPERATIONAL_SHORT`, `CASE_AUDIT`, `DOCUMENT_POLICY`, `OBSERVABILITY_SHORT`) plutôt que d'inventer des durées réglementaires.

## Conséquence architecturale

Cette matrice est normative pour les itérations suivantes : si un nouveau composant veut devenir System of Record d'un domaine, une ADR doit justifier le changement.

**Statut : DESIGNED — I1.**