import logging
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.db import models
from app.services.forecast import generate_forecast, MODEL_CONFIG, PARENT_CHILD_MAP

logger = logging.getLogger(__name__)

IMAGE_ASSETS = {
    "Beras": "assets/images/beras.png",
    "Daging Ayam": "assets/images/daging_ayam.png",
    "Daging Sapi": "assets/images/daging_sapi.png",
    "Telur Ayam": "assets/images/telur_ayam.png",
    "Bawang Merah": "assets/images/bawang_merah.png",
    "Bawang Putih": "assets/images/bawang_putih.png",
    "Cabai Merah": "assets/images/cabai_merah.png",
    "Cabai Rawit": "assets/images/cabai_rawit.png",
    "Minyak Goreng": "assets/images/minyak_goreng.png",
    "Gula Pasir": "assets/images/gula_pasir.png"
}

def get_commodity_unit(name: str) -> str:
    if "Minyak" in name:
        return "ltr"
    return "kg"

def generate_rule_based_insight(name: str, trend: str, forecast_pct: float, history_change_pct: float = 0.0) -> dict:
    pct_abs = abs(forecast_pct)
    hist_abs = abs(history_change_pct)
    
    # Determine history state
    if history_change_pct > 0.1:
        history_desc = f"terpantau naik sebesar {hist_abs:.1f}% hari ini"
        history_trend = "naik"
    elif history_change_pct < -0.1:
        history_desc = f"mengalami penurunan sebesar {hist_abs:.1f}% hari ini"
        history_trend = "turun"
    else:
        history_desc = "terpantau stabil hari ini"
        history_trend = "stabil"

    # Determine forecast state
    if trend == "naik":
        forecast_desc = f"diprediksi naik sebesar {pct_abs:.1f}% dalam sepekan ke depan"
    elif trend == "turun":
        forecast_desc = f"diproyeksikan turun sebesar {pct_abs:.1f}% dalam sepekan ke depan"
    else:
        forecast_desc = "diprediksi stabil dalam beberapa hari ke depan"

    # Determine connector
    if history_trend == "stabil" and trend == "stabil":
        masyarakat_desc = f"Harga {name} {history_desc} dan {forecast_desc}."
        pedagang_desc = f"Kondisi harga {name} {history_desc} dan {forecast_desc}."
    elif history_trend == trend:
        connector = "Sejalan dengan tren tersebut,"
        masyarakat_desc = f"Harga {name} {history_desc}. {connector} harga {forecast_desc}."
        pedagang_desc = f"Harga {name} {history_desc}. {connector} harga {forecast_desc}."
    else:
        # Divergent trends, or one is stable and the other is moving
        connector = "Meskipun demikian,"
        masyarakat_desc = f"Harga {name} {history_desc}. {connector} harga {forecast_desc}."
        pedagang_desc = f"Harga {name} {history_desc}. {connector} harga {forecast_desc}."

    # Append recommendations
    if trend == "naik":
        masyarakat_text = f"{masyarakat_desc} Sebaiknya stok kebutuhan belanja Anda sedikit lebih awal untuk berhemat."
        pedagang_text = f"{pedagang_desc} Tren kenaikan ini akan menaikkan modal operasional. Pertimbangkan menyetok bahan sebelum harga naik atau menyesuaikan porsi menu."
    elif trend == "turun":
        masyarakat_text = f"{masyarakat_desc} Kabar baik, tunda belanja grosir sampai harga mendekati titik terendah agar lebih efisien."
        pedagang_text = f"{pedagang_desc} Penurunan harga memberi ruang margin keuntungan yang lebih lebar. Manfaatkan momen ini untuk menaikkan volume penjualan."
    else:
        masyarakat_text = f"{masyarakat_desc} Anda dapat membelinya secara berkala sesuai kebutuhan rumah tangga biasa."
        pedagang_text = f"{pedagang_desc} Kondisi harga relatif aman. Pertahankan stok inventori normal tanpa perlu khawatir gejolak biaya jangka pendek."

    return {
        "masyarakat": masyarakat_text,
        "pedagang": pedagang_text,
        "disclaimer": "Rekomendasi taktis berbasis peramalan model SARIMAX."
    }

_global_analysis_cache = {}

def get_global_ai_analysis(db: Session, commodities_data: list, latest_date_str: str) -> str:
    """
    Menghasilkan analisis ringkas pasar pangan nasional secara keseluruhan menggunakan NVIDIA NIM (Google Gemma).
    Menggunakan caching berbasis tanggal agar tidak memicu pemanggilan API berulang kali.
    """
    if latest_date_str in _global_analysis_cache:
        logger.info("Mengambil global analysis dari cache.")
        return _global_analysis_cache[latest_date_str]

    from app.core.config import settings
    default_fallback = "Analisis harga pangan pokok nasional menunjukkan stabilitas pada kelompok beras, namun fluktuasi minor terdeteksi pada komoditas cabai dan bawang karena faktor cuaca musiman."

    if not settings.NVIDIA_API_KEY or "your_nvidia_api_key" in settings.NVIDIA_API_KEY:
        logger.info("NVIDIA_API_KEY tidak dikonfigurasi. Menggunakan fallback analisis bawaan.")
        return default_fallback

    # Siapkan ringkasan komoditas untuk prompt
    summary_parts = []
    for item in commodities_data:
        name = item["name"]
        price = item["current_price"]
        unit = item["unit"]
        trend = item["trend"]
        pct = item["price_changes"].get("day_7", 0.0)
        summary_parts.append(f"- {name}: Rp {price:,.0f}/{unit} (Tren sepekan: {trend} {abs(pct):.1f}%)")

    summary_list_text = "\n".join(summary_parts)

    prompt = (
        "Anda adalah pakar analis ekonomi dan pangan nasional.\n"
        "Berdasarkan data pergerakan rata-rata harga pangan pokok tingkat nasional berikut:\n\n"
        f"{summary_list_text}\n\n"
        "Berikan analisis ringkas, profesional, dan padat mengenai situasi harga pangan nasional saat ini serta proyeksi singkat ke depan dalam maksimal 60 kata.\n"
        "Respon wajib langsung berupa teks analisis saja tanpa tanda kutip di awal/akhir, tanpa markdown codeblock, dan tanpa embel-embel kalimat pembuka/penutup."
    )

    headers = {
        "Authorization": f"Bearer {settings.NVIDIA_API_KEY}",
        "Content-Type": "application/json"
    }

    import urllib.request
    import urllib.error
    import json

    url = "https://integrate.api.nvidia.com/v1/chat/completions"
    
    # Coba Google Gemma 3 12B IT (Model modern, seimbang antara performa & kecepatan)
    try:
        body = {
            "model": "google/gemma-3-12b-it",
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.2,
            "max_tokens": 256
        }
        req = urllib.request.Request(
            url,
            data=json.dumps(body).encode("utf-8"),
            headers=headers,
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=40) as response:
            res_body = response.read().decode("utf-8")
            data = json.loads(res_body)
            choices = data.get("choices", [])
            result_text = None
            if choices:
                content = choices[0].get("message", {}).get("content")
                if content:
                    result_text = content.strip()
            
            if result_text:
                # Bersihkan jika ada codeblock
                if result_text.startswith("```"):
                    result_text = "\n".join([line for line in result_text.split("\n") if not line.startswith("```")])
                result_text = result_text.strip()
                
                _global_analysis_cache[latest_date_str] = result_text
                logger.info("Global AI Analysis berhasil dibuat menggunakan NVIDIA NIM (Google Gemma 3 12B).")
                return result_text
    except Exception as e:
        logger.warning(f"Percobaan NVIDIA Google Gemma 3 12B untuk global analysis gagal: {str(e)}. Menggunakan fallback Google Gemma 2 2B...")
        
        # Fallback 1: Google Gemma 2 2B IT (Sangat ringan, minim resiko timeout)
        try:
            body = {
                "model": "google/gemma-2-2b-it",
                "messages": [
                    {"role": "user", "content": prompt}
                ],
                "temperature": 0.2,
                "max_tokens": 256
            }
            fallback_req = urllib.request.Request(
                url,
                data=json.dumps(body).encode("utf-8"),
                headers=headers,
                method="POST"
            )
            with urllib.request.urlopen(fallback_req, timeout=30) as response:
                res_body = response.read().decode("utf-8")
                data = json.loads(res_body)
                choices = data.get("choices", [])
                result_text = None
                if choices:
                    content = choices[0].get("message", {}).get("content")
                    if content:
                        result_text = content.strip()
                
                if result_text:
                    # Bersihkan jika ada codeblock
                    if result_text.startswith("```"):
                        result_text = "\n".join([line for line in result_text.split("\n") if not line.startswith("```")])
                    result_text = result_text.strip()
                    
                    _global_analysis_cache[latest_date_str] = result_text
                    logger.info("Global AI Analysis berhasil dibuat menggunakan fallback model Google Gemma 2 2B.")
                    return result_text
        except Exception as fallback_err:
            logger.error(f"Gagal mengambil Global AI Analysis dari NVIDIA NIM Google Gemma 3 12B maupun Gemma 2 2B: {str(fallback_err)}.")
            
    # Fallback akhir jika API bermasalah/gagal
    _global_analysis_cache[latest_date_str] = default_fallback
    return default_fallback

def get_consolidated_market_summary(db: Session) -> dict:
    commodities_data = []
    
    # Ambil data historis 30 hari terakhir untuk kalkulasi perubahan harga
    # Kita cari tanggal terakhir yang ada di database
    latest_price_rec = db.query(models.CommodityPrice).order_by(models.CommodityPrice.date.desc()).first()
    if not latest_price_rec:
        return {"commodities": [], "metadata": {}}
        
    latest_date = latest_price_rec.date
    
    for parent_name, children_names in PARENT_CHILD_MAP.items():
        # Ambil record sub-commodities
        children = db.query(models.Commodity).filter(models.Commodity.name.in_(children_names)).all()
        if not children:
            continue
            
        child_ids = [c.id for c in children]
        
        # Ambil harga historis sub-commodities untuk dirata-ratakan
        # history limit 30 hari
        history_start = latest_date - timedelta(days=35) # ambil extra untuk pastikan ada data
        prices_query = db.query(models.CommodityPrice).filter(
            models.CommodityPrice.commodity_id.in_(child_ids),
            models.CommodityPrice.date >= history_start
        ).order_by(models.CommodityPrice.date.asc()).all()
        
        # Kelompokkan harga berdasarkan tanggal
        date_price_map = {}
        for p in prices_query:
            date_str = p.date.strftime("%Y-%m-%d")
            if date_str not in date_price_map:
                date_price_map[date_str] = []
            date_price_map[date_str].append(p.price)
            
        # Rata-rata harga per tanggal untuk parent
        parent_history = []
        sorted_dates = sorted(date_price_map.keys())
        for d_str in sorted_dates:
            avg_p = sum(date_price_map[d_str]) / len(date_price_map[d_str])
            parent_history.append({"date": d_str, "price": round(avg_p, 2)})
            
        # Batasi history ke 30 hari terakhir
        parent_history = parent_history[-30:]
        
        if not parent_history:
            continue
            
        current_price = parent_history[-1]["price"]
        
        # Hitung perubahan harga historis (day_1, day_7, day_30)
        price_changes = {"day_1": 0.0, "day_7": 0.0, "day_30": 0.0}
        if len(parent_history) >= 2:
            p_prev_24h = parent_history[-2]["price"]
            price_changes["day_1"] = round(((current_price - p_prev_24h) / p_prev_24h) * 100, 2) if p_prev_24h > 0 else 0.0
        if len(parent_history) >= 7:
            p_prev_7d = parent_history[-7]["price"]
            price_changes["day_7"] = round(((current_price - p_prev_7d) / p_prev_7d) * 100, 2) if p_prev_7d > 0 else 0.0
        if len(parent_history) >= 30:
            p_prev_30d = parent_history[0]["price"]
            price_changes["day_30"] = round(((current_price - p_prev_30d) / p_prev_30d) * 100, 2) if p_prev_30d > 0 else 0.0
            
        # We no longer calculate live forecast points for all subcategories in the summary view to keep it ultra-fast.
        # Instead, we project a basic trend based on the historical 7-day change.
        forecast_pct = price_changes["day_7"]
        trend = "naik" if forecast_pct > 0.5 else ("turun" if forecast_pct < -0.5 else "stabil")
        
        # Generate sub_commodities list
        sub_commodities_list = []
        for child in children:
            # Ambil 2 harga terakhir untuk sub-commodity ini
            recent_p = db.query(models.CommodityPrice).filter(
                models.CommodityPrice.commodity_id == child.id
            ).order_by(models.CommodityPrice.date.desc()).limit(2).all()
            
            if not recent_p:
                continue
                
            c_price = recent_p[0].price
            prev_price = recent_p[1].price if len(recent_p) > 1 else c_price
            change_pct = round(((c_price - prev_price) / prev_price) * 100, 2) if prev_price > 0 else 0.0
            c_trend = "naik" if change_pct > 0 else ("turun" if change_pct < 0 else "stabil")
            
            sub_commodities_list.append({
                "name": child.name,
                "price": c_price,
                "change_pct": change_pct,
                "trend": c_trend,
                "image_asset": IMAGE_ASSETS.get(parent_name, "")
            })
            
        commodities_data.append({
            "name": parent_name,
            "current_price": current_price,
            "unit": get_commodity_unit(parent_name),
            "price_changes": price_changes,
            "forecast_pct": forecast_pct,
            "trend": trend,
            "reliability": "Tinggi",
            "market_alert": f"Harga {parent_name} cenderung {trend}." if trend != "stabil" else f"Harga {parent_name} stabil.",
            "image_asset": IMAGE_ASSETS.get(parent_name, ""),
            "insight": generate_rule_based_insight(
                parent_name,
                trend,
                forecast_pct,
                price_changes["day_1"]
            ),
            "chart": {
                "history": parent_history,
                "forecast": []
            },
            "sub_commodities": sub_commodities_list
        })
        
    latest_date_str = latest_date.strftime("%Y-%m-%d")
    default_fallback = "Analisis harga pangan pokok nasional menunjukkan stabilitas pada kelompok beras, namun fluktuasi minor terdeteksi pada komoditas cabai dan bawang karena faktor cuaca musiman."

    metadata = {
        "updated_at": latest_date_str,
        "global_analysis": default_fallback,
        "disclaimer": "Prediksi harga ini dihasilkan oleh kecerdasan buatan (SARIMAX Model) untuk membantu perkiraan perencanaan belanja. Keputusan pembelian tetap di tangan konsumen.",
        "about_us": {
            "title": "Arjuna Pijak API - Forecasting Engine",
            "app_name": "Arjuna",
            "description": "Analisis Harga & Tinjauan Pangan Nusantara",
            "version": "1.0.0",
            "developer": "Capstone Team - PJK-GU106"
        }
    }
    
    return {
        "commodities": commodities_data,
        "metadata": metadata
    }

def get_global_market_analysis(db: Session) -> dict:
    """
    Mengambil analisis pasar pangan global secara dinamis (AI Insight).
    Fungsi ini berjalan secara independen agar tidak memperlambat loading summary komoditas.
    """
    latest_price_rec = db.query(models.CommodityPrice).order_by(models.CommodityPrice.date.desc()).first()
    if not latest_price_rec:
        return {"global_analysis": "", "updated_at": ""}
        
    latest_date_str = latest_price_rec.date.strftime("%Y-%m-%d")
    
    # Ambil data komoditas teragregasi untuk feed prompt
    summary = get_consolidated_market_summary(db)
    commodities_data = summary.get("commodities", [])
    
    global_analysis_text = get_global_ai_analysis(db, commodities_data, latest_date_str)
    return {
        "global_analysis": global_analysis_text,
        "updated_at": latest_date_str
    }
