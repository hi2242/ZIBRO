from fastapi import APIRouter, HTTPException, Depends, Form
from sqlalchemy.orm import Session
from database import get_db, SessionLocal
from models import User
from schemas import UserCreate, UserResponse, UserLogin, UserUpdate
from utils import hash_password, verify_password, get_current_user
import jwt
import datetime

# 라우터 생성
router = APIRouter()

# JWT 관련 상수
SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"

# 회원가입 API
@router.post("/register/", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")

    hashed_password = hash_password(user.password)
    db_user = User(**user.dict(exclude={"password"}), password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return UserResponse(id=db_user.id, **user.dict())

# 로그인 API
@router.post("/login/")
def login(username: str = Form(...), password: str = Form(...), db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == username).first()

    if not db_user or not verify_password(password, db_user.password):
        raise HTTPException(status_code=400, detail="Invalid username or password")

    utc_now = datetime.datetime.now(datetime.timezone.utc)
    token = jwt.encode({
        "sub": db_user.username,
        "exp": utc_now + datetime.timedelta(hours=1)
    }, SECRET_KEY, algorithm=ALGORITHM)

    return {"access_token": token, "token_type": "bearer"}

# 현재 사용자 조회 API
@router.get("/me/", response_model=UserResponse)
def read_users_me(current_user: str = Depends(get_current_user), db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == current_user).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse(id=db_user.id, username=db_user.username)

# 사용자 정보 업데이트 API
@router.put("/me/", response_model=UserResponse)
def update_user_info(user_update: UserUpdate, current_user: str = Depends(get_current_user), db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == current_user).first()

    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    # 업데이트 가능한 필드만 수정
    for field, value in user_update.dict(exclude_unset=True).items():
        setattr(db_user, field, value)

    db.commit()
    db.refresh(db_user)

    return UserResponse(id=db_user.id, username=db_user.username)

# 평점 부여 API
@router.post("/ratings/")
def rate_user(rating: float, user_id: int, db: Session = Depends(get_db)):
    if rating < 0.0 or rating > 5.0 or rating % 0.5 != 0:
        raise HTTPException(status_code=400, detail="Rating must be between 0.0 and 5.0 in increments of 0.5")

    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    db_user.rating = round((db_user.rating + rating) / 2, 1) if db_user.rating else rating
    db.commit()
    db.refresh(db_user)

    return {"user_id": db_user.id, "new_rating": db_user.rating}
