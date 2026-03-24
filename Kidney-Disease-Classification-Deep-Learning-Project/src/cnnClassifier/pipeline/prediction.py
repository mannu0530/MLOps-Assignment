import numpy as np
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
import os
from pathlib import Path



class PredictionPipeline:
    def __init__(self,filename):
        self.filename =filename


    
    def predict(self):
        # Check if model exists
        model_path = os.path.join("model", "model.h5")
        if not os.path.exists(model_path) or os.path.getsize(model_path) < 1000:
            # Model doesn't exist or is too small (placeholder)
            # Try to load from artifacts directory
            model_path = "artifacts/training/model.h5"
            if not os.path.exists(model_path) or os.path.getsize(model_path) < 1000:
                return [{"error": "Model not found. Please run training pipeline first.", "image": "unknown"}]
        
        # load model
        model = load_model(model_path)

        imagename = self.filename
        test_image = image.load_img(imagename, target_size = (224,224))
        test_image = image.img_to_array(test_image)
        test_image = np.expand_dims(test_image, axis = 0)
        result = np.argmax(model.predict(test_image), axis=1)
        print(result)

        if result[0] == 1:
            prediction = 'Tumor'
            return [{ "image" : prediction}]
        else:
            prediction = 'Normal'
            return [{ "image" : prediction}]