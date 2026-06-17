import urllib.request
import urllib.error
import json
import os
import logging
import time
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.db.models import Commodity, CommodityPrice
from app.services.forecast import (
    _forecast_cache, _audit_cache, _insight_cache,
    generate_forecast, get_ai_insight, PARENT_CHILD_MAP
)

logger = logging.getLogger(__name__)

METADATA_FILE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "../dataset/system_metadata.json")
DATASET_FILE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "../dataset/commodity_history.json")

MONTH_NAMES_ID = {
    1: "Januari", 2: "Februari", 3: "Maret", 4: "April", 5: "Mei", 6: "Juni",
    7: "Juli", 8: "Agustus", 9: "September", 10: "Oktober", 11: "November", 12: "Desember"
}

def format_datetime_id(dt: datetime) -> str:
    day = dt.day
    month = MONTH_NAMES_ID.get(dt.month, "")
    year = dt.year
    hour = f"{dt.hour:02d}"
    minute = f"{dt.minute:02d}"
    return f"{day} {month} {year} pukul {hour}:{minute} WIB"

def get_system_metadata() -> dict:
    if os.path.exists(METADATA_FILE):
        try:
            with open(METADATA_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Gagal membaca metadata sistem: {e}")
    # Default fallback
    return {
        "last_updated_train": "-",
        "last_updated_fetch": "-"
    }

def save_system_metadata(train_time: str = None, fetch_time: str = None):
    data = get_system_metadata()
    if train_time:
        data["last_updated_train"] = train_time
    if fetch_time:
        data["last_updated_fetch"] = fetch_time
    try:
        os.makedirs(os.path.dirname(METADATA_FILE), exist_ok=True)
        with open(METADATA_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
    except Exception as e:
        logger.error(f"Gagal menyimpan metadata sistem: {e}")

def get_jakarta_time() -> datetime:
    try:
        import pytz
        jakarta_tz = pytz.timezone('Asia/Jakarta')
        return datetime.now(jakarta_tz)
    except Exception:
        try:
            from zoneinfo import ZoneInfo
            return datetime.now(ZoneInfo("Asia/Jakarta"))
        except Exception:
            return datetime.utcnow() + timedelta(hours=7)

def fetch_and_sync_data(db: Session) -> dict:
    """Mengambil dataset terbaru dari BI, menggabungkan ke file json, dan menyimpan ke database."""
    logger.info("Memulai pengambilan data terbaru dari BI...")
    
    dt_now = get_jakarta_time()
    
    # Range tanggal (14 hari terakhir)
    end_date_str = dt_now.strftime("%Y-%m-%d")
    start_date_str = (dt_now - timedelta(days=14)).strftime("%Y-%m-%d")
    timestamp = int(time.time() * 1000)
    
    url = f"https://www.bi.go.id/hargapangan/WebSite/TabelHarga/GetGridDataDaerah?price_type_id=1&comcat_id=&province_id=&regency_id=&market_id=&tipe_laporan=1&start_date={start_date_str}&end_date={end_date_str}&_={timestamp}"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=30) as response:
            res_body = response.read().decode("utf-8")
            res_data = json.loads(res_body)
            
        data_items = res_data.get("data", [])
        if not data_items:
            raise ValueError("Data yang diambil dari BI kosong.")
            
        # 1. Update file JSON (commodity_history.json)
        if os.path.exists(DATASET_FILE):
            with open(DATASET_FILE, "r", encoding="utf-8") as f:
                history = json.load(f)
                
            u_map = {item["name"]: item for item in data_items}
            for item in history.get("data", []):
                name = item["name"]
                if name in u_map:
                    for k, v in u_map[name].items():
                        if "/" in k:
                            item[k] = v
                            
            with open(DATASET_FILE, "w", encoding="utf-8") as f:
                json.dump(history, f, indent=4, ensure_ascii=False)
            logger.info("Berhasil melakukan merge data ke commodity_history.json")
        else:
            logger.warning(f"File {DATASET_FILE} tidak ditemukan untuk diupdate.")
            
        # 2. Update Database
        logger.info("Melakukan sinkronisasi data ke database...")
        for item in data_items:
            name = item.get("name")
            if not name:
                continue
            
            commodity = db.query(Commodity).filter(Commodity.name == name).first()
            if not commodity:
                commodity = Commodity(name=name, level=item.get("level", 2))
                db.add(commodity)
                db.commit()
                db.refresh(commodity)
                
            for k, v in item.items():
                if "/" in k:
                    try:
                        price_val = float(str(v).replace(",", ""))
                        date_val = datetime.strptime(k, "%d/%m/%Y").date()
                        
                        existing = db.query(CommodityPrice).filter(
                            CommodityPrice.commodity_id == commodity.id,
                            CommodityPrice.date == date_val
                        ).first()
                        
                        if existing:
                            existing.price = price_val
                        else:
                            db.add(CommodityPrice(
                                commodity_id=commodity.id,
                                date=date_val,
                                price=price_val
                            ))
                    except (ValueError, TypeError):
                        pass
        db.commit()
        logger.info("Sinkronisasi database berhasil diselesaikan.")
        
        # Simpan waktu fetch berhasil
        fetch_time_str = format_datetime_id(dt_now)
        save_system_metadata(fetch_time=fetch_time_str)
        return {"status": "success", "fetch_time": fetch_time_str}
        
    except Exception as e:
        logger.error(f"Gagal melakukan fetch dan sync data: {str(e)}")
        raise e

def retrain_and_precache(db: Session) -> dict:
    """Melakukan retraining model (membersihkan cache) dan langsung melakukan precaching wawasan ke NVIDIA NIM."""
    logger.info("Memulai proses retraining dan pre-caching...")
    
    # 1. Bersihkan semua cache
    _forecast_cache.clear()
    _audit_cache.clear()
    _insight_cache.clear()
    logger.info("Cache ramalan, audit model, dan AI Insight berhasil dibersihkan.")
    
    success_count = 0
    fail_count = 0
    
    # Kumpulkan semua subkategori yang disupport model
    targets = []
    
    # Daftarkan parent
    for p in PARENT_CHILD_MAP.keys():
        targets.append(p)
    # Daftarkan child
    for c in db.query(Commodity).filter(Commodity.level == 2).all():
        targets.append(c.name)
        
    # Urutkan unik
    targets = sorted(list(set(targets)))
    
    logger.info(f"Daftar target pre-cache ({len(targets)} item): {targets}")
    
    for subcategory in targets:
        try:
            # Panggil peramalan dengan refit=True untuk melatih ulang parameter model
            forecast_res = generate_forecast(db, subcategory, model_type="sarimax", steps=7, refit=True)
            
            # Panggil AI Insight (ini akan menembak NVIDIA NIM & menyimpan hasilnya di insight cache)
            get_ai_insight(
                subcategory=subcategory,
                trend=forecast_res["trend"],
                horizon=forecast_res["horizon"],
                current_price=forecast_res["last_historical_price"],
                predicted_price=forecast_res["predicted_price"],
                db=db
            )
            success_count += 1
            logger.info(f"Pre-cache AI Insight berhasil untuk '{subcategory}'")
        except Exception as e:
            fail_count += 1
            logger.error(f"Gagal melakukan pre-cache untuk '{subcategory}': {str(e)}")
            
    dt_now = get_jakarta_time()
    train_time_str = format_datetime_id(dt_now)
    save_system_metadata(train_time=train_time_str)
    
    logger.info(f"Retraining & pre-cache selesai. Sukses: {success_count}, Gagal: {fail_count}")
    return {
        "status": "success",
        "train_time": train_time_str,
        "processed": success_count,
        "failed": fail_count
    }

def trigger_full_sync_job(db: Session) -> dict:
    """Menjalankan alur lengkap: fetch data terbaru -> retraining -> pre-caching NVIDIA NIM."""
    logger.info("Menjalankan tugas full sync terjadwal...")
    fetch_res = {"status": "failed", "detail": "Not executed"}
    try:
        fetch_res = fetch_and_sync_data(db)
    except Exception as e:
        logger.warning(f"Gagal mengambil data dari BI saat sync: {e}. Tetap melanjutkan retraining model...")
        fetch_res = {"status": "failed", "error": str(e)}
        
    train_res = retrain_and_precache(db)
    return {
        "fetch": fetch_res,
        "train": train_res
    }
