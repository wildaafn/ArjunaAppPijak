from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Arjuna Pijak API"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = "API Prediksi Harga Pangan Pokok dengan model SARIMAX"
    
    APP_ENV: str = "development"
    DEBUG: bool = True
    
    # PostgreSQL Database
    DATABASE_HOST: str = "localhost"
    DATABASE_PORT: int = 5432
    DATABASE_USER: str = "user"
    DATABASE_PASSWORD: str = "password"
    DATABASE_NAME: str = "arjuna_pijak"
    
    DATABASE_URL_ENV: Optional[str] = None
    
    @property
    def DATABASE_URL(self) -> str:
        if self.DATABASE_URL_ENV:
            return self.DATABASE_URL_ENV
        return f"postgresql://{self.DATABASE_USER}:{self.DATABASE_PASSWORD}@{self.DATABASE_HOST}:{self.DATABASE_PORT}/{self.DATABASE_NAME}"
    
    # Security & CORS
    ALLOWED_ORIGINS: str = "*"

    # AI Insight Configuration
    NVIDIA_API_KEY: str = ""

    # News Configuration (GNews.io)
    GNEWS_API_KEY: str = ""

    class Config:
        env_file = ".env"

settings = Settings()
