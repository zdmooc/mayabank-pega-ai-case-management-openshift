# Environment overlays

These files are **architecture contracts**, not direct copies of the official Pega Helm `values.yaml`.

Before runtime deployment:

1. pin the exact official `pegasystems/pega-helm-charts` release/commit compatible with the selected Pega release;
2. map these architecture fields to the vendor chart keys;
3. validate with `helm lint` / `helm template`;
4. keep secrets external;
5. pin approved internal image digests;
6. preserve the same release candidate across DEV -> TEST -> PREPROD -> PROD.

The repository deliberately avoids freezing guessed Pega image names, chart keys or support versions before entitlement and release documentation are available.