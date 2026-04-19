import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
import joblib
import os

def train():
    # Load the auto-generated data.csv
    # Adjust path if data.csv is in Flutter's assets folder
    csv_path = "../assets/data.csv"
    
    if not os.path.exists(csv_path):
        print("Error: data.csv not found!")
        return

    df = pd.read_csv(csv_path)

    # Vectorize text (Supports Sinhala, Singlish, and English)
    vectorizer = TfidfVectorizer(ngram_range=(1, 2))
    X = vectorizer.fit_transform(df['sentence'].values.astype('U'))
    y = df['category']

    # Using SGDClassifier for fast and efficient learning
    model = SGDClassifier(loss='modified_huber')
    model.fit(X, y)

    # Save the model and vectorizer
    if not os.path.exists("models"):
        os.makedirs("models")
        
    joblib.dump(model, 'models/smart_model.pkl')
    joblib.dump(vectorizer, 'models/vectorizer.pkl')
    print("Model training complete. Files saved in backend/models/")

if __name__ == "__main__":
    train()