import bcrypt
import jwt
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from database import get_db, SessionLocal
from models import User, Driver  # User와 Driver 모델 import
from sqlalchemy.orm import Session

# JWT 관련 설정
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/login/")
driver_oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/drivers/login/")

SECRET_KEY = "your_secret_key"  # 비밀 키 설정 (환경 변수로 관리 권장)
ALGORITHM = "HS256"

# 비밀번호 해싱 및 검증 함수
def hash_password(password: str) -> str:
    """
    입력받은 비밀번호를 해싱하여 반환합니다.
    """
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    입력받은 비밀번호와 해싱된 비밀번호를 비교하여 일치 여부를 반환합니다.
    """
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

# 현재 사용자 가져오기
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    JWT 토큰에서 사용자 정보를 추출하고, 데이터베이스에서 사용자를 반환합니다.
    """
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception

    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise credentials_exception

    return user

# 현재 운전기사 가져오기
def get_current_driver(token: str = Depends(driver_oauth2_scheme)):
    """
    JWT 토큰에서 운전기사 정보를 추출하고, 데이터베이스에서 운전기사를 반환합니다.
    """
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except jwt.PyJWTError:
        raise credentials_exception

    db: Session = SessionLocal()  # 세션 열기
    try:
        driver = db.query(Driver).filter(Driver.username == username).first()
        if driver is None:
            raise credentials_exception
    finally:
        db.close()  # 세션 닫기

    return driver  # 운전기사 객체 반환
