# CRC overlay for the official Pegasystems `pega/pega` Helm chart.
# Render with envsubst. Secrets are NOT present in this template; deploy.sh creates
# a temporary chmod-600 values file for DB/admin/clustering credentials.
#
# This overlay intentionally replaces the tier array with one CRC-only tier.
# It is NOT a production sizing or HA configuration.
---
global:
  provider: "openshift"
  customerDeploymentId: "mayabank-pega-crc"
  deployment:
    name: "${PEGA_RELEASE}"
  actions:
    execute: "deploy"
  storageClassName: ""

  jdbc:
    url: "${PEGA_JDBC_URL}"
    driverClass: "${PEGA_JDBC_DRIVER_CLASS}"
    dbType: "${PEGA_DB_TYPE}"
    driverUri: "${PEGA_JDBC_DRIVER_URI}"
    username: ""
    password: ""
    external_secret_name: ""
    rulesSchema: "${PEGA_RULES_SCHEMA}"
    dataSchema: "${PEGA_DATA_SCHEMA}"
    customerDataSchema: ""

  docker:
    registry:
      url: ""
      username: ""
      password: ""
    imagePullSecretNames:
      - "${PEGA_IMAGE_PULL_SECRET}"
    pega:
      image: "${PEGA_WEB_IMAGE}"

  tier:
    - name: "crc"
      nodeType: "BackgroundProcessing,WebUser,Search"
      service:
        httpEnabled: true
        port: 80
        targetPort: 8080
        tls:
          enabled: false
          port: 443
          targetPort: 8443
          traefik:
            enabled: false
            insecureSkipVerify: false
      ingress:
        enabled: true
        domain: "${PEGA_ROUTE_HOST}"
        annotations:
          haproxy.router.openshift.io/timeout: 2m
        tls:
          enabled: false
      replicas: 1
      javaOpts: ""
      initialHeap: "${PEGA_WEB_HEAP}"
      maxHeap: "${PEGA_WEB_HEAP}"
      resources:
        requests:
          memory: "${PEGA_WEB_MEMORY}"
          cpu: "${PEGA_WEB_CPU_REQUEST}"
        limits:
          memory: "${PEGA_WEB_MEMORY}"
          cpu: "${PEGA_WEB_CPU_LIMIT}"
      hpa:
        enabled: false
      pdb:
        enabled: false
      volumeClaimTemplate:
        resources:
          requests:
            storage: 5Gi

cassandra:
  enabled: false

pegasearch:
  externalSearchService: false

installer:
  image: "${PEGA_INSTALLER_IMAGE}"
  adminPassword: ""

hazelcast:
  enabled: false
  clusteringServiceImage: "${PEGA_CLUSTERING_SERVICE_IMAGE}"
  clusteringServiceEnabled: true
  replicas: ${PEGA_CLUSTERING_REPLICAS}
  username: ""
  password: ""
  external_secret_name: ""

stream:
  enabled: ${PEGA_STREAM_ENABLED}
  bootstrapServer: "${PEGA_KAFKA_BOOTSTRAP}"
  securityProtocol: "${PEGA_KAFKA_SECURITY_PROTOCOL}"
  replicationFactor: "1"
  external_secret_name: ""
