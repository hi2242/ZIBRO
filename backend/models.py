from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from database import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)
    name = Column(String)
    birth_date = Column(String)
    university = Column(String)  # 대학 추가
    gender = Column(String)
    major = Column(String) # 학과 추가
    phone_number = Column(String) # 휴대폰 번호 추가

#<<<<<<< HEAD
    parties = relationship("Party", back_populates="host")
#=======
    parties = relationship("Party", back_populates="host") 
#>>>>>>> origin/BaeMG
    party_members = relationship("PartyMember", back_populates="user")
    rides = relationship("Ride", back_populates="user")  # 추가된 부분

class Ride(Base):
    __tablename__ = "rides"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))  # 외래 키 제약 조건 추가
    distance = Column(Float)
    carbon_emission = Column(Float)
    savings = Column(Float)

    user = relationship("User", back_populates="rides")  # 추가된 부분

class Party(Base):
    __tablename__ = "parties"
    
    id = Column(Integer, primary_key=True, index=True)
    host_id = Column(Integer, ForeignKey("users.id"))
    origin = Column(String)
    destination = Column(String)
    departure_time = Column(DateTime)
    
    host = relationship("User", back_populates="parties")
    members = relationship("PartyMember", back_populates="party")

class PartyMember(Base):
    __tablename__ = "party_members"
    
    id = Column(Integer, primary_key=True, index=True)
    party_id = Column(Integer, ForeignKey("parties.id"))
    user_id = Column(Integer, ForeignKey("users.id"))

    party = relationship("Party", back_populates="members")
    user = relationship("User", back_populates="party_members")

#<<<<<<< HEAD
class UserRating(Base):
    __tablename__ = 'user_ratings'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)  # 사용자 ID
    rating = Column(Float, default=0.0)  # 평점
#=======
class Driver(Base):
    __tablename__ = "drivers"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)
    name = Column(String)
    gender = Column(String)
    birth_date = Column(String)
    vehicle_type = Column(String)  # 차종
    vehicle_number = Column(String)  # 차량번호
    license_number = Column(String)  # 기사면허증
    company = Column(String)  # 회사
#>>>>>>> origin/BaeMG
