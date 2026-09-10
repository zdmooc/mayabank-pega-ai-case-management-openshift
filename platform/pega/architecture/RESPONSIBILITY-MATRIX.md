# Deployment responsibility matrix

| Capability | Pega Cloud | Client-managed OpenShift | On-prem self-managed |
|---|---|---|---|
| Pega runtime infrastructure | Pega | Customer/partner | Customer/partner |
| Kubernetes/OpenShift lifecycle | Pega | Customer/partner | Customer/partner |
| Vendor image acquisition | Pega-operated path | Customer-controlled entitlement path | Customer-controlled entitlement path |
| Internal registry governance | not customer Pega-runtime concern | Customer/partner | Customer/partner |
| Database infrastructure | Pega service responsibility | Customer/partner | Customer/partner |
| Pega application design/configuration | shared/customer app team | customer app team | customer app team |
| Enterprise IAM integration | shared | shared | shared |
| Business APIs/integrations | shared/customer | customer | customer |
| Platform observability | Pega-managed service + customer-visible tooling | customer/partner + PDC as applicable | customer/partner + PDC as applicable |
| Upgrade coordination | Pega-managed service process | customer/partner using supported process | customer/partner using supported process |
| DR infrastructure | Pega service scope | customer/partner | customer/partner |

Exact contractual responsibilities always come from the customer's current Pega agreement and service description; this table is an architecture working model, not a licence contract.