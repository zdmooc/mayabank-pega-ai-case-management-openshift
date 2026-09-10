# I4 — Official Pega Helm / OpenShift Architecture

## Objective

Use the **official Pega Helm chart as the vendor deployment contract** and keep MayaBank-specific overlays, controls and architecture decisions in this repository.

> Status: **DESIGNED / STATIC VALIDATION POSSIBLE WITHOUT PEGA IMAGES**.

## Source-of-truth rule

Do not fork or copy the entire vendor chart into this repository. Instead:

1. pin an approved version/commit of `pegasystems/pega-helm-charts`;
2. inspect the chart values and OpenShift guidance for the selected Pega release;
3. maintain only MayaBank overlays, policies and validation scripts here;
4. update the pin through a controlled change when the vendor chart changes.

The chart version and the Pega application version are separate configuration items and must both be recorded.

## Target layers

```text
Vendor Pega Helm chart (pinned)
            |
            v
MayaBank common values
            |
            +--> local/CRC overlay
            +--> dev overlay
            +--> test overlay
            +--> preprod overlay
            +--> prod overlay
            |
            v
Rendered Kubernetes/OpenShift resources
            |
            v
Policy checks / security review
            |
            v
Argo CD deployment
```

## OpenShift responsibilities

The target OpenShift platform must provide or integrate:

- projects/namespaces;
- service accounts and RBAC;
- storage classes/PVCs;
- routes/ingress and TLS;
- network policy enforcement;
- secrets or external-secret integration;
- internal/private registry connectivity;
- DNS/NTP/certificates;
- observability;
- backup and restore;
- capacity and node placement;
- disaster-recovery architecture for production.

## Runtime topology

The exact Pega topology depends on the selected release and product. The architecture must explicitly identify:

```text
Route / ingress
      |
      v
Pega web/API workload(s)
      |
      +--> background/async workload(s)
      +--> clustering service (release dependent)
      +--> SRS/search/reporting services (release dependent)
      +--> integration endpoints
      |
      v
Relational database
```

No topology element is marked runtime-validated until an authorized Pega environment is actually executed.

## Static validation without proprietary images

Useful controls that do not require Pega image pull access:

```bash
helm lint <vendor-chart> -f values/common.yaml -f values/local.yaml
helm template pega <vendor-chart> -f values/common.yaml -f values/local.yaml > rendered.yaml
```

Then inspect rendered resources with policy-as-code tools where available.

A successful render proves only that the configuration is syntactically compatible with the selected chart. It does **not** prove that the Pega runtime starts, that database installation succeeds or that the topology is supported for production.

## Configuration contract

MayaBank overlays must not contain:

- registry passwords or pull tokens;
- database passwords;
- private keys;
- Pega proprietary binaries;
- customer-specific licence/order data;
- kubeconfig content.

Secret values are injected at runtime through a secret manager or CI/CD protected secret mechanism.

## Version manifest

Each environment must resolve to a release manifest such as:

```yaml
pegaRelease: "<authorized-release>"
pegaHelmChartRef: "<pinned-tag-or-commit>"
runtimeDigest: "sha256:<approved-digest>"
installerDigest: "sha256:<approved-digest>"
srsDigest: "sha256:<approved-digest-if-used>"
clusteringDigest: "sha256:<approved-digest-if-used>"
configurationRevision: "<git-commit>"
```

## Gate I4

I4 is complete at architecture level when the team can reproduce the Helm source pin, render an environment deterministically, trace every image to I3 governance and explain every OpenShift dependency.