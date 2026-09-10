# I2-I8 architecture demo

## 15-minute technical walkthrough

1. Explain Pega product/licence and deployment responsibility options (I2).
2. Show the authorized artifact acquisition -> quarantine -> scan/SBOM -> approved registry chain (I3).
3. Explain why the official Pega Helm chart is pinned instead of copied (I4).
4. Show common + LOCAL/DEV/TEST/PREPROD/PROD environment contracts (I5).
5. Explain DB/SRS/clustering/API/Kafka/MQ dependencies and ownership (I6).
6. Show identity, TLS, secret and network-policy responsibilities (I7).
7. Show the immutable release tuple and GitOps promotion model (I8).
8. Finish by showing the evidence taxonomy and clearly state what is not runtime-validated without Pega entitlement.

## Interview claim

A correct claim today is:

> Designed a client-managed Pega platform architecture for OpenShift covering licensing/entitlements, official-image governance, Artifactory/registry promotion, Helm integration, multi-environment configuration, platform dependencies, IAM/security and GitOps release management.

Do **not** claim that Pega Infinity runtime or HA has been executed until evidence exists.