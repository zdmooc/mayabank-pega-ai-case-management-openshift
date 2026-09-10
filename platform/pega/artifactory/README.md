# Artifactory reference architecture for Pega images

This is a vendor-neutral architecture pattern that can be implemented with JFrog Artifactory or an equivalent enterprise registry.

```text
Authorized Pega distribution
          |
          v
acquisition job / controlled workstation
          |
          v
pega-quarantine-local
          |
     scan / SBOM / policy
          |
          v
pega-approved-local
          |
          v
pega-virtual
          |
          +--> DEV
          +--> TEST
          +--> PREPROD
          +--> PROD
```

## Artifactory concepts to demonstrate

- Docker local repository for quarantine;
- Docker local repository for approved artifacts;
- optional remote repository only if proxying the vendor registry is technically and contractually acceptable;
- virtual repository as the cluster-facing endpoint;
- Xray or equivalent vulnerability policy;
- immutable digest tracking;
- retention that preserves supported rollback candidates;
- robot/service accounts and TLS;
- audit trail for import and promotion.

Do not claim an upstream remote proxy is supported by Pega unless verified for the selected distribution mechanism. A controlled pull-and-push/mirror workflow remains a valid architecture pattern.