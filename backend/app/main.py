from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from datetime import datetime
from app.core.config import settings
from app.api.endpoints import router
from app.services.scheduler import start_scheduler
from app.db.database import engine, Base
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create database tables if they don't exist
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Start the APScheduler cron jobs
    logger.info("Memulai aplikasi dan scheduler...")
    start_scheduler()
    yield
    # Shutdown: Clean up resources
    logger.info("Mematikan aplikasi...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    lifespan=lifespan
)

# Parse allowed CORS origins
allowed_origins = [origin.strip() for origin in settings.ALLOWED_ORIGINS.split(",") if origin.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok", "timestamp": datetime.utcnow().isoformat()}

app.include_router(router)
