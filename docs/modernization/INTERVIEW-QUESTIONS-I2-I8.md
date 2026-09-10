# Interview questions — Pega platform architecture

A candidate should be able to answer these without relying on proprietary customer information.

1. What changes between Pega Cloud and client-managed Pega?
2. How do you prove that a Pega image is authorized and the same artifact reaches production?
3. Why use an internal registry/Artifactory between vendor distribution and OpenShift?
4. What are quarantine, approved and virtual repositories?
5. Why pin a digest instead of `latest`?
6. What is the relationship between Pega release, Helm chart release and DB schema change?
7. Why can a container rollback be unsafe after a database upgrade?
8. What belongs in Git and what belongs in a secret manager/registry?
9. What differs between DEV, TEST, PREPROD and PROD?
10. What roles do database, SRS and clustering services play for the selected Pega release?
11. How do you integrate Pega with enterprise IAM, APIs, Kafka and MQ?
12. What can CRC prove, and what can it not prove?
13. How does Argo CD promote configuration while preserving image immutability?
14. What evidence is required before saying `RUNTIME VALIDATED` or `HA VALIDATED`?
15. How would you migrate an existing Pega 8.x estate toward a supported modern Pega/Constellation architecture?
