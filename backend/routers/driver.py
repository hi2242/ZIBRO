from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Driver
from schemas import DriverCreate, DriverResponse, DriverUpdate
from utils import hash_password, verify_password, get_current_driver
import jwt
import datetime


router = APIRouter()
SECRET_KEY = "your_secret_key"  # 비밀 키 설정
ALGORITHM = "HS256"

#운전자 회원가입
@router.post("/drivers/register/", response_model=DriverResponse)
def create_driver(driver: DriverCreate):
    db: Session = SessionLocal()
    try:
        existing_driver = db.query(Driver).filter(Driver.username == driver.username).first()
        if existing_driver:
            raise HTTPException(status_code=400, detail="Username already registered")

        hashed_password = hash_password(driver.password)
        db_driver = Driver(**driver.dict(exclude={"password"}), password=hashed_password)
        db.add(db_driver)
        db.commit()
        db.refresh(db_driver)
    finally:
        db.close()

    return DriverResponse(id=db_driver.id, **driver.dict(exclude={"password"}))

#운전자 로그인
@router.post("/drivers/login/")
def driver_login(username: str = Form(...), password: str = Form(...)):
    db: Session = SessionLocal()
    driver = db.query(Driver).filter(Driver.username == username).first()

    if not driver or not verify_password(password, driver.password):
        raise HTTPException(status_code=400, detail="Invalid username or password")
        
        # JWT 토큰 생성
    utc_now = datetime.datetime.now(datetime.timezone.utc)
    token = jwt.encode({
        "sub": driver.username,
         "exp": utc_now + datetime.timedelta(hours=1)  # 1시간 후 만료
     }, SECRET_KEY, algorithm=ALGORITHM)

    db.close()
    return {"access_token": token, "token_type": "bearer"}



@router.get("/drivers/me/", response_model=DriverResponse)
def read_driver_me(current_driver: Driver = Depends(get_current_driver)):
    return current_driver  # 현재 로그인된 운전기사 정보 반환

#운전자 정보 변경
@router.put("/drivers/change/", response_model=DriverResponse)
def update_driver_info(driver_update: DriverUpdate, current_driver: Driver = Depends(get_current_driver)):
    db: Session = SessionLocal()
    try:
        db_driver = db.query(Driver).filter(Driver.id == current_driver.id).first()
        if db_driver is None:
            raise HTTPException(status_code=404, detail="Driver not found")

        # 정보 업데이트
        db_driver.name = driver_update.name
        db_driver.gender = driver_update.gender
        db_driver.birth_date = driver_update.birth_date
        db_driver.vehicle_type = driver_update.vehicle_type
        db_driver.vehicle_number = driver_update.vehicle_number
        db_driver.license_number = driver_update.license_number
        db_driver.company = driver_update.company

        db.commit()
        db.refresh(db_driver)
    finally:
        db.close()

    return DriverResponse(id=db_driver.id, **driver_update.dict())