#!/usr/bin/env bash
set -euo pipefail
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/kube/service-account.json"
export KUBECONFIG="$PWD/kube/config"
readonly CERT_MANAGER_NAMESPACE="cert-manager"

install-cert-manager() {
  if ! kubectl get namespace "$CERT_MANAGER_NAMESPACE"; then
    kubectl create namespace "$CERT_MANAGER_NAMESPACE"
  fi

  kubectl apply -f ci-resources/k8s-specs/tiller-service-account.yml
  kubectl apply -f ci-resources/k8s-specs/restricted-psp.yaml
  helm init --service-account tiller --upgrade --wait
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm upgrade \
    --install \
    cert-manager \
    jetstack/cert-manager \
    --namespace "$CERT_MANAGER_NAMESPACE" \
    --version v1.0.4 \
    --set installCRDs=true \
    --wait
}

configure-certs() {
  local cert_config_file key_file
  if ! kubectl get secret -n "$CERT_MANAGER_NAMESPACE" clouddns-dns01-solver-svc-acct; then
    key_file=$(mktemp)
    trap "rm -f $key_file" RETURN
    echo "$DNS_SERVICE_ACCOUNT_JSON" >"$key_file"
    kubectl create secret -n "$CERT_MANAGER_NAMESPACE" generic clouddns-dns01-solver-svc-acct --from-file=key.json="$key_file"
  fi

  cert_config_file=$(mktemp)
  trap "rm -f $cert_config_file" RETURN
  cat <<EOF >>"$cert_config_file"
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt
  namespace: "$CERT_MANAGER_NAMESPACE"
spec:
  acme:
    email: eirini@cloudfoundry.org
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-private-key
    solvers:
      - dns01:
          cloudDNS:
            # The ID of the GCP project
            project: "$GCP_PROJECT_ID"
            # This is the secret used to access the service account
            serviceAccountSecretRef:
              name: clouddns-dns01-solver-svc-acct
              key: key.json

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: eirinidotcf-cert
  namespace: "$CERT_MANAGER_NAMESPACE"
spec:
  secretName: eirinidotcf-cert
  commonName: eirini.cf
  dnsNames:
  - eirini.cf
  issuerRef:
    name: letsencrypt
EOF

  kubectl apply -f "$cert_config_file"
}

get-cert-status() {
  kubectl get certificate eirinidotcf-cert -n "$CERT_MANAGER_NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}'
}

wait-for-certs() {
  echo "Waiting for cert generation..."
  for i in {1..60}; do
    if [[ "$(get-cert-status)" == "True" ]]; then
      echo "Certs are generated!"
      return
    fi
    echo "Certs not generated. Attempt #$i..."
    sleep 10
  done
}

main() {
  install-cert-manager
  configure-certs
  wait-for-certs
}

main
