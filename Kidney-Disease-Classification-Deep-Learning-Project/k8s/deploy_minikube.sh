#!/bin/bash

# Kidney Disease Classification - Minikube Deployment Script

set -e

echo "========================================="
echo "Kidney Disease Classification - Minikube Deployment"
echo "========================================="

# Step 1: Check if minikube is installed
echo "Step 1: Checking minikube installation..."
if ! command -v minikube &> /dev/null; then
    echo "Error: minikube is not installed. Please install minikube first."
    exit 1
fi

# Step 2: Check if kubectl is installed
echo "Step 2: Checking kubectl installation..."
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Step 3: Start minikube if not running
echo "Step 3: Starting minikube..."
if ! minikube status &> /dev/null; then
    minikube start --memory=4096 --cpus=2
fi

# Step 4: Enable ingress addon
echo "Step 4: Enabling ingress addon..."
minikube addons enable ingress

# Step 5: Create namespace
echo "Step 5: Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Step 6: Build Docker image
echo "Step 6: Building Docker image..."
docker build -t kidney-disease-classifier:latest .

# Step 7: Load image into minikube
echo "Step 7: Loading image into minikube..."
minikube image load kidney-disease-classifier:latest

# Step 8: Deploy to Kubernetes
echo "Step 8: Deploying to Kubernetes..."
kubectl apply -f k8s/deployment.yaml

# Step 9: Wait for deployment
echo "Step 9: Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kidney-disease-classifier -n mlops

# Step 10: Get service URL
echo "Step 10: Getting service URL..."
minikube service kidney-disease-classifier-service -n mlops --url

echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="
echo ""
echo "To check the deployment status:"
echo "  kubectl get pods -n mlops"
echo "  kubectl get services -n mlops"
echo "  kubectl get deployment -n mlops"
echo ""
echo "To access the application:"
echo "  minikube service kidney-disease-classifier-service -n mlops"
echo ""
echo "To view logs:"
echo "  kubectl logs -n mlops -l app=kidney-disease-classifier"
echo ""
echo "To delete the deployment:"
echo "  kubectl delete -f k8s/"