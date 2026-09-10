# Pega Solution Architect Operating Model

## Purpose

This document translates I2-I8 into the responsibilities a Pega Solution Architect must be able to explain during design reviews and interviews.

## End-to-end responsibility chain

```text
Product need
  -> Pega product/licence decision
  -> deployment responsibility model
  -> entitled artifact acquisition
  -> registry security approval
  -> release manifest
  -> Helm/OpenShift configuration
  -> dependency readiness
  -> IAM/TLS/network controls
  -> GitOps promotion
  -> runtime validation
  -> production change
  -> support/upgrade/rollback
```

## Architecture review questions

A Solution Architect should be able to answer:

- Which Pega products are required and why?
- Who owns the runtime: Pega Cloud or the customer?
- Which release and support lifecycle are targeted?
- How are official images acquired and governed?
- Which registry is authoritative for deployments?
- How are image digests, SBOMs, vulnerabilities and approvals tracked?
- Which database and platform services are required by the selected release?
- What differs between DEV, TEST, PREPROD and PROD?
- How are identities, secrets and certificates managed?
- How is configuration promoted with GitOps?
- What is the database-aware rollback strategy?
- Which claims are design-only, statically validated, runtime validated or HA validated?

## Interview demonstration target

The repository should eventually support a 20-30 minute walkthrough from a banking Customer Service case to the underlying Pega platform supply chain and production architecture, without claiming access to proprietary components that are not actually available.