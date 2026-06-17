import logging
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

logger = logging.getLogger(__name__)

def perform_retraining():
    """
    Tugas yang dijalankan oleh cron job untuk melakukan training ulang model.
    Di environment production, ini bisa mengeksekusi pipeline retraining SARIMAX
    dan menyimpan parameter/model terbaik ke database atau storage.
    """
    logger.info("Memulai proses training ulang model SARIMAX...")
    try:
        from app.services.forecast import _forecast_cache, _audit_cache, _insight_cache
        _forecast_cache.clear()
        _audit_cache.clear()
        _insight_cache.clear()
        logger.info("Cache ramalan, audit model, dan AI Insight berhasil dibersihkan.")
    except Exception as e:
        logger.error(f"Gagal membersihkan cache ramalan/audit/insight: {str(e)}")
    
    # TODO: Implementasi logika retraining (misal: memanggil fungsi fine-tuning 
    # untuk setiap komoditas dan mengupdate parameter di database)
    logger.info("Proses training ulang model selesai.")

def start_scheduler():
    scheduler = BackgroundScheduler()
    # Menjadwalkan tugas pada hari Senin ('mon') jam 12:00 WIB
    # Catatan: Pastikan timezone server sudah diset ke Asia/Jakarta (WIB)
    # atau spesifikasikan timezone pada trigger.
    trigger = CronTrigger(day_of_week='mon', hour=12, minute=0, timezone='Asia/Jakarta')
    scheduler.add_job(perform_retraining, trigger)
    scheduler.start()
    logger.info("Scheduler APScheduler telah dimulai. Retraining dijadwalkan setiap Senin pukul 12:00 WIB.")
