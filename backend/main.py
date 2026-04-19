from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
import re
import os

app = FastAPI()

# Enable CORS for all origins to avoid connectivity issues
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_DIR = "models"
MODEL_PATH = os.path.join(MODEL_DIR, "smart_model.pkl")
VEC_PATH = os.path.join(MODEL_DIR, "vectorizer.pkl")
DATA_PATH = "../assets/data.csv"

class InputData(BaseModel):
    text: str

@app.post("/predict")
async def predict(data: InputData):
    try:
        # Debugging: Log the incoming request
        print(f"Received request: {data.text}")
        
        model = joblib.load(MODEL_PATH)
        vec = joblib.load(VEC_PATH)
        clean_text = data.text.lower().strip()
        
        # Predict Category
        v = vec.transform([clean_text])
        category = model.predict(v)[0]
        
        # Extract Amount using regex
        nums = re.findall(r'\d+', clean_text)
        amount = int(nums[0]) if nums else 0
        
        print(f"Prediction: {category}, Amount: {amount}")
        
        return {
            "category": str(category),
            "amount": amount,
            "status": "success"
        }
    except Exception as e:
        print(f"Internal Error: {e}")
        return {"category": "Other", "amount": 0, "status": "error"}

if __name__ == "__main__":
    import uvicorn
    # Bind to 0.0.0.0 and your port 8000
    uvicorn.run(app, host="0.0.0.0", port=8000)