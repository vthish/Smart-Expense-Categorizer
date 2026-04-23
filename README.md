# 🚀 Smart Expense AI - Intelligent Expense Tracker

![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Hugging Face](https://img.shields.io/badge/AI_Host-Hugging_Face-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)
![Firebase](https://img.shields.io/badge/Database-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)

**Smart Expense AI** is a next-generation personal finance tracker built with **Flutter** and powered by a custom **Machine Learning model** hosted on **Hugging Face**. Instead of manually filling out forms, users can simply type what they spent (e.g., *"bus ticket 150.50"*), and the AI automatically extracts the amount and predicts the correct category.

The app features a stunning **Glassmorphism UI**, Dark Theme, and a self-learning backend that gets smarter with every transaction.

---

## ✨ Key Features

- **🧠 Natural Language Processing (NLP):** Just type your expense in plain text. The AI extracts the exact decimal amount and categorizes it.
- **🔄 Continuous Self-Learning:** If the AI makes a mistake, correcting it trains the model in the background. The app gets smarter every day!
- **⚡ Personalized AI Cache:** Remembers your specific spending habits locally for lightning-fast, personalized categorization.
- **🔐 Secure Google Authentication:** One-tap login via Firebase Auth.
- **📊 Advanced Analytics:** Interactive pie charts and detailed category breakdowns using `fl_chart`.
- **🎨 Premium UI/UX:** Dark mode, Glassmorphism design, custom Poppins typography, and satisfying Haptic Feedback.

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework:** Flutter (Dart)
- **Design:** Custom Glassmorphism UI, Dark Theme (`#020617`)
- **State Management & Database:** Firebase Cloud Firestore
- **Authentication:** Firebase Auth (Google Sign-In)
- **Typography:** Google Fonts (Poppins)

### Backend (AI Server)
- **Framework:** FastAPI (Python)
- **Hosting:** Hugging Face Spaces (`venu17/smart-expense-ai`)
- **Machine Learning:** Scikit-learn (`SGDClassifier`, `TfidfVectorizer`), Pandas, Joblib
- **Continuous Integration:** Automated dataset updating and model retraining via Hugging Face API.

---

## 🏗️ System Architecture

1. **User Input:** User types *"water bill 5677.89"*.
2. **Local Verification:** App checks Firestore for past identical entries to provide instant personalization.
3. **AI Prediction:** If it's a new pattern, the text is sent to the FastAPI server on Hugging Face.
4. **Data Extraction:** Regex captures the exact decimal amount (`5677.89`), and the NLP model predicts the category (`Utilities`).
5. **Self-Learning Loop:** Upon confirmation, the expense is saved to Firestore, and a background task triggers the `/learn` endpoint to retrain the Hugging Face model with the new data.

---

## 🚀 Installation & Setup

### 1. Flutter Setup
```bash
# Clone the repository
git clone [https://github.com/your-username/smart-expense-ai.git](https://github.com/your-username/smart-expense-ai.git)

# Navigate to the project directory
cd smart-expense-ai

# Install dependencies
flutter pub get

# Run the app
flutter run