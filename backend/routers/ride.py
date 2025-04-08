from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Ride
from schemas import RideCreate

router = APIRouter()

@router.post("/rides/")
def create_ride(ride: RideCreate, user_id: int):
    db: Session = SessionLocal()
    # 이동 기록 추가 로직 생략
    db.close()
