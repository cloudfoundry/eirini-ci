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
  if kubectl -n cf get secret eirini-certs >/dev/null 2>&1; then
    echo "Secret eirini-certs already exists. Skipping cert generation..."
    exit 0
  fi

  local nats_password_b64 cert key secrets_file
  nats_password_b64="$(echo -n "$NATS_PASSWORD" | base64)"
  openssl req -x509 -newkey rsa:4096 -keyout test.key -out test.cert -nodes -subj '/CN=localhost' -addext "subjectAltName = DNS:eirini-opi.cf.svc.cluster.local" -days 365
  cert=$(base64 -w0 <test.cert)
  key=$(base64 -w0 <test.key)
  rm test.*

  secrets_file=$(mktemp)
  cat <<EOF >"$secrets_file"
apiVersion: v1
kind: Secret
metadata:
  name: eirini-certs
type: Opaque
data:
  tls.crt: "$cert"
  ca.crt: "$cert"
  tls.key: "$key"
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
