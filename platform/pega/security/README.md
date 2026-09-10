# Pega platform security control inventory

This directory will hold OpenShift/Pega-adjacent security controls that are safe to publish as templates.

## Controls to implement/validate

- namespace-scoped ServiceAccounts and RBAC;
- default-deny NetworkPolicies with explicit flows;
- approved-registry enforcement;
- TLS route policy;
- external secret-manager integration pattern;
- database/API/Kafka/MQ secret references;
- enterprise IAM integration design;
- certificate ownership and rotation runbook;
- audit/evidence collection.

No production secret, token, private key or customer-specific endpoint belongs in Git.