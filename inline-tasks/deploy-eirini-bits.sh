#!/bin/bash

set -eo pipefail
IFS=$'\n\t'

readonly ENVIRONMENT="cluster-state/environments/kube-clusters/$CLUSTER_NAME"

main() {
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
  export KUBECONFIG="$PWD/kube/config"

  helm init --upgrade --wait
  helm repo add bitnami https://charts.bitnami.com/bitnami

  helm-install
  install-nats
  install-wiremock
  create-test-secret
}

install-nats() {
  helm upgrade nats \
    --install bitnami/nats \
    --namespace cf \
    --set auth.user="nats" \
    --set auth.password="$NATS_PASSWORD"
}

install-wiremock() {
  kubectl apply -n cf -f - <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cc-wiremock
spec:
  selector:
    matchLabels:
      name: cc-wiremock
  template:
    metadata:
      labels:
        name: cc-wiremock
    spec:
      containers:
      - name: wiremock
        image: rodolpheche/wiremock
        ports:
        - containerPort: 8080
          name: http

---
apiVersion: v1
kind: Service
metadata:
  name: cc-wiremock
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
      name: http
  selector:
    name: cc-wiremock
EOF
}

create-test-secret() {
  local nats_password_b64 cert key secrets_file
  nats_password_b64="$(echo -n "$NATS_PASSWORD" | base64)"

  openssl req -nodes -new -x509 -keyout test.key -out test.cert -subj "/CN=eirini-opi.cf.svc.cluster.local"
  cert=$(base64 -w0 <test.cert)
  key=$(base64 -w0 <test.key)
  rm test.*

  secrets_file=$(mktemp)
  cat <<EOF >"$secrets_file"
apiVersion: v1
kind: Secret
metadata:
  name: cf-secrets
type: Opaque
data:
  cc-server-crt: "$cert"
  cc-server-crt-key: "$key"
  doppler-cert: "$cert"
  doppler-cert-key: "$key"
  eirini-client-crt: "$cert"
  eirini-client-crt-key: "$key"
  internal-ca-cert: "$cert"
  loggregator-agent-cert: "$cert"
  loggregator-agent-cert-key: "$key"
  nats-password: ""
EOF

  goml set -f "$secrets_file" -p data.nats-password -v "$nats_password_b64"
  kubectl apply -n cf -f "$secrets_file"
}

helm-install() {
  helm upgrade --install eirini \
    eirini-release/helm/eirini \
    --namespace cf \
    --values "$ENVIRONMENT"/values.yaml
}

main
