# MayaBank — Pega Solution Architecture

Portfolio d’architecture orienté **Architecte Solution Pega — CRM / Customer Service / Case Management / Decisioning / OpenShift — Certified SA & SSA**.

Le dépôt couvre deux dimensions complémentaires :

1. **architecture applicative Pega** : Customer Service, Customer 360, Case Management bancaire/assurance, Decisioning, Constellation et AI gouvernée ;
2. **architecture plateforme Pega** : licences/entitlements, distribution des images officielles, Artifactory/registry governance, Helm, OpenShift, sécurité, GitOps, observabilité, résilience et upgrades.

> **Statut au 10 septembre 2026 : I0-I1 cadrés ; I2-I8 architecture/configuration construites ; runtime Pega non validé faute d’images officielles autorisées.**
>
> Aucun composant Pega propriétaire, credential, licence client ou image vendor n’est publié dans ce dépôt. Les parties nécessitant un produit Pega réel restent `DESIGNED` / `STATICALLY VALIDATED` jusqu’à obtention d’un entitlement et d’evidence d’exécution.

## Architecture cible

```text
Customer / Agent / Channel
          |
          v
Pega Customer Service / Customer 360
          |
          v
Pega Case Management
          |
          +--> Rules / CDH / ODM
          +--> REST / API Management
          +--> Kafka / IBM MQ
          +--> Core Banking / Insurance simulé
          +--> AI assistant gouverné
          |
          v
Pega Platform
          |
          +--> Database
          +--> SRS / Search & Reporting (selon release)
          +--> Clustering services (selon release)
          |
          v
OpenShift / Client-Managed Platform
          |
          +--> IAM / TLS / Secrets / NetworkPolicies
          +--> Artifactory / Quay / Registry governance
          +--> Observability / SRE
          +--> GitOps / CI-CD
          +--> HA / PRA / Capacity
```

## POC métier principal

**MayaBank Customer Service & Payment Investigation** : un client signale un paiement instantané non reçu. L’agent consulte une vue Customer 360 synthétique, ouvre/rejoint un Service Request, puis Pega orchestre un Case `PAYMENT_UNKNOWN` jusqu’à investigation, décision, validation humaine éventuelle, résolution côté core payment et clôture/audit.

Principe : **Pega orchestre le Case ; le système de paiement reste System of Record financier.**

Un second vertical réutilisera le même socle pour **MayaInsurance Claims Investigation**.

## Les 4 POC du dépôt

### POC-A — CRM / Customer Service / Customer 360

- Customer 360 synthétique ;
- Customer Interaction ;
- Service Requests / Complaints ;
- routing / work queues / SLA / escalations ;
- historique d’interactions ;
- séparation Pega / systèmes de record ;
- audit, consentement, rétention.

### POC-B — Payment Investigation Case Management

```text
Wero / SCT Inst / Payment Core simulé
             |
             v
       API / Kafka / MQ
             |
             v
        Pega Case
             |
   +---------+----------+----------------+
   |                    |                |
PAYMENT_UNKNOWN    FRAUD_REVIEW   RECONCILIATION_BREAK
   |                    |                |
   +--------------------+----------------+
             |
             v
       Investigation
             |
       Rules / ODM
             |
       Human Approval
             |
             v
     Resolution / Audit
```

### POC-C — Pega Platform / Client-Managed OpenShift

Le POC plateforme couvre désormais explicitement :

```text
Pega entitlement
      |
      v
Authorized vendor distribution
      |
      v
Quarantine registry
      |
      +--> CVE scan
      +--> SBOM
      +--> provenance / digest
      |
      v
Approved Artifactory/Quay repository
      |
      v
Pinned Pega Helm chart + environment overlays
      |
      v
LOCAL -> DEV -> TEST -> PREPROD -> PROD
      |
      v
OpenShift
```

Le répertoire [`docs/modernization/`](docs/modernization/) documente les itérations I2-I8. Le répertoire [`platform/pega/`](platform/pega/) contient les contrats de release, registry et environnements.

### POC-D — Pega moderne : Constellation / Decisioning / AI

- Constellation selon version/entitlement ;
- Customer Decision Hub / Next Best Action selon licence ;
- stratégie Pega rules vs CDH vs IBM ODM ;
- case summarization / RAG procédures ;
- recommended next investigation step ;
- human-in-the-loop ;
- provenance, audit et guardrails.

```text
AI proposes
 -> Rules / policy validate
 -> Human approves when required
 -> Deterministic core executes
 -> Pega records outcome and audit
```

## Roadmap moderne I0 -> I17

```text
I0  Cadrage / architecture / Definition of Done
I1  CRM / Customer Service / Case Model

I2  Licences / produits / entitlements / support lifecycle
I3  Images / Registry / Artifactory / SBOM / CVE / promotion
I4  Helm officiel Pega / architecture OpenShift
I5  LOCAL / DEV / TEST / PREPROD / PROD
I6  Database / SRS / clustering / API / Kafka / MQ dependencies
I7  IAM / TLS / Secrets / RBAC / NetworkPolicies
I8  GitOps / Argo CD / release promotion

I9  Install / patch / upgrade / rollback / database-aware change
I10 Observability / PDC / logs / metrics / traces
I11 HA / PRA / backup / restore / RPO-RTO
I12 Sizing / performance / capacity / cost
I13 Pega Cloud vs Client-Managed vs On-Prem decision architecture
I14 Migration Pega 8.x -> modern Infinity / Constellation
I15 Customer Service / Customer 360 / Constellation runtime
I16 CDH / Decisioning / AI-GenAI gouvernée
I17 HLD / LLD / ADR-DAT / Architecture Board / CV mapping / demo finale
```

### Statut I2-I8

| Itération | Résultat actuel | Runtime Pega |
|---|---|---|
| I2 | architecture licences/entitlement + checklist | non applicable sans contrat réel |
| I3 | registry/Artifactory + image catalog + promotion + CI guards | image Pega non tirée |
| I4 | architecture Helm/OpenShift + règles de pin vendor | render réel à faire après pin du chart |
| I5 | overlays LOCAL/DEV/TEST/PREPROD/PROD | plateforme testable indépendamment |
| I6 | dépendances DB/SRS/clustering/API/Kafka/MQ | versions à aligner avec release Pega choisie |
| I7 | architecture IAM/TLS/secrets/network + secret guard | contrôles OpenShift testables |
| I8 | release manifest + GitOps/promotion + rollback DB-aware | Argo/Pega runtime à tester ultérieurement |

Voir [`docs/modernization/I2-I8-STATUS.md`](docs/modernization/I2-I8-STATUS.md).

## Sources techniques publiques de référence

La baseline moderne s’inspire notamment des dépôts publics vendor suivants, sans les copier comme preuve de supportabilité :

- `pegasystems/pega-helm-charts` — source vendor principale pour les charts/deployment patterns Pega Kubernetes/OpenShift ;
- `pegasystems/docker-pega-web-ready` — référence pédagogique/historique container ;
- `jfrog/charts` — patterns JFrog Platform/Artifactory ;
- `jfrog/jfrog-docker-repo-simple-example` — concepts local/remote/virtual repositories ;
- `jfrog/Evidence-Examples` — supply-chain evidence/provenance patterns.

Voir [`docs/modernization/PUBLIC-REFERENCE-REPOSITORIES.md`](docs/modernization/PUBLIC-REFERENCE-REPOSITORIES.md).

## Principes obligatoires

1. Pega orchestre Customer Service et Case Management ; les cores restent systèmes de record.
2. Aucune décision financière irréversible n’est confiée à un LLM autonome.
3. Les APIs/events/messages critiques sont idempotents, corrélés, auditables et disposent d’une stratégie retry/DLQ/backout.
4. Les produits/licences/entitlements sont vérifiés avant tout runtime.
5. Les images Pega officielles ne sont obtenues qu’avec un accès autorisé.
6. Une image est acquise/scannée une fois puis promue par **digest immuable** ; elle n’est pas reconstruite par environnement.
7. Secrets, pull secrets, mots de passe, private keys, kubeconfigs et contrats clients restent hors Git.
8. Le chart Pega officiel est piné ; la configuration MayaBank reste dans des overlays séparés.
9. Un rollback container n’est pas supposé sûr après un changement de schéma DB Pega.
10. CRC valide un lab local, jamais une HA multi-worker/multi-zone.
11. Toute affirmation `VALIDATED`, `TESTED`, `HA`, `RPO` ou `RTO` doit pointer vers une evidence reproductible.
12. Aucun nom, secret, donnée ou architecture interne d’une entreprise réelle n’est publié.

## Validation automatisée

Une GitHub Action [`Pega Architecture Guard`](.github/workflows/pega-architecture-guard.yml) vérifie notamment :

- absence d’artefacts binaires/propriétaires Pega dans le dépôt ;
- absence de secrets évidents ;
- présence des contrats de release/image governance ;
- syntaxe YAML.

Ces contrôles prouvent l’hygiène du dépôt, **pas l’exécution de Pega**.

## Evidence vocabulary

- `DESIGNED` : architecture documentée.
- `STATICALLY VALIDATED` : syntaxe/chart/policies vérifiés sans runtime.
- `PLATFORM VALIDATED` : OpenShift/registry/GitOps exécutés, éventuellement avec images substitutives.
- `RUNTIME VALIDATED` : runtime Pega autorisé réellement exécuté et smoke-tested.
- `HA VALIDATED` : scénarios de panne exécutés sur une infrastructure capable de démontrer la propriété HA.

## Prochaine étape exécutable

Sans images Pega officielles, la suite utile est : validation CI, CRC, registry/Artifactory lab avec images substitutives, OpenShift security controls, Argo CD, puis pin d’un chart Pega officiel et `helm lint/template`. Une fois l’entitlement obtenu, on remplace les placeholders par les digests autorisés et on passe au runtime.

Le backlog historique détaillé reste dans [`BACKLOG.md`](BACKLOG.md). La roadmap moderne I2-I8 et les gates sont dans [`docs/modernization/`](docs/modernization/).
