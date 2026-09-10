# Next executable work

With I2-I8 architecture in place and no official Pega image entitlement available, the next executable sequence is:

```text
1. Validate repository guards in GitHub Actions
2. Start/verify OpenShift Local (CRC)
3. Validate namespace/RBAC/quota/network/TLS patterns with substitute workloads
4. Install/verify Argo CD if desired for the lab
5. Select and pin an official Pega Helm chart ref
6. Map architecture overlays to exact vendor chart keys
7. Run helm lint/template
8. Obtain authorized Pega images when entitlement becomes available
9. Mirror exact digests through quarantine/approved registry
10. Install supported database prerequisites
11. Deploy Pega
12. Run functional smoke tests and collect sanitized evidence
```

Steps 8-12 remain blocked for genuine Pega runtime until authorized artifacts are available.