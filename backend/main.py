from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import re
import os

app = FastAPI()

# Global variables for model and vectorizer
model = None
vectorizer = None

# Load models on startup
@app.on_event("startup")
def load_models():
    global model, vectorizer
    try:
        model = joblib.load('models/smart_model.pkl')
        vectorizer = joblib.load('models/vectorizer.pkl')
        print("AI Models loaded successfully.")
    except Exception as e:
        print(f"Error loading models: {e}")

class PredictionRequest(BaseModel):
    text: str

@app.post("/predict")
async def predict(request: PredictionRequest):
    if model is None or vectorizer is None:
        raise HTTPException(status_code=500, detail="Model not loaded")

    # 1. NLP Prediction for Category
    input_vector = vectorizer.transform([request.text.lower()])
    category = model.predict(input_vector)[0]

    # 2. Regex for Amount Extraction
    amount_match = re.search(r'\d+', request.text)
    amount = float(amount_match.group(0)) if amount_match else 0.0

    return {
        "category": category,
        "amount": amount
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)