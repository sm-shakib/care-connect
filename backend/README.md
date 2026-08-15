# Care Connect Backend (FastAPI)

Welcome to the Care Connect backend! This server is built using **FastAPI** (Python) and connects to a **PostgreSQL** database hosted on Neon. It handles authentication (JWT), user management, and profile storage for Elders, Caregivers, and Family Members.

---

## 🚀 Quick Start Guide

If you need to get the backend running locally to test the app, follow these steps:

### 1. Prerequisites
Ensure you have **Python 3.10+** installed on your machine. You can check by running:
```powershell
python --version
```

### 2. Initial Setup
Open your terminal in the `backend` folder and run the following commands:

**Create a Virtual Environment:**
```powershell
python -m venv venv
```

**Activate the Virtual Environment:**
- **Windows (PowerShell):** `.\venv\Scripts\activate`
- **Windows (CMD):** `venv\Scripts\activate`
- **Mac/Linux:** `source venv/bin/activate`

*(Once activated, you should see `(venv)` at the start of your command prompt line.)*

**Install Dependencies:**
```powershell
pip install -r requirements.txt
```

### 3. Environment Variables
You need a `.env` file to connect to the database and Cloudinary. 

1. Create your local `.env` file by running:
   - **Windows:** `copy .env.example .env`
   - **Mac/Linux:** `cp .env.example .env`

2. Open `.env` and fill in the following credentials:
   - `DATABASE_URL`: Your Neon PostgreSQL connection string.
   - `CLOUDINARY_CLOUD_NAME`: Found in Cloudinary Dashboard.
   - `CLOUDINARY_API_KEY`: Found in Cloudinary Dashboard.
   - `CLOUDINARY_API_SECRET`: Found in Cloudinary Dashboard.

---

## 🏃 How to Run the Server

To start the backend, run this command from the `backend` folder:

```powershell
uvicorn app.main:app --reload --host 0.0.0.0
```

### Why `--host 0.0.0.0`?
This is **critical** for mobile development. By default, the server only listens to your own computer (`127.0.0.1`). Using `--host 0.0.0.0` allows your physical phone or emulator to connect to your computer's IP address.

---

## 📱 Connecting the Frontend (Flutter)

To connect your Flutter app to this backend:

1. **Find your Local IP:** Open CMD and type `ipconfig`. Look for your IPv4 Address (e.g., `192.168.0.105`).
2. **Update Flutter Constants:** Open `frontend/lib/core/constants/api_constants.dart` and update the `baseUrl`:
   ```dart
   static const String baseUrl = 'http://192.168.0.105:8000'; // Use your IP here
   ```
3. **Emulator Shortcut:** If you are using the **Android Emulator**, you can use `http://10.0.2.2:8000` which automatically points to your computer's localhost.

---

## 📖 API Documentation (Swagger)

FastAPI automatically generates interactive documentation. Once the server is running, go to:
👉 **[http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)**

You can use this page to test endpoints (Signup, Login, etc.) directly from your browser without using the app.

---

## 📁 Project Structure

```text
backend/
├── app/
│   ├── api/          # API Routes (Endpoints for Login, Signup, etc.)
│   ├── core/         # Security, JWT, and Global Config
│   ├── db/           # Database Connection & Session Management
│   ├── models/       # SQLAlchemy Models (Database Table Definitions)
│   ├── schemas/      # Pydantic Schemas (Request/Response Data Validation)
│   └── main.py       # App Entry Point & Router Registration
├── .env              # Secrets (Database URL, JWT Key) - DO NOT COMMIT
├── requirements.txt  # Python Libraries
└── README.md         # This file!
```

---

## ⚠️ Common Issues

- **"ModuleNotFoundError":** Ensure your `venv` is activated and you ran `pip install -r requirements.txt`.
- **"Connection Refused" in Flutter:** 
  - Ensure the backend is running with `--host 0.0.0.0`.
  - Ensure your phone and computer are on the same Wi-Fi.
  - Check your Windows Firewall (it might be blocking port 8000).
- **Database Tables Not Found:** The app automatically creates tables on startup. If you add a new model, just restart the server.
