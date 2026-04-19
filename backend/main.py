from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
import re
import os

app = FastAPI()

MODEL_DIR = "models"
MODEL_PATH = f"{MODEL_DIR}/smart_model.pkl"
VEC_PATH = f"{MODEL_DIR}/vectorizer.pkl"
DATA_PATH = "../assets/data.csv"

if not os.path.exists(MODEL_DIR):
    os.makedirs(MODEL_DIR)

def train_model():
    if not os.path.exists(DATA_PATH): return
    df = pd.read_csv(DATA_PATH)
    vec = TfidfVectorizer(ngram_range=(1, 2))
    X = vec.fit_transform(df['sentence'].values.astype('U'))
    y = df['category']
    model = SGDClassifier(loss='modified_huber')
    model.fit(X, y)
    joblib.dump(model, MODEL_PATH)
    joblib.dump(vec, VEC_PATH)
    print("AI Model retrained successfully.")

class InputData(BaseModel):
    text: str

@app.post("/predict")
async def predict(data: InputData):
    try:
        model = joblib.load(MODEL_PATH)
        vec = joblib.load(VEC_PATH)
        v = vec.transform([data.text.lower()])
        category = model.predict(v)[0]
        nums = re.findall(r'\d+', data.text)
        amount = float(nums[0]) if nums else 0.0
        return {"category": category, "amount": amount}
    except:
        return {"category": "Other", "amount": 0.0}

@app.post("/retrain")
async def retrain(background_tasks: BackgroundTasks):
    background_tasks.add_task(train_model)
    return {"message": "Retraining started"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)