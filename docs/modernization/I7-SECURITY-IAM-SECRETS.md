# I7 — Security, IAM, TLS, Secrets & Network Controls

## Objective

Define a production-grade security architecture around Pega that separates identity, transport security, secrets, platform RBAC and application authorization.

> Status: **DESIGNED / OPENSHIFT CONTROLS CAN BE TESTED WITHOUT PEGA RUNTIME**.

## Security layers

```text
User / Agent
    |
    v
Enterprise IdP (OIDC/SAML according to supported Pega design)
    |
    v
Route / ingress TLS
    |
    v
Pega application authorization
    |
    +--> REST/API authentication
    +--> DB credentials
    +--> registry pull credentials
    +--> Kafka/MQ credentials
    |
    v
OpenShift namespace isolation / RBAC / NetworkPolicies
```

## Principles

- no shared administrator identities for normal operations;
- SSO through the enterprise identity provider where supported;
- least privilege at both Pega and OpenShift layers;
- separate human identities from service accounts;
- no secret values in Git;
- TLS for user, API, database and messaging paths where supported;
- certificate ownership and renewal process documented;
- production access audited;
- break-glass procedures separated from routine administration;
- secrets rotated without rebuilding application images;
- environment isolation prevents non-production credentials from accessing production.

## Secret classes

| Secret | Storage target | Git representation |
|---|---|---|
| Pega vendor registry credential | enterprise secret manager / protected CI secret | variable name only |
| Internal registry robot credential | secret manager / OpenShift Secret provisioned securely | template only |
| Database credential | secret manager | secret reference only |
| TLS private key | PKI/secret manager | never committed |
| API OAuth client secret | secret manager | client-id may be documented, secret never |
| Kafka/MQ password/certificate | secret manager | reference only |
| Pega administrative bootstrap secret | controlled secret process | never committed |

## OpenShift controls

Required design controls:

- dedicated project/namespace per environment or approved tenancy model;
- ServiceAccount per workload function when separation is justified;
- Role/RoleBinding rather than broad ClusterRole bindings for app operations;
- ResourceQuota and LimitRange;
- default-deny NetworkPolicies plus explicit egress/ingress allowances;
- image policy restricting deployment to approved registries;
- Security Context Constraints compatible with vendor requirements and least privilege;
- read-only/rootless posture where supported by the vendor image;
- audit logging and cluster monitoring;
- route TLS policy aligned to enterprise PKI.

Do not weaken an OpenShift SCC merely to make an image start without documenting and approving the security trade-off.

## IAM decision record

For each environment document:

```yaml
humanIdentityProvider: "<enterprise-idp>"
protocol: "<supported-oidc-or-saml-pattern>"
adminModel: "named-admins-plus-break-glass"
serviceIdentityModel: "dedicated-service-accounts"
apiAuth: "oauth2/mtls/as-designed"
secretBackend: "<enterprise-secret-manager>"
certificateAuthority: "<enterprise-pki>"
```

## Network segmentation

Minimum logical flows:

```text
Users -> Route/Ingress -> Pega
Pega -> Database
Pega -> SRS / clustering service
Pega -> API Gateway
Pega -> Kafka/MQ when required
Pega/cluster -> internal container registry
Observability agents -> monitoring backend
```

Everything else should be denied by default where feasible.

## Security evidence

Evidence that can be collected without Pega entitlement:

- namespace RBAC checks (`oc auth can-i`);
- network-policy manifests and connectivity tests using substitute workloads;
- TLS route/certificate checks;
- secret scanners on the Git repository;
- approved-registry policy tests;
- Helm-render policy checks.

Runtime-level Pega authentication and authorization remain `NOT VALIDATED` until an authorized runtime is available.

## Gate I7

I7 is complete when every identity, credential, certificate and network path has an owner, storage mechanism, rotation path and least-privilege control.