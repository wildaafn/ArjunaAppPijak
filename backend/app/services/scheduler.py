import logging
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

logger = logging.getLogger(__name__)

def perform_scheduled_sync():
    """Tugas harian yang dijalankan oleh cron job untuk mengambil data terbaru dan retraining model."""
    logger.info("Memulai sync terjadwal harian (10:00 WIB)...")
    from app.db.database import SessionLocal
    with SessionLocal() as db:
        try:
            from app.services.sync_service import trigger_full_sync_job
            trigger_full_sync_job(db)
            logger.info("Sync terjadwal harian selesai dengan sukses.")
        except Exception as e:
            logger.error(f"Gagal mengeksekusi sync terjadwal harian: {e}")

def start_scheduler():
    scheduler = BackgroundScheduler()
    # Menjadwalkan tugas setiap hari ('*') jam 10:00 WIB
    trigger = CronTrigger(day_of_week='*', hour=10, minute=0, timezone='Asia/Jakarta')
    scheduler.add_job(perform_scheduled_sync, trigger)
    scheduler.start()
    logger.info("Scheduler APScheduler telah dimulai. Sync & Retraining dijadwalkan setiap hari pukul 10:00 WIB.")
