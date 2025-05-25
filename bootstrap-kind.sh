#!/usr/bin/env bash
set -e

CLUSTER=devnotes
INGRESS_MANIFEST=https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.1/deploy/static/provider/kind/deploy.yaml

echo "🔄 Deleting old kind cluster (if it exists)…"
kind delete cluster --name ${CLUSTER} || true

echo "🚀 Creating kind cluster with port mappings…"
kind create cluster --name ${CLUSTER} --config kind-config.yaml

echo "🏷️  Labeling control-plane node for ingress…"
kubectl label node ${CLUSTER}-control-plane ingress-ready=true --overwrite

echo "📦 Loading Docker images into kind…"
kind load docker-image devnotes-backend:latest --name ${CLUSTER}
kind load docker-image devnotes-frontend:latest --name ${CLUSTER}

echo "🌐 Installing nginx-ingress controller…"
kubectl apply -f ${INGRESS_MANIFEST}

echo "📂 Applying app manifests…"
kubectl apply -f k8s/persistent-volume.yaml
kubectl apply -f k8s/persistent-volume-claim.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

echo "✅ Bootstrap complete!  Browse to http://localhost:30080 and http://localhost:30080/notes"
