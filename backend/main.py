import os
import re
import joblib
import pandas as pd
from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from huggingface_hub import HfApi
from dotenv import load_dotenv
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier

# Load environment variables
load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
REPO_ID = "venu17/smart-expense-ai" 
HF_TOKEN = os.getenv("HF_TOKEN")
MODEL_PATH = "models/smart_model.pkl"
VEC_PATH = "models/vectorizer.pkl"
DATA_PATH = "data.csv"

api = HfApi()

class TrainingData(BaseModel):
    sentence: str
    category: str

def retrain_and_upload(new_sentence, new_category):
    if not HF_TOKEN:
        print("Error: HF_TOKEN is not set.")
        return

    # Update local CSV dataset
    df = pd.read_csv(DATA_PATH)
    new_row = pd.DataFrame([[new_sentence, new_category]], columns=['sentence', 'category'])
    df = pd.concat([df, new_row], ignore_index=True)
    df.to_csv(DATA_PATH, index=False)

    # Retrain the model
    vec = TfidfVectorizer(ngram_range=(1, 2))
    X = vec.fit_transform(df['sentence'].values.astype('U'))
    y = df['category']
    
    model = SGDClassifier(loss='modified_huber')
    model.fit(X, y)

    # Save the updated models
    joblib.dump(model, MODEL_PATH)
    joblib.dump(vec, VEC_PATH)

    # Sync back to Hugging Face Space for persistence
    try:
        for file_path in [DATA_PATH, MODEL_PATH, VEC_PATH]:
            api.upload_file(
                path_or_fileobj=file_path,
                path_in_repo=file_path,
                repo_id=REPO_ID,
                repo_type="space",
                token=HF_TOKEN
            )
        print("Sync Successful: Data and models updated on HF Space.")
    except Exception as e:
        print(f"Sync Failed: {str(e)}")

@app.post("/predict")
async def predict(data: dict):
    try:
        model = joblib.load(MODEL_PATH)
        vec = joblib.load(VEC_PATH)
        text = data.get('text', '').lower().strip()
        
        v = vec.transform([text])
        category = model.predict(v)[0]
        
        nums = re.findall(r'\d+', text)
        amount = int(nums[0]) if nums else 0
        
        return {"category": str(category), "amount": amount}
    except Exception as e:
        return {"category": "Other", "amount": 0, "error": str(e)}

@app.post("/learn")
async def learn(data: TrainingData, background_tasks: BackgroundTasks):
    # Trigger training in the background so the user doesn't have to wait
    background_tasks.add_task(retrain_and_upload, data.sentence, data.category)
    return {"status": "success", "message": "Training started"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)