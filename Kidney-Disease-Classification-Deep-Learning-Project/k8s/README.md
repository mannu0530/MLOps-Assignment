# Kubernetes Deployment for Kidney Disease Classification

This directory contains the Kubernetes manifests and deployment scripts for running the Kidney Disease Classification application on Minikube.

## Prerequisites

1. **Minikube** - Local Kubernetes cluster
2. **Docker** - Container runtime
3. **kubectl** - Kubernetes CLI

## Installation

### 1. Install Minikube

```bash
# On macOS with Homebrew
brew install minikube

# On Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### 2. Install kubectl

```bash
# On macOS with Homebrew
brew install kubectl

# On Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/
```

## Deployment

### Option 1: Using the deployment script

```bash
cd k8s
chmod +x deploy_minikube.sh
./deploy_minikube.sh
```

### Option 2: Manual deployment

```bash
# Start minikube
minikube start --memory=4096 --cpus=2

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Build and load Docker image
docker build -t kidney-disease-classifier:latest ..
minikube image load kidney-disease-classifier:latest

# Deploy
kubectl apply -f k8s/deployment.yaml

# Check status
kubectl get pods -n mlops
kubectl get services -n mlops

# Get service URL
minikube service kidney-disease-classifier-service -n mlops --url
```

## Service Configuration

The application is exposed via NodePort service on port 30080.

- **Service URL**: `http://<minikube-ip>:30080`
- **Health Check**: `http://<minikube-ip>:30080/`
- **Prediction Endpoint**: `POST http://<minikube-ip>:30080/predict`

## Resource Limits

The deployment is configured with:

- **Requests**:
  - Memory: 2Gi
  - CPU: 1000m
- **Limits**:
  - Memory: 4Gi
  - CPU: 2000m

Adjust these values based on your available resources.

## Troubleshooting

### Check pod logs
```bash
kubectl logs -n mlops -l app=kidney-disease-classifier
```

### Describe pod
```bash
kubectl describe pod -n mlops -l app=kidney-disease-classifier
```

### Restart deployment
```bash
kubectl rollout restart deployment/kidney-disease-classifier -n mlops
```

### Delete all resources
```bash
kubectl delete -f k8s/namespace.yaml
kubectl delete -f k8s/deployment.yaml
```

## Cleanup

```bash
minikube stop
minikube delete
```

## MLflow Configuration

The application is configured to use DagsHub for MLflow tracking:

- **Repository Owner**: mannu0530
- **Repository Name**: MLOps-Assignment
- **MLflow URI**: https://dagshub.com/mannu0530/MLOps-Assignment.mlflow

The MLflow integration uses `dagshub.init()` instead of environment variables, as specified in the project requirements.