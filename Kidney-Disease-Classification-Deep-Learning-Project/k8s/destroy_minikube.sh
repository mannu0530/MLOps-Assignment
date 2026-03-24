#!/bin/bash

# Kidney Disease Classification - Minikube Cleanup Script

set -e

echo "========================================="
echo "Kidney Disease Classification - Cleanup"
echo "========================================="

# Step 1: Delete Kubernetes resources
echo "Step 1: Deleting Kubernetes resources..."
kubectl delete -f k8s/deployment.yaml --ignore-not-found
kubectl delete -f k8s/namespace.yaml --ignore-not-found

# Step 2: Delete Docker image from minikube
echo "Step 2: Deleting Docker image from minikube..."
minikube image rm kidney-disease-classifier:latest 2>/dev/null || true

echo "========================================="
echo "Cleanup completed successfully!"
echo "========================================="
echo ""
echo "To completely remove minikube:"
echo "  minikube delete"
echo ""
echo "To check remaining resources:"
echo "  kubectl get all --all-namespaces"