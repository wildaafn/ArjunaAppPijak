from pydantic import BaseModel
from typing import List

class DailyPrediction(BaseModel):
    date: str
    day_name: str
    predicted_price: float

class ForecastResponse(BaseModel):
    subcategory: str
    model_used: str
    last_historical_price: float
    last_historical_date: str
    predictions: List[DailyPrediction]
    trend: float
    horizon: int
    predicted_price: float
