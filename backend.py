from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta
import os
import requests
import yfinance as yf

app = Flask(__name__)
CORS(app)

TD_API_KEY = os.getenv("TWELVE_DATA_API_KEY")
TD_BASE = "https://api.twelvedata.com"

QUOTE_CACHE = {}
CACHE_TTL_SECONDS = 15


def now_utc():
    return datetime.utcnow()


def is_cache_fresh(entry):
    if not entry:
        return False
    return now_utc() - entry["fetched_at"] < timedelta(seconds=CACHE_TTL_SECONDS)


def safe_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(value)
    except Exception:
        return default


def to_td_symbol(symbol: str) -> str:
    s = symbol.strip().upper()
    if s.endswith(".NS"):
        return s.replace(".NS", ":NSE")
    if ":" in s:
        return s

    indian = {
        "RELIANCE", "TCS", "INFY", "HDFCBANK", "ICICIBANK",
        "KOTAKBANK", "AXISBANK", "SBIN", "WIPRO", "HCLTECH"
    }
    return f"{s}:NSE" if s in indian else s


def to_yf_symbol(symbol: str) -> str:
    s = symbol.strip().upper()
    if s.endswith(":NSE"):
        return s.replace(":NSE", ".NS")
    if s.endswith(".NS"):
        return s
    if "." in s:
        return s

    indian = {
        "RELIANCE", "TCS", "INFY", "HDFCBANK", "ICICIBANK",
        "KOTAKBANK", "AXISBANK", "SBIN", "WIPRO", "HCLTECH"
    }
    return f"{s}.NS" if s in indian else s


def normalize_yf_symbol(symbol: str) -> str:
    return to_yf_symbol(symbol)


def normalize_quote(company, symbol, price, prev_close, high, low, source, stale=False):
    change = round(price - prev_close, 2) if prev_close else 0.0
    change_pct = round((change / prev_close) * 100, 2) if prev_close else 0.0
    return {
        "company": company,
        "symbol": symbol,
        "price": round(price, 2),
        "previousClose": round(prev_close, 2),
        "change": change,
        "changePercent": change_pct,
        "dayHigh": round(high, 2),
        "dayLow": round(low, 2),
        "timestamp": now_utc().isoformat() + "Z",
        "source": source,
        "stale": stale,
    }


def fetch_td_quote(symbol: str):
    if not TD_API_KEY:
        raise ValueError("TWELVE_DATA_API_KEY is not set")

    td_symbol = to_td_symbol(symbol)
    res = requests.get(
        f"{TD_BASE}/quote",
        params={"symbol": td_symbol, "apikey": TD_API_KEY},
        timeout=8,
    )
    data = res.json()

    if res.status_code != 200 or data.get("status") == "error":
        raise ValueError(data.get("message", "Twelve Data quote failed"))

    price = safe_float(data.get("close") or data.get("previous_close"))
    prev_close = safe_float(data.get("previous_close"), price)
    high = safe_float(data.get("high"), price)
    low = safe_float(data.get("low"), price)
    company = data.get("name") or symbol

    return normalize_quote(company, td_symbol, price, prev_close, high, low, "twelvedata")


def fetch_yf_quote(symbol: str):
    yf_symbol = to_yf_symbol(symbol)
    ticker = yf.Ticker(yf_symbol)

    info = {}
    try:
        info = ticker.info or {}
    except Exception:
        info = {}

    hist = ticker.history(period="2d", interval="1d", auto_adjust=False)

    if hist.empty:
        raise ValueError("yfinance returned empty history")

    latest = hist.iloc[-1]
    price = safe_float(latest["Close"])
    high = safe_float(latest["High"])
    low = safe_float(latest["Low"])
    prev_close = safe_float(hist.iloc[-2]["Close"]) if len(hist) >= 2 else safe_float(latest["Open"])

    company = info.get("longName") or info.get("shortName") or yf_symbol
    return normalize_quote(company, yf_symbol, price, prev_close, high, low, "yfinance")


def get_quote(symbol: str):
    cache_key = symbol.upper()
    cached = QUOTE_CACHE.get(cache_key)

    if is_cache_fresh(cached):
        return cached["data"]

    try:
        data = fetch_td_quote(symbol)
        QUOTE_CACHE[cache_key] = {"data": data, "fetched_at": now_utc()}
        return data
    except Exception as td_error:
        try:
            data = fetch_yf_quote(symbol)
            data["stale"] = False
            QUOTE_CACHE[cache_key] = {"data": data, "fetched_at": now_utc()}
            return data
        except Exception as yf_error:
            if cached:
                stale = dict(cached["data"])
                stale["stale"] = True
                stale["source"] = f'{stale["source"]}|cache'
                return stale
            raise ValueError(f"Twelve Data failed: {td_error}; yfinance failed: {yf_error}")


@app.get("/ping")
def ping():
    return jsonify({"status": "ok"})


@app.get("/api/stock/<symbol>")
def stock(symbol):
    try:
        return jsonify(get_quote(symbol))
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.get("/api/stocks")
def stocks():
    raw = request.args.get("symbols", "")
    symbols = [s.strip() for s in raw.split(",") if s.strip()]

    if not symbols:
        return jsonify({"error": "No symbols provided"}), 400

    data = []
    errors = []

    for symbol in symbols:
        try:
            data.append(get_quote(symbol))
        except Exception as e:
            errors.append({"symbol": symbol, "message": str(e)})

    return jsonify({"data": data, "errors": errors})


@app.get("/api/stock/<symbol>/history")
def stock_history(symbol):
    period = request.args.get("period", "1M")
    yf_symbol = to_yf_symbol(symbol)

    interval_map = {
        "1D": ("1d", "5m"),
        "1W": ("5d", "30m"),
        "1M": ("1mo", "1d"),
        "3M": ("3mo", "1d"),
        "6M": ("6mo", "1d"),
        "1Y": ("1y", "1d"),
        "5Y": ("5y", "1wk"),
        "ALL": ("max", "1mo"),
        "1d": ("1d", "5m"),
        "1w": ("5d", "30m"),
        "1mo": ("1mo", "1d"),
        "3mo": ("3mo", "1d"),
        "6mo": ("6mo", "1d"),
        "1y": ("1y", "1d"),
        "5y": ("5y", "1wk"),
        "all": ("max", "1mo"),
    }

    yf_period, yf_interval = interval_map.get(period, ("1mo", "1d"))

    try:
        hist = yf.Ticker(yf_symbol).history(
            period=yf_period,
            interval=yf_interval,
            auto_adjust=False
        )

        if hist.empty:
            return jsonify([])

        rows = []
        for ts, row in hist.iterrows():
            rows.append({
                "timestamp": ts.isoformat(),
                "open": safe_float(row.get("Open")),
                "high": safe_float(row.get("High")),
                "low": safe_float(row.get("Low")),
                "close": safe_float(row.get("Close")),
                "volume": safe_float(row.get("Volume")),
            })

        return jsonify(rows)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/stocks/bulk", methods=["POST"])
def bulk_stocks():
    try:
        body = request.get_json(silent=True) or {}
        symbols = body.get("symbols", [])

        if not symbols:
            return jsonify({"error": "No symbols provided"}), 400

        results = []

        for symbol in symbols:
            try:
                yf_symbol = normalize_yf_symbol(symbol)
                ticker = yf.Ticker(yf_symbol)

                info = {}
                try:
                    info = ticker.info or {}
                except Exception:
                    info = {}

                hist = ticker.history(period="2d", interval="1d", auto_adjust=False)

                if hist.empty:
                    continue

                latest = hist.iloc[-1]
                price = safe_float(latest.get("Close"))
                day_high = safe_float(latest.get("High"))
                day_low = safe_float(latest.get("Low"))

                previous_close = safe_float(latest.get("Open"))
                if len(hist) >= 2:
                    previous_close = safe_float(hist.iloc[-2].get("Close"), previous_close)

                change = price - previous_close
                change_percent = (change / previous_close * 100) if previous_close else 0.0

                company_name = (
                    info.get("longName")
                    or info.get("shortName")
                    or yf_symbol.replace(".NS", "")
                )

                results.append({
                    "company": company_name,
                    "symbol": yf_symbol,
                    "price": round(price, 2),
                    "previousClose": round(previous_close, 2),
                    "change": round(change, 2),
                    "changePercent": round(change_percent, 2),
                    "dayHigh": round(day_high, 2),
                    "dayLow": round(day_low, 2),
                })

            except Exception:
                continue

        return jsonify(results)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True, port=5001)