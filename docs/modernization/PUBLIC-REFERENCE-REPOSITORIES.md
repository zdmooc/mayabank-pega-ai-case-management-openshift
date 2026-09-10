# Public reference repositories

This portfolio uses public vendor repositories as architectural references while keeping MayaBank configuration independent.

## Pegasystems

- `pegasystems/pega-helm-charts`
  - primary reference for Pega deployment on Kubernetes/OpenShift;
  - use the official chart and deployment documentation as source-of-truth for supported chart keys, image coordinates, platform services, install and upgrade workflows;
  - pin an explicit tag/commit before validation.

- `pegasystems/docker-pega-web-ready`
  - historical/educational reference for understanding Pega web-ready containerization patterns;
  - not used as the modern deployment source-of-truth when the official Helm deployment model applies.

## JFrog

- `jfrog/charts`
  - reference for JFrog Platform / Artifactory deployment patterns on Kubernetes;
  - useful for registry topology, TLS, secrets, persistence, HA and lifecycle concepts.

- `jfrog/jfrog-docker-repo-simple-example`
  - reference for Docker repository patterns such as local, remote and virtual repositories.

- `jfrog/Evidence-Examples`
  - reference for software-supply-chain evidence, Build Info and provenance-oriented workflows.

## OpenShift / security references

The MayaBank portfolio may also reuse generic patterns from its existing OpenShift repositories for:

- registry restrictions;
- image digest pinning;
- secret management;
- GitOps;
- policy-as-code;
- disconnected/mirrored registry architecture.

## Rule

Public examples are **inspiration, not proof of supportability**. For a real Pega deployment, the selected Pega release documentation, support matrix, entitlement and official chart version take precedence.