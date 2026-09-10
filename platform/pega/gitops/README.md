# GitOps promotion model

## Source of truth

Git stores desired state and release metadata; the private registry stores Pega images; the secret manager stores credentials.

```text
Git PR -> validation -> merge -> Argo CD -> OpenShift
              |                      |
              v                      v
       release manifest        runtime evidence
              |
              v
     approved image digest
              |
              v
        private registry
```

## Promotion

- DEV: engineering approval and smoke tests.
- TEST: functional/integration regression.
- PREPROD: production-like security/performance/rollback validation.
- PROD: controlled change approval.

The exact organizational approval workflow is customer-specific; this public repository documents the architecture pattern only.