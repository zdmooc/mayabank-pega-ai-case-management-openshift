# Modern Pega architecture validation scripts

These scripts validate repository contracts that are meaningful **before** an authorized Pega runtime is available.

## Commands

```bash
bash scripts/modern/validate-no-secrets.sh .
bash scripts/modern/validate-release-contract.sh
```

They check repository hygiene and release/image-governance contracts. They do not prove that Pega is installed or running.

## Runtime evidence

When entitlement and official images become available, add separate scripts for:

- vendor chart pin verification;
- Helm lint/template;
- image digest verification against the approved catalog;
- OpenShift prerequisite checks;
- Pega route/API smoke tests;
- sanitized evidence capture.

Do not weaken these guards to accommodate proprietary binaries in Git.