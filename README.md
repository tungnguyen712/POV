# 📍 POV (Landmark Lens)

Landmark Lens is a mobile application that uses Google Gemini 3 to identify landmarks from photos and provide personalized, interactive travel insights. Users can scan real-world locations and instantly learn about history, culture, and fun facts through AI-powered analysis.


## 🚀 Features

### 📷 Photo-Based Landmark Recognition
- Identify landmarks using images from camera or gallery
- Real-time image processing with Gemini Multimodal AI

### 🧠 AI-Powered Analysis (Gemini 3)
- Multimodal understanding (image + context)
- Structured JSON responses
- Confidence scoring and uncertainty handling
- Smart caching system for faster responses

### 🎯 Personalized Experience
- Personalized fun facts and descriptions based on user age and interests

### 💬 Interactive AI Chatbot
- Ask follow-up questions about landmarks
- Natural conversation powered by Gemini

### 🗺️ Location-Based Insights
- Nearby restaurant recommendations near landmarks
- Live events nearby (Ticketmaster API)
- Interactive Google Maps integration for exploration history

### 📊 Journey Tracking & Analytics
- "Wrapped" yearly summary feature
- View past scans and exploration history

### 👤 User Profiles & Authentication
- Secure authentication via Supabase
- Save interests and preferences

### 📱 Cross-Platform Mobile App
- Built with Flutter (Android / iOS / Desktop supported)

### 🗣️ Accessibility Features
- Text-to-speech (TTS) for landmark descriptions

## 🛠️ Tech Stack

**Frontend**
- Flutter (cross-platform mobile)
- Google Maps integration
- Text-to-Speech accessibility
- Supabase Auth

**Backend**
- FastAPI (Python)
- Google Gemini 3 multimodal API
- Supabase (Database + Storage)
- Google Places API
- Ticketmaster Events API
- Redis caching

**Key API Integrations**
- Google Gemini 3 for AI-powered landmark analysis
- Google Places for nearby recommendations
- Ticketmaster for live events
- OpenStreetMap for geocoding

## 📂 Project Structure

```
📂 Landmark-Lens/
├── 📂 backend/
│   ├── 📂 db/
│   ├── 📂 routes/
│   ├── 📂 schemas/
│   ├── 📂 services/
│   └── 📄 main.py
├── 📂 frontend/
│   ├── 📂 assets/
│   ├── 📂 lib/
│   │   ├── 📂 constants/
│   │   ├── 📂 screens/
│   │   ├── 📂 services/
│   │   └── 📄 main.dart
│   └── 📄 pubspec.yaml
└── 📄 requirements.txt
└── 📄 README.md
```

## ⚙️ Setup and Installation

### 1. Clone the repository:

```bash
git clone <repository-url>
cd Landmark-Lens
```

### 2. Backend Setup

**Install Dependencies**

```bash
pip install -r requirements.txt
```

**Set Environment Variables**

Create a `.env` file:

```env
GEMINI_API_KEY=your_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
SUPABASE_SECRET_KEY=your_supabase_secret_key
GOOGLE_PLACES_API_KEY=your_google_places_api_key
TICKETMASTER_API_KEY=your_ticketmaster_api_key
```

**Run Backend Server**

```bash
cd backend
python main.py
```

Backend runs at: [http://localhost:8000](http://localhost:8000)

### 3. Frontend Setup

**Install Flutter Packages**

```bash
cd frontend
flutter pub get
```

**Run App**

```bash
.\run.ps1
```

## 🧩 Gemini Integration

We use Gemini 3 for:
- Multimodal image understanding
- Landmark identification
- Context-aware reasoning
- Personalized explanations
- Schema-based JSON generation

## 📖 Usage Guide

1. Open the app
2. Tap the camera or gallery button
3. Select an image
4. View landmark details
6. Explore history and fun facts
7. Check wrapped journey history

## 🎥 Demo

> 🔧 TODO: Add demo video link (YouTube/Vimeo)

Example: `https://youtu.be/your-demo-video`
