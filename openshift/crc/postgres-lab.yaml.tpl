# OPTIONAL CRC LAB DATABASE TEMPLATE.
# Render with envsubst only after POSTGRES_IMAGE and PostgreSQL major version
# have been checked against the selected Pega patch support matrix.
apiVersion: v1
kind: Service
metadata:
  name: pega-postgres
  namespace: mayabank-pega
  labels:
    app.kubernetes.io/name: pega-postgres
    app.kubernetes.io/part-of: mayabank-pega-solution-architecture
spec:
  selector:
    app.kubernetes.io/name: pega-postgres
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: pega-postgres
  namespace: mayabank-pega
  labels:
    app.kubernetes.io/name: pega-postgres
    app.kubernetes.io/part-of: mayabank-pega-solution-architecture
spec:
  serviceName: pega-postgres
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: pega-postgres
  template:
    metadata:
      labels:
        app.kubernetes.io/name: pega-postgres
        app.kubernetes.io/part-of: mayabank-pega-solution-architecture
        mayabank.io/environment: crc
    spec:
      automountServiceAccountToken: false
      containers:
        - name: postgres
          image: ${POSTGRES_IMAGE}
          imagePullPolicy: IfNotPresent
          ports:
            - name: postgres
              containerPort: 5432
          env:
            # Red Hat-style variables.
            - name: POSTGRESQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: database
            - name: POSTGRESQL_USER
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: username
            - name: POSTGRESQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: password
            # Docker/Postgres-style variables; images that do not use them ignore them.
            - name: POSTGRES_DB
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: database
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: username
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: pega-postgres-secret
                  key: password
          readinessProbe:
            tcpSocket:
              port: postgres
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 12
          livenessProbe:
            tcpSocket:
              port: postgres
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 6
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: "2"
              memory: 2Gi
          volumeMounts:
            # Choose an OpenShift-compatible image and confirm its data path.
            # This template uses the Red Hat PostgreSQL data path by default.
            - name: data
              mountPath: /var/lib/pgsql/data
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: ${POSTGRES_STORAGE}
