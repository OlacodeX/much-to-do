#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CLUSTER_NAME="${KIND_CLUSTER_NAME:-muchtodo-cluster}"

echo "Deleting MuchToDo Kubernetes resources..."
kubectl delete -f kubernetes/ingress.yaml --ignore-not-found --timeout=60s 2>/dev/null || true
kubectl delete -f kubernetes/backend/ --ignore-not-found --timeout=60s 2>/dev/null || true
kubectl delete -f kubernetes/mongodb/ --ignore-not-found --timeout=60s 2>/dev/null || true
kubectl delete namespace muchtodo --ignore-not-found --timeout=120s 2>/dev/null || true

echo "Deleting Kind cluster '$CLUSTER_NAME'..."
if command -v kind &>/dev/null; then
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
fi

echo "Cleanup done. Run:  bash scripts/k8s-deploy.sh"
