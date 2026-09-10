# Official Pega Helm integration

Use `pegasystems/pega-helm-charts` as the vendor deployment source-of-truth.

## Rules

- pin an explicit chart tag/commit compatible with the selected authorized Pega release;
- do not copy/fork the complete vendor chart into this repository without a specific governance reason;
- maintain only MayaBank overlays and validation logic here;
- map architecture overlays to exact vendor keys only after the chart revision is selected;
- run `helm lint` and `helm template` before deployment;
- capture the chart ref in the release manifest;
- treat successful rendering as static validation, not Pega runtime validation.

Official vendor documentation/support matrices override examples in this portfolio.