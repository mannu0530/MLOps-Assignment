# LangGraph AI Agents - Production Deployment

This project deploys five LangGraph-powered AI agents as a FastAPI REST API, containerized with Docker and orchestrated with Kubernetes (Minikube).

---

## Table of Contents

- [Overview](#overview)
- [Agents](#agents)
- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment (Minikube)](#kubernetes-deployment-minikube)
- [API Testing](#api-testing)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)

---

## Overview

This project wraps five LangGraph agent patterns in a FastAPI application:

| Agent | Endpoint | Type | Description |
|-------|----------|------|-------------|
| **Agent Bot** | `/api/agent-bot/chat` | Stateless | Single-turn Gemini chatbot |
| **Memory Agent** | `/api/memory/chat` | Session-based | Multi-turn chat with conversation history |
| **ReAct Agent** | `/api/react/solve` | Stateless | Math queries using add/subtract/multiply tools |
| **Drafter Agent** | `/api/drafter/chat` | Session-based | Document writing via LLM tool calls |
| **RAG Agent** | `/api/rag/query` | Stateless | PDF Q&A using ChromaDB + embeddings |

---

## Prerequisites

- **Docker** - For containerizing the application
- **Minikube** - For local Kubernetes cluster
- **kubectl** - Kubernetes CLI
- **Python 3.12+** - For local development
- **OpenRouter API Key** - For LLM inference (uses OpenAI-compatible API)

---

## Local Development

### 1. Clone and Setup

```bash
cd Assignment_agenticAi
```

### 2. Create Environment Variables

Create a `.env` file in the `Assignment_agenticAi` directory:

```bash
# Using OpenRouter API (recommended - accepts Azure-format keys)
OPENAI_API_KEY="sk-or-v1-your-key-here"
OPENAI_API_BASE="https://openrouter.ai/api/v1"
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run Locally

```bash
uvicorn app:app --host 0.0.0.0 --port 8000
```

### 5. Test Local API

```bash
# Agent Bot
curl -X POST http://localhost:8000/api/agent-bot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'

# Memory Agent
curl -X POST http://localhost:8000/api/memory/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test123", "message": "My name is John"}'

# ReAct Agent
curl -X POST http://localhost:8000/api/react/solve \
  -H "Content-Type: application/json" \
  -d '{"message": "What is 25 + 17?"}'

# Drafter Agent
curl -X POST http://localhost:8000/api/drafter/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "draft1", "message": "Write a short email", "document_content": ""}'

# RAG Agent
curl -X POST http://localhost:8000/api/rag/query \
  -H "Content-Type: application/json" \
  -d '{"message": "What was the stock market performance in 2024?"}'
```

---

## Docker Deployment

### 1. Build the Docker Image

```bash
cd Assignment_agenticAi
eval $(minikube docker-env)
docker build -t assignment-agentic-ai:latest .
```

### 2. Run the Container

```bash
docker run -d -p 8000:8000 \
  --env-file .env \
  assignment-agentic-ai:latest
```

### 3. Test the Container

```bash
curl -X POST http://localhost:8000/api/agent-bot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'
```

---

## Kubernetes Deployment (Minikube)

### 1. Start Minikube

```bash
minikube start
```

### 2. Apply Kubernetes Manifests

```bash
cd Assignment_agenticAi/k8s

# Apply ConfigMap
kubectl apply -f configmap.yaml

# Apply Secret (update with your API key first)
kubectl apply -f secret.yaml

# Apply Deployment
kubectl apply -f deployment.yaml

# Apply Service
kubectl apply -f service.yaml
```

### 3. Verify Deployment

```bash
# Check pods
kubectl get pods -l app=assignment-agentic-ai

# Check service
kubectl get svc assignment-agentic-ai-service
```

### 4. Access the API

#### Option A: Port Forward (Recommended for testing)

```bash
kubectl port-forward svc/assignment-agentic-ai-service 8080:80 &
```

Then access at: `http://localhost:8080`

#### Option B: Minikube Service URL

```bash
minikube service assignment-agentic-ai-service --url
```

### 5. Redeploy After Changes

```bash
# Rebuild image
eval $(minikube docker-env)
docker build -t assignment-agentic-ai:latest .

# Update deployment
kubectl apply -f k8s/deployment.yaml

# Restart pods
kubectl rollout restart deployment/assignment-agentic-ai-deployment

# Watch status
kubectl rollout status deployment/assignment-agentic-ai-deployment
```

---

## API Testing

### Test All Agents

```bash
# Base URL
BASE_URL="http://localhost:8080"

# 1. Agent Bot (Stateless)
echo "=== Testing Agent Bot ==="
curl -s -X POST $BASE_URL/api/agent-bot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'

# 2. Memory Agent (Session-based)
echo -e "\n\n=== Testing Memory Agent ==="
curl -s -X POST $BASE_URL/api/memory/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test123", "message": "My name is John."}'

# 3. ReAct Agent (Stateless)
echo -e "\n\n=== Testing ReAct Agent ==="
curl -s -X POST $BASE_URL/api/react/solve \
  -H "Content-Type: application/json" \
  -d '{"message": "What is 25 + 17?"}'

# 4. Drafter Agent (Session-based)
echo -e "\n\n=== Testing Drafter Agent ==="
curl -s -X POST $BASE_URL/api/drafter/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "draft1", "message": "Write a short email about the meeting.", "document_content": ""}'

# 5. RAG Agent (Stateless)
echo -e "\n\n=== Testing RAG Agent ==="
curl -s -X POST $BASE_URL/api/rag/query \
  -H "Content-Type: application/json" \
  -d '{"message": "What is S&P 500?"}'
```

### Actual Test Results

#### 1. Agent Bot (Stateless)
**Request:**
```bash
curl -s -X POST http://localhost:8080/api/agent-bot/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello!"}'
```

**Response:**
```json
{"response":"Hello! How can I assist you today?","session_id":null}
```

---

#### 2. Memory Agent (Session-based)
**Request:**
```bash
curl -s -X POST http://localhost:8080/api/memory/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "test123", "message": "My name is John."}'
```

**Response:**
```json
{"response":"Nice to meet you, John! How can I assist you today?","session_id":"test123"}
```

---

#### 3. ReAct Agent (Stateless)
**Request:**
```bash
curl -s -X POST http://localhost:8080/api/react/solve \
  -H "Content-Type: application/json" \
  -d '{"message": "What is 25 + 17?"}'
```

**Response:**
```json
{"response":"25 + 17 equals 42.","session_id":null}
```

**Request:**
```bash
curl -s -X POST http://localhost:8080/api/react/solve \
  -H "Content-Type: application/json" \
  -d '{"message": "What is 10 * 5?"}'
```

**Response:**
```json
{"response":"10 multiplied by 5 is 50.","session_id":null}
```

---

#### 4. Drafter Agent (Session-based)
**Request:**
```bash
curl -s -X POST http://localhost:8080/api/drafter/chat \
  -H "Content-Type: application/json" \
  -d '{"session_id": "draft1", "message": "Write a short email about the meeting.", "document_content": ""}'
```

**Response:**
```json
{"response":"Document would be saved to meeting_reminder_email.txt","session_id":"draft1"}
```

---

#### 5. RAG Agent (Stateless)
**Request:**
```bash
curl -s -X POST http://localhost:8080/api/rag/query \
  -H "Content-Type: application/json" \
  -d '{"message": "What was the stock market performance in 2024?"}'
```

**Response:**
```json
{"response":"In 2024, the U.S. stock market experienced a remarkably strong performance, continuing the bullish trend from the previous year. Here are the key highlights:\n\n1. Overall Market Performance: The S&P 500 index achieved a total return of approximately 25%, with around a 23% increase in price terms. This marked the second consecutive year of over 20% returns for the S&P 500, something not seen since the late 1990s (Document 1).\n\n2. Nasdaq Composite: The tech-heavy Nasdaq Composite outperformed the broader market, soaring nearly 29% for the year (Document 1).\n\n3. Small-Cap Stocks: Conversely, smaller-cap stocks had a more modest performance...\n\n4. Dominance of Technology Stocks: The 2024 rally was significantly driven by large-cap technology stocks, especially a group referred to as the Magnificent 7...\n\n5. Sector Performance: The performance of the stock market was highly concentrated within the technology sector...\n\nOverall, 2024 was indeed marked as a banner year for stocks, predominantly thanks to the performance of technology stocks...","session_id":null}
```

**Request:**
```bash
curl -s -X POST http://localhost:8080/api/rag/query \
  -H "Content-Type: application/json" \
  -d '{"message": "What is S&P 500?"}'
```

**Response:**
```json
{"response":"The S&P 500, or Standard & Poor's 500, is a stock market index that measures the stock performance of 500 large companies listed on stock exchanges in the United States. It is considered one of the best representations of the U.S. stock market and is widely used by investors and analysts to evaluate market performance. The index includes companies from various sectors, including technology, healthcare, finance, and consumer goods, making it a diverse benchmark for U.S. equities. The S&P 500 is often used as a gauge for the overall health of the U.S. economy.","session_id":null}
```

---

## Project Structure

```
Assignment_agenticAi/
├── app.py                    # FastAPI application with all agent endpoints
├── Dockerfile                # Multi-stage Docker build
├── requirements.txt          # Python dependencies
├── .env                     # Environment variables (API keys)
├── Agents/                  # Original agent scripts
│   ├── Agent_Bot.py
│   ├── Memory_Agent.py
│   ├── ReAct.py
│   ├── Drafter.py
│   ├── RAG_Agent.py
│   └── Stock_Market_Performance_2024.pdf
├── k8s/                     # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
└── README.md               # This file
```

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | API key for LLM (OpenRouter or OpenAI) | Yes |
| `OPENAI_API_BASE` | Base URL for API endpoint | Yes (for OpenRouter) |

### Getting an OpenRouter API Key

1. Go to [OpenRouter.ai](https://openrouter.ai)
2. Create an account
3. Generate an API key
4. Add to `.env` or Kubernetes secret

---

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### API not responding
```bash
# Check service endpoints
kubectl get endpoints assignment-agentic-ai-service

# Check port forwarding
kubectl port-forward svc/assignment-agentic-ai-service 8080:80
```

### Rebuild after code changes
```bash
eval $(minikube docker-env)
docker build -t assignment-agentic-ai:latest .
kubectl rollout restart deployment/assignment-agentic-ai-deployment
```

---

## License

This project is for educational purposes as part of the FreeCodeCamp LangGraph Course.
