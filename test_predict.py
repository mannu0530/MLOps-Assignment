import base64
import requests
import sys

# Read and encode image
with open('/Users/maheshb/Documents/MLOps_project/MLOps-Assignment/Kidney-Disease-Classification-Deep-Learning-Project/inputImage.jpg', 'rb') as f:
    image_data = base64.b64encode(f.read()).decode('utf-8')

# Send request - note: the decodeImage function expects raw base64, not data URI
url = 'http://localhost:8080/predict'
payload = {'image': image_data}

response = requests.post(url, json=payload)
print(f"Status Code: {response.status_code}")
print(f"Response: {response.text}")