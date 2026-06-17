from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey
from sqlalchemy.orm import relationship
from app.db.database import Base

class Commodity(Base):
    __tablename__ = "commodities"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    level = Column(Integer, nullable=False)
    
    prices = relationship("CommodityPrice", back_populates="commodity", cascade="all, delete-orphan")

class CommodityPrice(Base):
    __tablename__ = "commodity_prices"

    id = Column(Integer, primary_key=True, index=True)
    commodity_id = Column(Integer, ForeignKey("commodities.id"), nullable=False, index=True)
    date = Column(Date, nullable=False, index=True)
    price = Column(Float, nullable=False)

    commodity = relationship("Commodity", back_populates="prices")
