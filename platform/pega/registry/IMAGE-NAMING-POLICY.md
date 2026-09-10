# Image naming and digest policy

## Deployment references

Controlled environments must prefer immutable digest references:

```text
<internal-registry>/<approved-repository>/<vendor-image>@sha256:<digest>
```

Human-friendly release tags may coexist in the registry, but a tag is not accepted as immutable evidence by itself.

## Forbidden production patterns

- `:latest`;
- unapproved public registry coordinates;
- locally rebuilt Pega vendor images presented as official images;
- environment-specific rebuilds of the same vendor release;
- registry credentials embedded in values files.

## Naming

Repository paths and tags should make vendor/product/release clear without exposing customer-sensitive information. Exact enterprise naming conventions are intentionally left configurable.