import pandas as pd
import numpy as np
import time
import logging
from datetime import timedelta
from statsmodels.tsa.statespace.sarimax import SARIMAX
from sqlalchemy.orm import Session
from app.db.models import Commodity, CommodityPrice

logger = logging.getLogger(__name__)

# Konfigurasi Parameter Hasil Fine-Tuning yang Stabil & Production-Ready (Dataset 2021-2026)
MODEL_CONFIG = {
    "Bawang Merah Ukuran Sedang": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Bawang Putih Ukuran Sedang": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Bawah I": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Bawah II": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Medium I": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Medium II": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Super I": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Beras Kualitas Super II": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Cabai Merah Besar": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Cabai Merah Keriting ": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Cabai Rawit Hijau": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Cabai Rawit Merah": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Daging Ayam Ras Segar": {"sarima": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 0, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Daging Sapi Kualitas 1": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Daging Sapi Kualitas 2": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Gula Pasir Kualitas Premium": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Gula Pasir Lokal": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Minyak Goreng Curah": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Minyak Goreng Kemasan Bermerk 1": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Minyak Goreng Kemasan Bermerk 2": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
    "Telur Ayam Ras Segar": {"sarima": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}, "sarimax": {"order": [1, 1, 1], "seasonal_order": [0, 0, 0, 7]}},
}

PARENT_CHILD_MAP = {
    "Beras": [
        "Beras Kualitas Bawah I",
        "Beras Kualitas Bawah II",
        "Beras Kualitas Medium I",
        "Beras Kualitas Medium II",
        "Beras Kualitas Super I",
        "Beras Kualitas Super II"
    ],
    "Daging Ayam": ["Daging Ayam Ras Segar"],
    "Daging Sapi": ["Daging Sapi Kualitas 1", "Daging Sapi Kualitas 2"],
    "Telur Ayam": ["Telur Ayam Ras Segar"],
    "Bawang Merah": ["Bawang Merah Ukuran Sedang"],
    "Bawang Putih": ["Bawang Putih Ukuran Sedang"],
    "Cabai Merah": ["Cabai Merah Besar", "Cabai Merah Keriting "],
    "Cabai Rawit": ["Cabai Rawit Hijau", "Cabai Rawit Merah"],
    "Minyak Goreng": [
        "Minyak Goreng Curah",
        "Minyak Goreng Kemasan Bermerk 1",
        "Minyak Goreng Kemasan Bermerk 2"
    ],
    "Gula Pasir": ["Gula Pasir Kualitas Premium", "Gula Pasir Lokal"]
}

class ForecastCache:
    def __init__(self, ttl_seconds=43200):  # Default TTL: 12 Jam
        self._cache = {}
        self.ttl = ttl_seconds

    def get(self, subcategory: str, model_type: str, steps: int):
        key = (subcategory, model_type, steps)
        if key in self._cache:
            timestamp, data = self._cache[key]
            if time.time() - timestamp < self.ttl:
                return data
        return None

    def set(self, subcategory: str, model_type: str, steps: int, data):
        key = (subcategory, model_type, steps)
        self._cache[key] = (time.time(), data)

    def clear(self):
        self._cache.clear()

_forecast_cache = ForecastCache()  # TTL 12 jam untuk ramalan masa depan
_audit_cache = ForecastCache(ttl_seconds=3600)  # TTL 1 jam untuk audit in-sample
_insight_cache = ForecastCache(ttl_seconds=3600)  # TTL 1 jam untuk AI Insight

def load_commodity_data_from_db(db: Session, subcategory: str) -> pd.Series:
    commodity = db.query(Commodity).filter(Commodity.name == subcategory).first()
    if not commodity:
        raise ValueError(f"Subkategori '{subcategory}' tidak ditemukan di database.")
        
    prices = db.query(CommodityPrice).filter(CommodityPrice.commodity_id == commodity.id).order_by(CommodityPrice.date).all()
    if not prices:
        raise ValueError(f"Tidak ada data historis untuk subkategori '{subcategory}'.")
        
    dates = [p.date for p in prices]
    vals = [p.price for p in prices]
    
    series = pd.Series(data=vals, index=pd.to_datetime(dates)).sort_index()
    # Atur frekuensi harian & imputasi interpolasi linear (independen)
    series = series.asfreq('D').interpolate(method='linear').ffill().bfill()
    return series

def get_in_sample_fit(db: Session, subcategory: str, days: int = 30) -> list:
    """
    Mengembalikan in-sample fitted values dari model SARIMAX untuk audit akurasi historis.
    
    Fitted values adalah nilai yang diperkirakan model untuk setiap titik data historis
    yang sudah ada (bukan prediksi masa depan). Ini merepresentasikan kemampuan model
    dalam menjelaskan pola harga masa lalu secara jujur.

    Args:
        db: Database session.
        subcategory: Nama subkategori komoditas.
        days: Jumlah hari terakhir yang dikembalikan (default 30).

    Returns:
        List of dicts: [{date, actual_price, fitted_price, residual_pct}]
    """
    # If it is a parent category, average the fits of its children
    if subcategory in PARENT_CHILD_MAP:
        children = PARENT_CHILD_MAP[subcategory]
        fits_by_date = {}
        for child in children:
            try:
                child_fit = get_in_sample_fit(db, child, days)
                for pt in child_fit:
                    d = pt["date"]
                    if d not in fits_by_date:
                        fits_by_date[d] = {"actual": [], "fitted": []}
                    fits_by_date[d]["actual"].append(pt["actual_price"])
                    fits_by_date[d]["fitted"].append(pt["fitted_price"])
            except Exception as e:
                logger.error(f"Gagal mengambil fit untuk anak {child}: {e}")
                
        if not fits_by_date:
            raise ValueError(f"Gagal melakukan audit untuk semua sub-komoditas dari '{subcategory}'.")
            
        result = []
        for d in sorted(fits_by_date.keys()):
            avg_actual = sum(fits_by_date[d]["actual"]) / len(fits_by_date[d]["actual"])
            avg_fitted = sum(fits_by_date[d]["fitted"]) / len(fits_by_date[d]["fitted"])
            residual_pct = round(((avg_actual - avg_fitted) / avg_actual) * 100, 4) if avg_actual > 0 else 0.0
            result.append({
                "date": d,
                "actual_price": round(avg_actual, 2),
                "fitted_price": round(avg_fitted, 2),
                "residual_pct": residual_pct
            })
        return result

    if subcategory not in MODEL_CONFIG:
        raise ValueError(f"Subkategori '{subcategory}' tidak didukung oleh model.")

    # Cek cache audit terlebih dahulu
    cached = _audit_cache.get(subcategory, "audit", days)
    if cached is not None:
        return cached

    series = load_commodity_data_from_db(db, subcategory)

    orders = MODEL_CONFIG[subcategory]["sarimax"]
    order = tuple(orders["order"])
    seasonal_order = tuple(orders["seasonal_order"])

    # Transformasi log
    series_log = np.log1p(series)

    # Exog kalender: is_weekend (sama seperti generate_forecast)
    exog = pd.Series(
        [1 if d.dayofweek >= 5 else 0 for d in series.index],
        index=series.index,
        name="is_weekend"
    )

    try:
        model = SARIMAX(
            series_log, exog=exog,
            order=order, seasonal_order=seasonal_order,
            enforce_stationarity=True, enforce_invertibility=True
        )
        results = model.fit(disp=False)
        fitted_log = results.fittedvalues
    except Exception:
        # Fallback ke ARIMA(1,1,0) jika model utama gagal konvergensi
        fallback = SARIMAX(series_log, order=(1, 1, 0), enforce_stationarity=True)
        results = fallback.fit(disp=False)
        fitted_log = results.fittedvalues

    # Balikkan log-transform
    fitted = np.expm1(fitted_log)

    # Slice N hari terakhir setelah fitting seluruh series (penting: fit tetap pada full data)
    slice_series = series.iloc[-days:]
    slice_fitted = fitted.reindex(slice_series.index)

    result = []
    for date in slice_series.index:
        actual = float(slice_series[date])
        fit_val = slice_fitted.get(date)
        if fit_val is None or np.isnan(fit_val):
            fit_val = actual  # Fallback ke actual jika fitted NaN (biasanya titik awal AR)
        fit_val = float(fit_val)
        residual_pct = round(((actual - fit_val) / actual) * 100, 4) if actual > 0 else 0.0
        result.append({
            "date": date.strftime("%Y-%m-%d"),
            "actual_price": round(actual, 2),
            "fitted_price": round(fit_val, 2),
            "residual_pct": residual_pct
        })

    # Simpan ke audit cache
    _audit_cache.set(subcategory, "audit", days, result)
    return result


def generate_forecast(db: Session, subcategory: str, model_type: str, steps: int):
    # If it is a parent category, average the forecasts of its children
    if subcategory in PARENT_CHILD_MAP:
        children = PARENT_CHILD_MAP[subcategory]
        forecasts_by_date = {}
        last_prices = []
        last_dates = []
        
        for child in children:
            try:
                # Call generate_forecast recursively for child
                fc = generate_forecast(db, child, model_type, steps)
                last_prices.append(fc["last_historical_price"])
                last_dates.append(fc["last_historical_date"])
                for pred in fc["predictions"]:
                    d_str = pred["date"]
                    if d_str not in forecasts_by_date:
                        forecasts_by_date[d_str] = []
                    forecasts_by_date[d_str].append(pred["predicted_price"])
            except Exception as e:
                logger.error(f"Gagal melakukan forecast untuk {child}: {str(e)}")
                
        if not forecasts_by_date:
            raise ValueError(f"Gagal melakukan peramalan untuk semua sub-komoditas dari '{subcategory}'.")
            
        parent_predictions = []
        sorted_dates = sorted(forecasts_by_date.keys())
        from datetime import datetime
        for d_str in sorted_dates:
            avg_price = sum(forecasts_by_date[d_str]) / len(forecasts_by_date[d_str])
            # Parse day name from date string
            d_obj = datetime.strptime(d_str, "%Y-%m-%d")
            parent_predictions.append({
                "date": d_str,
                "day_name": d_obj.strftime("%A"),
                "predicted_price": round(avg_price, 2)
            })
            
        last_price = sum(last_prices) / len(last_prices) if last_prices else 0.0
        last_date_str = max(last_dates) if last_dates else datetime.now().strftime("%Y-%m-%d")
        
        last_pred_price = parent_predictions[-1]["predicted_price"] if parent_predictions else last_price
        trend = round(((last_pred_price - last_price) / last_price) * 100, 2) if last_price > 0 else 0.0
        
        return {
            "subcategory": subcategory,
            "model_used": "AGGREGATE_" + model_type.upper(),
            "last_historical_price": round(last_price, 2),
            "last_historical_date": last_date_str,
            "predictions": parent_predictions,
            "trend": trend,
            "horizon": steps,
            "predicted_price": last_pred_price
        }

    if subcategory not in MODEL_CONFIG:
        raise ValueError(f"Subkategori '{subcategory}' tidak didukung oleh model.")

    # Cek cache terlebih dahulu
    cached_result = _forecast_cache.get(subcategory, model_type, steps)
    if cached_result is not None:
        return cached_result

    series = load_commodity_data_from_db(db, subcategory)
    last_date = series.index[-1]
    last_price = float(series.iloc[-1])
    
    # Transformasi log
    series_log = np.log1p(series)
    
    # Ambil hyperparameter optimal hasil tuning
    orders = MODEL_CONFIG[subcategory][model_type]
    order = tuple(orders["order"])
    seasonal_order = tuple(orders["seasonal_order"])
    
    # Generate Tanggal Masa Depan
    future_dates = [last_date + timedelta(days=i) for i in range(1, steps + 1)]
    
    # Fitting dan Peramalan
    try:
        if model_type == "sarimax":
            # Siapkan exog kalender training ('is_weekend')
            exog_train = pd.Series(
                [1 if d.dayofweek >= 5 else 0 for d in series.index],
                index=series.index,
                name="is_weekend"
            )
            
            # Fitting SARIMAX
            model = SARIMAX(series_log, exog=exog_train, order=order, seasonal_order=seasonal_order,
                            enforce_stationarity=True, enforce_invertibility=True)
            results = model.fit(disp=False)
            
            # Siapkan exog kalender untuk masa depan (forecast horizon)
            exog_forecast = pd.Series(
                [1 if d.dayofweek >= 5 else 0 for d in future_dates],
                index=future_dates,
                name="is_weekend"
            )
            
            # Forecast
            forecast_log = results.forecast(steps=steps, exog=exog_forecast)
            
        else:
            # Fitting SARIMA Murni
            model = SARIMAX(series_log, order=order, seasonal_order=seasonal_order,
                            enforce_stationarity=True, enforce_invertibility=True)
            results = model.fit(disp=False)
            
            # Forecast
            forecast_log = results.forecast(steps=steps)
            
        # Balikkan log-transform (np.expm1) & rounding
        predictions = []
        for d, log_p in zip(future_dates, forecast_log):
            price = round(float(np.expm1(log_p)), 2)
            predictions.append({
                "date": d.strftime("%Y-%m-%d"),
                "day_name": d.strftime("%A"),
                "predicted_price": price
            })
            
        last_pred_price = predictions[-1]["predicted_price"] if predictions else last_price
        trend = round(((last_pred_price - last_price) / last_price) * 100, 2) if last_price > 0 else 0.0

        result = {
            "subcategory": subcategory,
            "model_used": model_type.upper(),
            "last_historical_price": last_price,
            "last_historical_date": last_date.strftime("%Y-%m-%d"),
            "predictions": predictions,
            "trend": trend,
            "horizon": steps,
            "predicted_price": last_pred_price
        }
        _forecast_cache.set(subcategory, model_type, steps, result)
        return result
        
    except Exception as e:
        # Fallback jika terjadi kegagalan konvergensi matematis (Production Graceful Fail)
        # Kami lakukan fallback ke model autoregressive sederhana (AR 1)
        try:
            fallback_model = SARIMAX(series_log, order=(1, 1, 0), enforce_stationarity=True)
            fallback_results = fallback_model.fit(disp=False)
            forecast_log = fallback_results.forecast(steps=steps)
            
            predictions = []
            for d, log_p in zip(future_dates, forecast_log):
                price = round(float(np.expm1(log_p)), 2)
                predictions.append({
                    "date": d.strftime("%Y-%m-%d"),
                    "day_name": d.strftime("%A"),
                    "predicted_price": price
                })
            
            last_pred_price = predictions[-1]["predicted_price"] if predictions else last_price
            trend = round(((last_pred_price - last_price) / last_price) * 100, 2) if last_price > 0 else 0.0

            result = {
                "subcategory": subcategory,
                "model_used": "FALLBACK_ARIMA(1,1,0)",
                "last_historical_price": last_price,
                "last_historical_date": last_date.strftime("%Y-%m-%d"),
                "predictions": predictions,
                "trend": trend,
                "horizon": steps,
                "predicted_price": last_pred_price
            }
            _forecast_cache.set(subcategory, model_type, steps, result)
            return result
        except Exception as fallback_err:
            raise ValueError(f"Gagal melakukan peramalan model utama maupun fallback. Error: {str(fallback_err)}")

def extract_text_from_response(data: dict) -> str:
    """Helper untuk mengambil konten teks jawaban dari response Google AI Studio."""
    candidates = data.get("candidates", [])
    if not candidates:
        raise ValueError("Tidak ada kandidat jawaban dari API.")
        
    parts = candidates[0].get("content", {}).get("parts", [])
    content_text = ""
    # Kumpulkan seluruh part teks yang bukan internal chain-of-thought (thinking)
    for p in parts:
        if not p.get("thought"):
            content_text += p.get("text", "")
            
    if not content_text and parts:
        # Fallback jika semua parts berupa thought atau field text di parts pertama langsung
        content_text = parts[0].get("text", "")
        
    if not content_text:
        raise ValueError("Gagal mengekstrak teks respons.")
    return content_text.strip()

def get_ai_insight(subcategory: str, trend: float, horizon: int, current_price: float, predicted_price: float, db: Session = None) -> dict:
    """
    Menghasilkan analisis bisnis taktis menggunakan Google Gemma 4 (31B) dengan caching.
    Menerapkan fallback ke model gemini-1.5-flash jika limit gemma terlampaui (RPD=2).
    Jika API key tidak valid atau terjadi error, kembalikan rule-based fallback secara anggun.
    """
    cache_key_str = f"{subcategory}_{trend}_{horizon}_{current_price}_{predicted_price}"
    steps_hash = abs(hash(cache_key_str)) % (10**8)
    cached = _insight_cache.get(subcategory, "insight", steps_hash)
    if cached is not None:
        return cached

    # Calculate historical change pct
    history_change_pct = 0.0
    if db is not None:
        try:
            # 1. Cari subcategory/commodity berdasarkan nama
            comm = db.query(Commodity).filter(Commodity.name == subcategory).first()
            if comm:
                # Ambil 2 harga terbaru
                recent_prices = db.query(CommodityPrice).filter(
                    CommodityPrice.commodity_id == comm.id
                ).order_by(CommodityPrice.date.desc()).limit(2).all()
                if len(recent_prices) >= 2:
                    latest_price = recent_prices[0].price
                    prev_price = recent_prices[1].price
                    if prev_price > 0:
                        history_change_pct = round(((latest_price - prev_price) / prev_price) * 100, 2)
            else:
                # 2. Coba cari jika ini adalah parent category
                if subcategory in PARENT_CHILD_MAP:
                    children_names = PARENT_CHILD_MAP[subcategory]
                    children = db.query(Commodity).filter(Commodity.name.in_(children_names)).all()
                    if children:
                        child_ids = [c.id for c in children]
                        from sqlalchemy import desc
                        latest_dates = db.query(CommodityPrice.date).filter(
                            CommodityPrice.commodity_id.in_(child_ids)
                        ).distinct().order_by(desc(CommodityPrice.date)).limit(2).all()
                        if len(latest_dates) >= 2:
                            d_latest = latest_dates[0][0]
                            d_prev = latest_dates[1][0]
                            
                            p_latest_list = db.query(CommodityPrice.price).filter(
                                CommodityPrice.commodity_id.in_(child_ids),
                                CommodityPrice.date == d_latest
                            ).all()
                            p_prev_list = db.query(CommodityPrice.price).filter(
                                CommodityPrice.commodity_id.in_(child_ids),
                                CommodityPrice.date == d_prev
                            ).all()
                            
                            if p_latest_list and p_prev_list:
                                avg_latest = sum(p[0] for p in p_latest_list) / len(p_latest_list)
                                avg_prev = sum(p[0] for p in p_prev_list) / len(p_prev_list)
                                if avg_prev > 0:
                                    history_change_pct = round(((avg_latest - avg_prev) / avg_prev) * 100, 2)
        except Exception as e:
            logger.warning(f"Gagal menghitung history_change_pct untuk {subcategory}: {e}")

    if abs(trend) < 0.1:
        trend_type = "kestabilan"
    else:
        trend_type = "kenaikan" if trend > 0 else "penurunan"
    trend_abs = abs(trend)
    
    # Check if API Key is placeholder or empty
    from app.core.config import settings
    if not settings.GEMMA_API_KEY or "your_gemma_api_key" in settings.GEMMA_API_KEY:
        # Fallback langsung ke rule-based jika key belum dikonfigurasi
        logger.info(f"API Key belum dikonfigurasi. Menggunakan fallback rule-based untuk {subcategory}.")
        from app.services.market_summary import generate_rule_based_insight
        fallback_res = generate_rule_based_insight(
            subcategory, 
            "naik" if trend >= 0.1 else ("turun" if trend <= -0.1 else "stabil"), 
            trend,
            history_change_pct
        )
        _insight_cache.set(subcategory, "insight", steps_hash, fallback_res)
        return fallback_res

    prompt = (
        "Anda adalah seorang pakar analis bisnis komoditas pangan yang cerdas, praktis, dan profesional.\n"
        "Tugas Anda adalah memberikan rekomendasi bisnis taktis yang singkat, solutif, dan langsung dapat dieksekusi "
        "dalam bentuk JSON terstruktur untuk dua sudut pandang (Masyarakat dan Pedagang):\n\n"
        f"- Komoditas: {subcategory}\n"
        f"- Harga Saat Ini: Rp {current_price:,.0f}/kg\n"
        f"- Harga Prediksi ({horizon} hari ke depan): Rp {predicted_price:,.0f}/kg\n"
        f"- Proyeksi Tren: {trend_type} sebesar {trend_abs:.1f}%\n\n"
        "Format respon wajib berupa raw JSON valid dengan struktur berikut tanpa markdown codeblock (no backticks):\n"
        "{\n"
        '  "masyarakat": "Rekomendasi singkat untuk pembeli/konsumen umum (max 40 kata)",\n'
        '  "pedagang": "Rekomendasi taktis untuk pelaku usaha/UMKM kuliner (max 40 kata)"\n'
        "}"
    )

    headers = {"Content-Type": "application/json"}
    body = {
        "contents": [{
            "parts": [{
                "text": prompt
            }]
        }]
    }

    import urllib.request
    import urllib.error
    import json

    # Skenario 1: Coba gemma-4-31b-it
    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemma-4-31b-it:generateContent?key={settings.GEMMA_API_KEY}"
        req = urllib.request.Request(
            url,
            data=json.dumps(body).encode("utf-8"),
            headers=headers,
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=20) as response:
            res_body = response.read().decode("utf-8")
            data = json.loads(res_body)
            result_text = extract_text_from_response(data)
            parsed_json = json.loads(result_text)
            parsed_json["disclaimer"] = "Analisis taktis bertenaga Google Gemma 4 (31B)."
            _insight_cache.set(subcategory, "insight", steps_hash, parsed_json)
            logger.info("AI Insight (JSON) berhasil dibuat menggunakan model gemma-4-31b-it.")
            return parsed_json
            
    except Exception as e:
        logger.warning(f"Percobaan gemma-4-31b-it gagal: {str(e)}. Melakukan fallback ke gemini-2.5-flash...")
        
        # Skenario 2: Fallback ke gemini-2.5-flash
        try:
            fallback_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={settings.GEMMA_API_KEY}"
            fallback_req = urllib.request.Request(
                fallback_url,
                data=json.dumps(body).encode("utf-8"),
                headers=headers,
                method="POST"
            )
            with urllib.request.urlopen(fallback_req, timeout=15) as response:
                res_body = response.read().decode("utf-8")
                data = json.loads(res_body)
                result_text = extract_text_from_response(data)
                parsed_json = json.loads(result_text)
                parsed_json["disclaimer"] = "Analisis taktis bertenaga Google Gemini 2.5 Flash."
                _insight_cache.set(subcategory, "insight", steps_hash, parsed_json)
                logger.info("AI Insight (JSON) berhasil dibuat menggunakan fallback model gemini-2.5-flash.")
                return parsed_json
        except Exception as fallback_err:
            logger.error(f"Gagal mengambil AI Insight dari Gemma maupun Gemini: {str(fallback_err)}. Mengaktifkan rule-based fallback.")
            # Fallback akhir yang 100% aman (Rule-based)
            from app.services.market_summary import generate_rule_based_insight
            fallback_res = generate_rule_based_insight(
                subcategory, 
                "naik" if trend >= 0.1 else ("turun" if trend <= -0.1 else "stabil"), 
                trend,
                history_change_pct
            )
            _insight_cache.set(subcategory, "insight", steps_hash, fallback_res)
            return fallback_res
