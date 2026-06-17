from fastapi import APIRouter, HTTPException, Query, Depends
from sqlalchemy.orm import Session
from sqlalchemy import extract, func
from app.db.database import get_db
from app.schemas.prediction import ForecastResponse
from app.services.forecast import generate_forecast, MODEL_CONFIG, get_in_sample_fit, get_ai_insight
from app.services.market_summary import get_consolidated_market_summary
from datetime import datetime, timedelta
from app.db import models
from app.core.config import settings

router = APIRouter()

@router.get("/commodities", tags=["Metadata"])
def list_commodities():
    """Mengembalikan daftar seluruh komoditas subkategori yang didukung."""
    return list(MODEL_CONFIG.keys())

@router.get("/predict", response_model=ForecastResponse, tags=["Forecasting"])
def get_prediction(
    subcategory: str = Query(..., description="Nama subkategori pangan strategis"),
    model_type: str = Query("sarimax", regex="^(sarima|sarimax)$", description="Jenis model: sarima (univariate) atau sarimax (eksogen kalender)"),
    steps: int = Query(7, ge=1, le=30, description="Jumlah hari ke depan yang ingin diprediksi"),
    db: Session = Depends(get_db)
):
    """
    Menghasilkan prediksi harga pangan untuk N hari ke depan menggunakan model SARIMA/SARIMAX Tuned.
    """
    try:
        result = generate_forecast(db, subcategory, model_type, steps)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan internal: {str(e)}")

@router.get("/historical", tags=["Data"])
def get_historical_data(
    subcategory: str = Query(..., description="Nama subkategori pangan strategis"),
    days: int = Query(30, ge=1, le=2500, description="Jumlah hari data historis"),
    year: int = Query(None, description="Tahun spesifik data historis (harian)"),
    start_year: int = Query(None, description="Tahun mulai untuk agregasi bulanan"),
    end_year: int = Query(None, description="Tahun akhir untuk agregasi bulanan"),
    monthly: bool = Query(False, description="Agregasi rata-rata per bulan"),
    db: Session = Depends(get_db)
):
    """
    Mengambil data harga historis dari database.
    """
    try:
        commodity = db.query(models.Commodity).filter(models.Commodity.name == subcategory).first()
        if not commodity:
            raise ValueError(f"Komoditas '{subcategory}' tidak ditemukan di database.")
        
        if monthly and start_year and end_year:
            records = db.query(
                extract('year', models.CommodityPrice.date).label('year'),
                extract('month', models.CommodityPrice.date).label('month'),
                func.avg(models.CommodityPrice.price).label('price')
            ).filter(
                models.CommodityPrice.commodity_id == commodity.id,
                extract('year', models.CommodityPrice.date) >= start_year,
                extract('year', models.CommodityPrice.date) <= end_year
            ).group_by(
                extract('year', models.CommodityPrice.date),
                extract('month', models.CommodityPrice.date)
            ).order_by('year', 'month').all()
            
            return [{"date": f"{int(r.year)}-{int(r.month):02d}", "price": float(r.price)} for r in records]
            
        elif year:
            records = db.query(models.CommodityPrice).filter(
                models.CommodityPrice.commodity_id == commodity.id,
                extract('year', models.CommodityPrice.date) == year
            ).order_by(models.CommodityPrice.date.asc()).all()
        else:
            # Get latest date
            latest_record = db.query(models.CommodityPrice).filter(
                models.CommodityPrice.commodity_id == commodity.id
            ).order_by(models.CommodityPrice.date.desc()).first()
            
            if not latest_record:
                return []
                
            start_date = latest_record.date - timedelta(days=days-1)
            
            records = db.query(models.CommodityPrice).filter(
                models.CommodityPrice.commodity_id == commodity.id,
                models.CommodityPrice.date >= start_date
            ).order_by(models.CommodityPrice.date.asc()).all()
        
        return [{"date": str(r.date), "price": r.price} for r in records]
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan internal: {str(e)}")

@router.get("/overview", tags=["Data"])
def get_market_overview(db: Session = Depends(get_db)):
    """
    Mengambil ringkasan pasar: harga terakhir dan perubahan 24 jam untuk semua komoditas.
    """
    try:
        commodities = db.query(models.Commodity).filter(models.Commodity.level == 2).all()
        result = []
        for c in commodities:
            # Get the two most recent prices
            recent_prices = db.query(models.CommodityPrice).filter(
                models.CommodityPrice.commodity_id == c.id
            ).order_by(models.CommodityPrice.date.desc()).limit(2).all()
            
            if not recent_prices:
                continue
                
            latest = recent_prices[0]
            previous = recent_prices[1] if len(recent_prices) > 1 else latest
            
            change_pct = 0
            if previous.price > 0:
                change_pct = ((latest.price - previous.price) / previous.price) * 100
                
            # Auto-categorize based on name for UI purposes
            name_lower = c.name.lower()
            if "beras" in name_lower or "kedelai" in name_lower or "jagung" in name_lower or "gandum" in name_lower:
                category = "Grains"
            elif "cabai" in name_lower or "bawang" in name_lower or "garam" in name_lower:
                category = "Spices"
            elif "daging" in name_lower or "ayam" in name_lower or "ikan" in name_lower or "telur" in name_lower:
                category = "Meat"
            elif "minyak" in name_lower or "gula" in name_lower:
                category = "Groceries"
            else:
                category = "Other"

            result.append({
                "name": c.name,
                "category": category,
                "latest_price": latest.price,
                "previous_price": previous.price,
                "change_percentage": round(change_pct, 2),
                "date": str(latest.date)
            })
            
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan internal: {str(e)}")

@router.get("/audit", tags=["Data"])
def get_model_audit(
    subcategory: str = Query(..., description="Nama subkategori komoditas"),
    days: int = Query(30, ge=1, le=2200, description="Jumlah hari data historis untuk audit"),
    db: Session = Depends(get_db)
):
    """Mengembalikan in-sample fitted values SARIMAX untuk audit akurasi historis."""
    try:
        data = get_in_sample_fit(db, subcategory, days)
        return data
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal menghitung audit model: {str(e)}")

@router.get("/insight", tags=["AI"])
def get_model_insight(
    subcategory: str = Query(..., description="Nama subkategori komoditas"),
    trend: float = Query(..., description="Persentase tren harga"),
    horizon: int = Query(..., description="Horizon peramalan (hari)"),
    current_price: float = Query(..., description="Harga historis terakhir"),
    predicted_price: float = Query(..., description="Harga prediksi terakhir"),
    db: Session = Depends(get_db)
):
    """
    Menghasilkan rekomendasi bisnis taktis untuk pelaku UMKM dan masyarakat
    menggunakan model NVIDIA NIM berdasarkan hasil prediksi sistem.
    """
    try:
        insight = get_ai_insight(
            subcategory=subcategory,
            trend=trend,
            horizon=horizon,
            current_price=current_price,
            predicted_price=predicted_price,
            db=db
        )
        
        # Ambil metadata tanggal fetch & training terbaru untuk ditampilkan di UI
        from app.services.sync_service import get_system_metadata
        metadata = get_system_metadata()
        if isinstance(insight, dict):
            insight["last_updated_train"] = metadata.get("last_updated_train", "-")
            insight["last_updated_fetch"] = metadata.get("last_updated_fetch", "-")
            
        return {"insight": insight}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengambil AI Insight: {str(e)}")

@router.get("/api/market-summary", tags=["Mobile"])
def get_market_summary(db: Session = Depends(get_db)):
    """Mengembalikan ringkasan pasar lengkap teragregasi untuk kebutuhan aplikasi mobile."""
    try:
        data = get_consolidated_market_summary(db)
        return data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal mengambil ringkasan pasar: {str(e)}")

@router.post("/api/trigger-sync", tags=["Admin/Sync"])
def trigger_sync(db: Session = Depends(get_db)):
    """Memicu proses sinkronisasi dataset terbaru dari BI dan melakukan retraining/pre-cache model secara manual."""
    try:
        from app.services.sync_service import trigger_full_sync_job
        res = trigger_full_sync_job(db)
        return {"status": "success", "detail": res}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal melakukan sinkronisasi: {str(e)}")


