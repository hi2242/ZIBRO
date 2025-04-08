from pydantic import BaseModel
from datetime import datetime
from typing import List

class UserCreate(BaseModel):
   username: str
   password: str
   name: str
   birth_date: str  # 생년월일 추가
   gender: str
   university: str  # 대학 추가
   major: str  # 학과 추가
   phone_number: str  # 휴대폰 번호 추가

class UserResponse(BaseModel):
    id: int
    username: str
    name: str
    birth_date: str  # 생년월일 추가
    gender: str
    university: str  # 대학 추가
    major: str  # 학과 추가
    phone_number: str  # 휴대폰 번호 추가

class Ride(BaseModel):
    id: int
    user_id: int
    distance: float
    carbon_emission: float
    savings: float

class RideCreate(BaseModel):
    distance: float

class UserLogin(BaseModel):
    username: str
    password: str

class UserUpdate(BaseModel):
    name: str
    birth_date: str  # 생년월일 추가
    gender: str
    university: str  # 대학 추가
    major: str  # 학과 추가
    phone_number: str  # 휴대폰 번호 추가

class PartyCreate(BaseModel):
    origin: str
    destination: str
    departure_time: datetime

class PartyResponse(BaseModel):
    id: int
    host_id: int
    origin: str
    destination: str
    departure_time: datetime

    class Config:
        orm_mode = True

class PartyJoin(BaseModel):
    party_id: int

class PartyMemberResponse(BaseModel):
    id: int
    party_id: int
    user_id: int

    class Config:
        orm_mode = True
#<<<<<<< HEAD
        
class RatingCreate(BaseModel):
    user_id: int
    rating: float
#=======

class DriverCreate(BaseModel):
    username: str
    password: str
    name: str
    gender: str
    birth_date: str
    vehicle_type: str
    vehicle_number: str
    license_number: str  # 기사 면허증
    company: str

class DriverResponse(BaseModel):
    id: int
    username: str
    name: str
    gender: str
    birth_date: str
    vehicle_type: str
    vehicle_number: str
    license_number: str
    company: str

    class Config:
        orm_mode = True

class DriverLogin(BaseModel):
    username: str
    password: str

class DriverUpdate(BaseModel):
    name: str
    gender: str
    birth_date: str
    vehicle_type: str
    vehicle_number: str
    license_number: str
    company: str
#>>>>>>> origin/BaeMG
