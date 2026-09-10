# Authorized Pega image acquisition flow

This repository does not automate vendor login because no Pega entitlement/credential is available here.

When a customer entitlement exists, the implementation must follow the official Pega distribution procedure for the selected release:

```text
Authorized operator/automation
 -> authenticate to Pega distribution endpoint
 -> pull exact vendor image/tag
 -> resolve and record sha256 digest
 -> push/mirror into quarantine repository
 -> scan / SBOM / policy
 -> promote exact digest into approved repository
 -> deploy only from approved internal registry
```

Never place the vendor credential in Git, CI logs or documentation examples.