# Pega platform dependencies

Track each dependency against the selected Pega release support matrix before runtime deployment.

| Dependency | Required decision |
|---|---|
| Relational database | supported engine/version, schema strategy, HA, backup, TLS |
| SRS/search/reporting | release requirement, image/service topology, persistence, sizing |
| Clustering service | release requirement, replicas, discovery, failure behavior |
| API gateway | ownership, OAuth/mTLS, timeout/retry policy |
| Kafka | topic/contracts, idempotence, retry/DLQ/replay |
| IBM MQ | queue/JMS/TLS/backout/transaction pattern |
| IAM | supported protocol/integration, role mapping |
| Secret manager | injection/rotation/audit pattern |
| Observability | PDC/log/metric/trace responsibilities |

Do not freeze guessed versions in this public architecture. Supportability is validated only after the exact authorized Pega release is chosen.