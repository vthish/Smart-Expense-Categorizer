# 🚀 Smart Expense AI - Intelligent Expense Tracker

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Hugging Face](https://img.shields.io/badge/AI_Host-Hugging_Face-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)
![Firebase](https://img.shields.io/badge/Database-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)

**Smart Expense AI** is a next-generation personal finance tracker built with **Flutter** and powered by a custom **Machine Learning model** hosted on **Hugging Face**. Instead of manually filling out tedious forms, users can simply type what they spent (e.g., *"bus ticket 150.50"*), and the AI automatically extracts the exact decimal amount and predicts the correct category.

The app features a stunning **Glassmorphism UI**, Dark Theme, Poppins typography, and a self-learning backend that gets smarter with every transaction.

---

## ✨ Key Features

- **🧠 Natural Language Processing (NLP):** Just type your expense in plain text. The AI extracts the exact amount (including decimals/cents) and categorizes it instantly.
- **🔄 Continuous Self-Learning:** If the AI makes a mistake, correcting it trains the model in the background. The app gets smarter every day!
- **⚡ Personalized AI Cache:** Remembers your specific spending habits locally via Firestore for lightning-fast, personalized categorization.
- **🔐 Secure Google Authentication:** One-tap secure login via Firebase Auth.
- **📊 Advanced Analytics:** Interactive pie charts and detailed category breakdowns using `fl_chart`.
- **🎨 Premium UI/UX:** Dark mode, Glassmorphism design, custom Google Fonts (Poppins), and satisfying Haptic Feedback on user interactions.

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework:** Flutter (Dart)
- **Design:** Custom Glassmorphism UI, Dark Theme (`#020617`)
- **State Management & Database:** Firebase Cloud Firestore
- **Authentication:** Firebase Auth (Google Sign-In)
- **Typography & Feedback:** Google Fonts (Poppins) & Haptic Feedback

### Backend (AI Server)
- **Framework:** FastAPI (Python)
- **Hosting:** Hugging Face Spaces (`venu17/smart-expense-ai`)
- **Machine Learning:** Scikit-learn (`SGDClassifier`, `TfidfVectorizer`), Pandas, Joblib
- **Continuous Integration:** Automated dataset updating and model retraining via Hugging Face API.

---

## 🏗️ System Architecture

1. **User Input:** User types *"water bill 5677.89"*.
2. **Local Verification:** App checks Firestore for past identical entries to provide instant personalization and bypass unnecessary API calls.
3. **AI Prediction:** If it's a new pattern, the text is sent to the FastAPI server on Hugging Face.
4. **Data Extraction:** An advanced Regex pattern (`\d+[.,]?\d*`) safely captures the exact decimal amount, and the NLP model predicts the category (e.g., `Utilities`).
5. **Self-Learning Loop:** Upon confirmation, the expense is saved to Firestore, and a background task triggers the `/learn` endpoint to retrain the Hugging Face model dynamically.

---

## 🚀 Installation & Setup

### 1. Flutter Setup (Mobile App)
```bash
# Clone the repository
git clone [https://github.com/vthish/smart-expense-ai.git](https://github.com/vthish/smart-expense-ai.git)

# Navigate to the project directory
cd smart-expense-ai

# Install dependencies
flutter pub get

# Run the app
flutter run

## ⚙️ Backend Setup (Local Server)

You can run the FastAPI backend locally using either a **standard Python setup** or **Docker (recommended for consistency and scalability)**.

---

### 🅰️ Method 1: Python Environment Setup

Follow these steps to run the backend using Python and pip:

```bash
# Navigate to the backend directory
cd backend

# Create a virtual environment
python -m venv venv

# Activate the virtual environment

# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the FastAPI server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

📌 The backend will be available at:
http://localhost:8000

---

### 🐳 Method 2: Docker Setup (Recommended)

Using Docker ensures a consistent environment across different systems.

#### 🔹 Option 1: Build & Run Manually

```bash
# Build the Docker image
docker build -t smart-expense-ai-backend .

# Run the container
docker run -p 8000:8000 --env HF_TOKEN=your_token_here smart-expense-ai-backend
```

#### 🔹 Option 2: Using Docker Compose

```bash
# Start all services
docker-compose up --build
```

---

### 🔗 Connecting Your Flutter App

When running the backend locally, update your API base URL in:

```
lib/services/ai_service.dart
```

Use the appropriate endpoint:

* Android Emulator: http://10.0.2.2:8000
* iOS Simulator / Web: http://127.0.0.1:8000

---

### ✅ Notes

* Ensure your backend is running before launching the Flutter app.
* Replace `HF_TOKEN` with your Hugging Face API token if you're syncing models.
* For production, consider deploying via Docker on a cloud platform.
