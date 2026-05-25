# 📈 Sakhi-Sampatti

![Flutter](https://img.shields.io/badge/Flutter-Frontend-02569B?style=for-the-badge&logo=flutter)
![Python](https://img.shields.io/badge/Python-3.8%2B-blue?style=for-the-badge&logo=python)
![Django](https://img.shields.io/badge/Django-4.0%2B-092E20?style=for-the-badge&logo=django)
![Flask](https://img.shields.io/badge/Flask-3.0%2B-000000?style=for-the-badge&logo=flask)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Welcome to **Sakhi-Sampatti**, a full-stack stock market tracking and analysis application. This project features a beautiful cross-platform frontend built with **Flutter**, powered by a dual-backend architecture using **Django** and **Flask** to deliver seamless, real-time stock quotes via **yfinance** and **TwelveData API**.

---

## 🌟 Key Features

- **📱 Cross-Platform UI**: A gorgeous frontend application built in Flutter (`my_app`) targeting mobile and web.
- **🚀 Real-Time Stock Quotes**: Instantly fetch live market data for any Indian (NSE) or US stock.
- **📊 Historical Data API**: Retrieve rich historical stock metrics across various periods (1D, 1W, 1M, 1Y, ALL).
- **⚡ Built-in Caching**: Avoids rate-limits and accelerates response times using optimized caching layers.
- **🌐 Dual-Backend Setup**:
  - A lightweight, ultra-fast **Flask** microservice for stock fetching (`backend.py`).
  - A full-fledged **Django** backend (`backend/`) equipped for user management, scalable databases, and enterprise-grade APIs.

---

## 🏗️ Project Structure

```bash
Sakhi-Sampatti/
├── my_app/               # The Flutter Frontend App (Mobile/Web UI)
│   ├── pubspec.yaml      # Flutter dependencies
│   └── lib/              # Frontend Dart source code
├── backend/              # The Django robust backend project
│   ├── api/              # Django app for core models and views
│   ├── backend/          # Django project settings
│   └── manage.py         # Django management script
├── backend.py            # The standalone Flask stock-fetching API
├── requirements.txt      # Master list of all Python dependencies
└── .gitignore            # Git exclusion settings
```

---

## 🛠️ Quick Start & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Divc18/Sakhi-Sampatti.git
cd Sakhi-Sampatti
```

### 2. Frontend Setup (Flutter)
Navigate to the `my_app` directory to set up the user interface. You will need the Flutter SDK installed.
```bash
cd my_app
flutter pub get
flutter run
```

### 3. Backend Setup (Python)
It's highly recommended to use an isolated Python environment for the backend servers.
```bash
# Return to the root folder
cd ..

# Create and activate a virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 4. Configure Environment Variables
You'll need an API key from TwelveData if you want live fallback quotes.
```bash
# Windows (PowerShell)
$env:TWELVE_DATA_API_KEY="your_api_key_here"

# macOS/Linux
export TWELVE_DATA_API_KEY="your_api_key_here"
```

---

## 🚀 Running the Servers

### Run the Flask Stock API
The Flask application fetches stock data quickly and caches it efficiently.
```bash
python backend.py
# Server runs on http://127.0.0.1:5001
```

### Run the Django Application
The Django server handles the core database-backed API endpoints.
```bash
cd backend
python manage.py makemigrations
python manage.py migrate
python manage.py runserver
# Server runs on http://127.0.0.1:8000
```

---

## 🔌 API Endpoints (Flask App)

- `GET /ping` - Server health check.
- `GET /api/stock/<symbol>` - Fetch real-time data for a specific stock (e.g., `RELIANCE` or `AAPL`).
- `GET /api/stocks?symbols=AAPL,MSFT` - Fetch multiple stock quotes at once.
- `GET /api/stock/<symbol>/history?period=1M` - Fetch historical pricing data.
- `POST /api/stocks/bulk` - Fetch rich details for a bulk list of symbols.

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Divc18/Sakhi-Sampatti/issues).

