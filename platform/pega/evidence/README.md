# Evidence taxonomy

Use evidence labels precisely:

- `DESIGNED`: documented architecture only.
- `STATICALLY VALIDATED`: syntax/chart/policy validation passed, no Pega runtime proof.
- `PLATFORM VALIDATED`: OpenShift/registry/GitOps mechanics executed, potentially with substitute images.
- `RUNTIME VALIDATED`: authorized Pega runtime executed and functional smoke tests passed.
- `HA VALIDATED`: failure tests executed on infrastructure capable of proving the stated HA property.

Every evidence set should record timestamp, Git revision, chart ref, image digest(s), environment/context, command/test result and known limitations.

Never commit raw credentials, proprietary Pega content, customer data or unsafe logs.