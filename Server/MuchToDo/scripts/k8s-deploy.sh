#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CLUSTER_NAME="${KIND_CLUSTER_NAME:-muchtodo-cluster}"
KUBE_CONTEXT="kind-${CLUSTER_NAME}"
API_HOST_PORT="${API_HOST_PORT:-8080}"

node_has_ingress_label() {
  kubectl get nodes -o jsonpath='{.items[0].metadata.labels.ingress-ready}' 2>/dev/null | grep -q true
}

cluster_has_api_port() {
  docker port "${CLUSTER_NAME}-control-plane" 2>/dev/null | grep -q ":${API_HOST_PORT}->"
}

create_kind_cluster() {
  if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
    if cluster_has_api_port && node_has_ingress_label; then
      echo "Kind cluster '$CLUSTER_NAME' is correctly configured."
      return
    fi
    echo "ERROR: Cluster '$CLUSTER_NAME' exists but is misconfigured."
    echo "  Run:  bash scripts/k8s-cleanup.sh"
    echo "  Then: bash scripts/k8s-deploy.sh"
    exit 1
  fi

  local kind_config
  kind_config="$(mktemp)"
  trap 'rm -f "$kind_config"' RETURN

  cat >"$kind_config" <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 30888
        hostPort: ${API_HOST_PORT}
        protocol: TCP
EOF

  kind create cluster --name "$CLUSTER_NAME" --config "$kind_config"
}

install_ingress_nginx() {
  if ! kubectl get namespace ingress-nginx &>/dev/null; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/kind/deploy.yaml
  fi

  echo "Waiting for ingress-nginx controller (up to 10 min)..."
  if ! kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=600s 2>/dev/null; then
    echo "WARNING: ingress-nginx controller not ready yet."
    echo "  Check: kubectl get pods -n ingress-nginx"
    echo "  Label node if needed: kubectl label node --all ingress-ready=true --overwrite"
  fi
}

if ! command -v kind &>/dev/null; then
  echo "ERROR: 'kind' not found in PATH. Use Git Bash where kind is installed, or add kind to PATH."
  exit 1
fi

echo "=== 1/8 Create Kind cluster ==="
create_kind_cluster
kubectl config use-context "$KUBE_CONTEXT"

echo "=== 2/8 Create namespace ==="
kubectl apply -f kubernetes/namespace.yaml

echo "=== 3/8 Install ingress-nginx ==="
install_ingress_nginx

echo "=== 4/8 Build and load backend image ==="
docker compose build backend
kind load docker-image muchtodo-backend:latest --name "$CLUSTER_NAME"

echo "=== 5/8 Deploy MongoDB ==="
kubectl apply -f kubernetes/mongodb/
kubectl wait --for=condition=available deployment/mongodb -n muchtodo --timeout=300s

echo "=== 6/8 Deploy backend ==="
kubectl apply -f kubernetes/backend/
kubectl wait --for=condition=available deployment/backend -n muchtodo --timeout=300s

echo "=== 7/8 Apply Ingress ==="
kubectl apply -f kubernetes/ingress.yaml

echo "=== 8/8 Status ==="
kubectl get pods,svc,ingress -n muchtodo
kubectl get pods -n ingress-nginx

echo ""
echo "=== Verify API ==="
sleep 5
if curl -sf "http://127.0.0.1:${API_HOST_PORT}/health"; then
  echo ""
  echo "SUCCESS: http://localhost:${API_HOST_PORT}/health"
else
  echo ""
  echo "Health check failed. Debug:"
  echo "  kubectl get pods -n muchtodo"
  echo "  kubectl logs -n muchtodo -l app=backend --tail=30"
  exit 1
fi
