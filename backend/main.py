from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from database import Base, engine  # Base와 engine을 올바르게 임포트합니다.
from routers import user, ride, party, driver, websocket

# 데이터베이스 초기화: 테이블 생성
Base.metadata.create_all(bind=engine)

# FastAPI 애플리케이션 인스턴스 생성
app = FastAPI()

# CORS 설정
origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://127.0.0.1:8000"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 포함
app.include_router(user.router)
app.include_router(ride.router)
app.include_router(party.router)
app.include_router(driver.router)
app.include_router(websocket.router)  # WebSocket 라우터 포함

# 루트 엔드포인트
@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

# Mock 데이터 생성
mock_party_data = {
    "partyDetails": {
        "departure": "마포구",
        "destination": "미추홀구",
        "gatheringLocation": "홍대역 7번 출구",
        "departureTime": "Sat 2:30 AM"
    },
    "myInfo": {
        "name": "김인하",
        "university": "인하대학교",
        "department": "컴퓨터 공학과",
        "gender": "여성",
        "age": "21",
        "mannerTemp": "43.5",
        "drunk": "O",
        "indiv_destination": "인하대학교",
        "indiv_departure" : "홍대역 9번출구"
    },
    "partyMembers": [
        {
            "name": "박인뇽",
            "university": "인하대학교",
            "department": "컴퓨터 공학과",
            "gender": "여성",
            "age": "21",
            "mannerTemp": "43.5",
            "drunk": "O",
            "indiv_destination": "송도 센트럴 파크",
            "indiv_departure" : "합정역 3번 출구",
            "eta" : 50,
            "arrivalTime" : "3:33 AM"
        },
        {
            "name": "이탄소",
            "university": "인천대학교",
            "department": "정보통신 공학과",
            "gender": "여성",
            "age": "21",
            "mannerTemp": "39.5",
            "drunk": "O",
            "indiv_destination": "송도 트리플 스트리트",
            "indiv_departure" : "합정역 7번 출구",
            "eta" : 54,
            "arrivalTime" : "3:37 AM"
        }
    ]
}

# 인근 택시 파티 더미 데이터
mock_taxi_parties = [
    {
        "party_id": 1,
        "departure": "마포구",
        "destination": "부평구",
        "gatheringLocation": "홍대역 3번 출구",
        "departureTime": "Sat 1:30 AM",
        "status": "2/3 파티 모집 중",
        "male": "🚺"
    },
    {
        "party_id": 2,
        "departure": "마포구",
        "destination": "연수구",
        "gatheringLocation": "홍대역 9번 출구",
        "departureTime": "Sat 2:45 AM",
        "status": "3/3 파티 모집 완료",
        "male": "🚺"
    },
    {
        "party_id": 3,
        "departure": "마포구",
        "destination": "부평구",
        "gatheringLocation": "홍대역 3번 출구",
        "departureTime": "Sat 3:30 AM",
        "status": "1/3 파티의 모집 중",
        "male": "🚹"
    },
]

# Mock 데이터에 출발지와 목적지 좌표 포함
mock_departure_coords = {
    "location": "마포구",
    "latitude": 37.55591,
    "longitude": 126.922951,
}

mock_destinations_coords = [
    {
        "party_id": 1,
        "location": "인하대학교",
        "latitude": 37.4500221,
        "longitude": 126.653488,
    },
    {
        "party_id": 2,
        "location": "송도 센트럴파크",
        "latitude": 37.3922621,
        "longitude": 126.6396891,
    },
    {
        "party_id": 3,
        "location": "송도 트리플 스트리트",
        "latitude": 37.3786464,
        "longitude": 126.6627468,
    },
]

# 파티 상세 정보를 반환하는 엔드포인트
@app.get("/party/details/{party_id}")
def get_party_details(party_id: int):
    return mock_party_data

# 기사 정보 더미 데이터를 반환하는 엔드포인트
@app.get("/driver")
def get_driver_info():
    driver_info = {
        "name": "김인덕",
        "car": "현대 더 뉴 아반떼, 흰색",
        "plate": "125너 7620",
        "mannerTemperature": 39.4,
        "phoneNumber": "010-1234-5678",
    }
    return driver_info
# 인근 파티 목록 엔드포인트
@app.get("/parties")
def get_taxi_parties():
    return JSONResponse(
        content={"parties": mock_taxi_parties},
        headers={"Content-Type": "application/json; charset=utf-8"}  # UTF-8 설정
    )

# 출발지 정보를 반환하는 엔드포인트
@app.get("/departure")
def get_departure():
    return JSONResponse(
        content=mock_departure_coords,
        headers={"Content-Type": "application/json; charset=utf-8"},
    )

# 목적지 목록을 반환하는 엔드포인트
@app.get("/destinations")
def get_destinations():
    return JSONResponse(
        content={"destinations": mock_destinations_coords},
        headers={"Content-Type": "application/json; charset=utf-8"},
    )
