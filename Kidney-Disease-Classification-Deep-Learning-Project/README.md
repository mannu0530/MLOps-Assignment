# Kidney-Disease-Classification-MLflow-DVC

A deep learning project for classifying kidney CT scan images as Normal or Tumor using CNN (VGG16-based) architecture.

## Project Overview

- **Model**: VGG16-based CNN for binary classification (Normal/Tumor)
- **ML Framework**: TensorFlow 2.12+
- **MLOps Tools**: MLflow (experiment tracking), DVC (data versioning), Kubernetes (deployment)
- **Deployment**: Docker containerized Flask app deployed to Minikube

## Project Structure

```
Kidney-Disease-Classification-Deep-Learning-Project/
├── app.py                    # Flask web application
├── main.py                   # Training pipeline entry point
├── config/
│   └── config.yaml          # Configuration file
├── params.yaml              # Model hyperparameters
├── dvc.yaml                 # DVC pipeline definition
├── Dockerfile               # Docker image definition
├── requirements.txt         # Python dependencies
├── setup.py                 # Package setup
├── k8s/                     # Kubernetes deployment files
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
├── src/cnnClassifier/       # Source code
│   ├── components/         # ML components
│   ├── pipeline/           # ML pipelines
│   ├── config/             # Configuration management
│   ├── entity/             # Data entities
│   ├── utils/              # Utility functions
│   └── constants/          # Constants
├── artifacts/              # Model and data artifacts
├── model/                  # Model files
└── templates/              # HTML templates
```

## Workflows

1. Update config.yaml
2. Update params.yaml (hyperparameters)
3. Update the entity
4. Update the configuration manager in src config
5. Update the components
6. Update the pipeline
7. Update the main.py
8. Update the dvc.yaml
9. Run app.py for prediction

---

# How to Run?

## Option 1: Local Development

### STEP 01 - Create a conda environment

```bash
conda create -n cnncls python=3.8 -y
conda activate cnncls
```

### STEP 02 - Install the requirements

```bash
pip install -r requirements.txt
```

### STEP 03 - Run the Flask application

```bash
python app.py
```

The app will start on `http://localhost:8080`

---

## Option 2: Docker Container

### Build the Docker image

```bash
cd Kidney-Disease-Classification-Deep-Learning-Project
docker build -t kidney-disease-classifier .
```

### Run the container

```bash
docker run -p 8080:8080 kidney-disease-classifier
```

---

## Option 3: Minikube Deployment

### Prerequisites

- Docker installed
- Minikube installed
- kubectl installed

### STEP 01 - Start Minikube

```bash
minikube start --driver=docker
```

### STEP 02 - Build and load Docker image to Minikube

```bash
# Build the image
eval $(minikube docker-env)
docker build -t kidney-disease-classifier:latest .

# Or load existing image to minikube
minikube image load kidney-disease-classifier:latest
```

### STEP 03 - Apply Kubernetes manifests

```bash
cd k8s
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### STEP 04 - Verify deployment

```bash
kubectl get pods -n mlops
kubectl get svc -n mlops
```

### STEP 05 - Access the application

```bash
minikube service kidney-disease-classifier-service -n mlops
```

---

## Training the Model

### Local Training

```bash
python main.py
```

This will run the full pipeline:
1. Data Ingestion
2. Prepare Base Model
3. Model Training
4. Model Evaluation

### Training in Kubernetes

```bash
kubectl exec -n mlops <pod-name> -- python main.py
```

### Training Parameters

Edit `params.yaml` to modify training parameters:

```yaml
AUGMENTATION: True
IMAGE_SIZE: [224, 224, 3]
BATCH_SIZE: 16
INCLUDE_TOP: False
EPOCHS: 5
CLASSES: 2
WEIGHTS: imagenet
LEARNING_RATE: 0.01
```

---

## Making Predictions

### Using the Web Interface

1. Open the application in browser
2. Upload a kidney CT scan image
3. Click predict

### Using the API

```python
import requests
import base64

# Encode image
with open('image.jpg', 'rb') as f:
    img_data = base64.b64encode(f.read()).decode('utf-8')

# Make prediction
response = requests.post(
    'http://localhost:8080/predict',
    json={'image': img_data}
)
print(response.json())
```

---

## MLflow with DagsHub

### Using dagshub.init() (Recommended)

Instead of using environment variables, you can use dagshub.init() directly in your code:

```python
import dagshub
dagshub.init(repo_owner='your_username', repo_name='MLOps-Assignment', mlflow=True)

import mlflow
with mlflow.start_run():
    mlflow.log_param('parameter name', 'value')
    mlflow.log_metric('metric name', 1)
```

### Alternative: Using Environment Variables

If you prefer environment variables, add these to your shell:

```bash
export MLFLOW_TRACKING_URI=https://dagshub.com/your_username/your_repo.mlflow
export MLFLOW_TRACKING_USERNAME=your_username
export MLFLOW_TRACKING_PASSWORD=your_token
```

### Run MLflow UI

```bash
mlflow ui
```

Or access via DagsHub:

```
https://dagshub.com/your_username/your_repo/mlflow
```

---

## DVC Commands

```bash
# Initialize DVC
dvc init

# Reproduce pipeline
dvc repro

# Show pipeline DAG
dvc dag

# Pull data
dvc pull

# Push data
dvc push
```

---

## Testing the Model

### Test with Normal Image

```bash
# Copy a normal image to inputImage.jpg
cp artifacts/data_ingestion/kidney-ct-scan-image/Normal/Normal-\(637\).jpg inputImage.jpg

# Run prediction
python -c "
from cnnClassifier.pipeline.prediction import PredictionPipeline
classifier = PredictionPipeline('inputImage.jpg')
result = classifier.predict()
print(result)
"
```

### Test with Tumor Image

```bash
# Copy a tumor image to inputImage.jpg
cp artifacts/data_ingestion/kidney-ct-scan-image/Tumor/Tumor-\(701\).jpg inputImage.jpg

# Run prediction
python -c "
from cnnClassifier.pipeline.prediction import PredictionPipeline
classifier = PredictionPipeline('inputImage.jpg')
result = classifier.predict()
print(result)
"
```

---

## Project Classes

- **Normal**: Healthy kidney CT scan
- **Tumor**: Kidney with tumor

---

## About MLflow & DVC

### MLflow

- Production-grade experiment tracking
- Trace all your experiments
- Logging & tagging your model
- Model registry for version management

### DVC

- Lightweight experiment tracker
- Data versioning and pipeline orchestration
- Git-based workflow for ML projects

---

## Troubleshooting

### Pod keeps restarting

Check pod logs:
```bash
kubectl logs -n mlops <pod-name>
```

### Image not loading

Ensure the image is properly loaded in Minikube:
```bash
minikube image ls | grep kidney
```

### Out of memory

Increase memory in deployment or reduce batch size in params.yaml

---

## License

MIT License - See LICENSE file

---

## Credits

- Original repository: [Krish Naik](https://github.com/krishnaik06/Kidney-Disease-Classification-Deep-Learning-Project)
- Dataset: Kidney CT Scan Images
