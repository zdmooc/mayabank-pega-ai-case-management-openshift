# Multi-environment policy

The target environments are LOCAL/CRC, DEV, TEST, PREPROD and PROD.

Key rules:

- CRC is a developer/single-node lab and never proves production HA.
- Promote the same approved Pega image digest through environments.
- Store only intended environment differences in overlays.
- Use synthetic or masked data outside production.
- Keep production credentials/endpoints out of this public repository.
- Require explicit release/evidence gates between environments.

See `../values/` for example architecture overlays.