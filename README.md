# 📈 Sakhi-Sampatti

![Python](https://img.shields.io/badge/Python-3.8%2B-blue?style=for-the-badge&logo=python)
![Django](https://img.shields.io/badge/Django-4.0%2B-092E20?style=for-the-badge&logo=django)
![Flask](https://img.shields.io/badge/Flask-3.0%2B-000000?style=for-the-badge&logo=flask)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Welcome to **Sakhi-Sampatti**, a powerful and robust backend ecosystem built to provide real-time and historical stock market data. This project leverages the capabilities of **yfinance** and **TwelveData API** to deliver seamless, fast, and cached stock quotes, making it the perfect foundation for financial applications, investment trackers, and market analysis tools.

---

## 🌟 Key Features

- **🚀 Real-Time Stock Quotes**: Instantly fetch live market data for any Indian (NSE) or US stock.
- **📊 Historical Data API**: Retrieve rich historical stock metrics across various periods (1D, 1W, 1M, 1Y, ALL).
- **⚡ Built-in Caching**: Avoids rate-limits and accelerates response times using optimized caching layers.
- **🔄 Smart Fallbacks**: Gracefully switches between TwelveData and yfinance to ensure maximum uptime and data availability.
- **🌐 Dual-Backend Setup**:
  - A lightweight, ultra-fast **Flask** microservice for stock fetching (`backend.py`).
  - A full-fledged **Django** backend (`backend/`) equipped for user management, scalable databases, and enterprise-grade APIs.

---

## 🏗️ Project Structure

```bash
Sakhi-Sampatti/
├── backend.py            # The standalone Flask stock-fetching API
├── requirements.txt      # Master list of all project dependencies
├── backend/              # The Django robust backend project
│   ├── api/              # Django app for core models and views
│   ├── backend/          # Django project settings
│   ├── manage.py         # Django management script
│   └── db.sqlite3        # Local SQLite database
└── .gitignore            # Git exclusion settings
```

---

## 🛠️ Quick Start & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Divc18/Sakhi-Sampatti.git
cd Sakhi-Sampatti
```

### 2. Set Up a Virtual Environment
It's highly recommended to use an isolated Python environment.
```bash
# Windows
python -m venv venv
.\venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables
You'll need an API key from TwelveData if you want live fallback quotes. Create a `.env` file or export it directly:
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

## 📄 License
This project is open-source and licensed under the MIT License.
