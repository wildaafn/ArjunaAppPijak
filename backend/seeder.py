import json
import os
from datetime import datetime
from sqlalchemy.orm import Session

# Tambahkan direktori saat ini ke sys.path agar bisa import module app
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.db.database import engine, Base
from app.db.models import Commodity, CommodityPrice

DATASET_PATH = "dataset/commodity_history.json"

def seed_data():
    if not os.path.exists(DATASET_PATH):
        print(f"Dataset not found at {DATASET_PATH}")
        return

    # Create tables if not exist
    Base.metadata.create_all(bind=engine)
    
    with open(DATASET_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)

    with Session(engine) as db:
        print("Starting database seeding...")
        items = data.get("data", [])
        
        count = 0
        for item in items:
            name = item.get("name")
            level = item.get("level")
            
            if not name or level is None:
                continue
                
            commodity = db.query(Commodity).filter(Commodity.name == name).first()
            if not commodity:
                commodity = Commodity(name=name, level=level)
                db.add(commodity)
                db.commit()
                db.refresh(commodity)
                
            # Process prices
            prices_to_add = []
            for key, value in item.items():
                if "/" in key:
                    try:
                        price_val = float(str(value).replace(",", ""))
                        date_val = datetime.strptime(key, "%d/%m/%Y").date()
                        prices_to_add.append(CommodityPrice(
                            commodity_id=commodity.id,
                            date=date_val,
                            price=price_val
                        ))
                    except (ValueError, TypeError):
                        pass
            
            if prices_to_add:
                # Hapus data harga lama untuk komoditas ini jika ada (agar idempotent)
                db.query(CommodityPrice).filter(CommodityPrice.commodity_id == commodity.id).delete()
                db.bulk_save_objects(prices_to_add)
                db.commit()
                
            count += 1
            if count % 10 == 0:
                print(f"Processed {count} commodities...")
                
        print("Seeding completed successfully.")

if __name__ == "__main__":
    seed_data()
