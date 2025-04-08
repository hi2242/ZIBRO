from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
from models import Party, PartyMember, User
from schemas import PartyCreate, PartyResponse, PartyJoin, PartyMemberResponse
from utils import get_current_user
from database import get_db

router = APIRouter()

@router.post("/parties/make/")
def create_party(party: PartyCreate, current_user: User = Depends(get_current_user)):
    db: Session = SessionLocal()  # 세션 열기
    try:
        # 새로운 파티 생성
        new_party = Party(
            host_id=current_user.id,
            origin=party.origin,
            destination=party.destination,
            departure_time=party.departure_time
        )
        
        db.add(new_party)
        db.commit()
        db.refresh(new_party)

        # 현재 유저를 파티 참여자로 추가
        party_member = PartyMember(
            party_id=new_party.id,
            user_id=current_user.id
        )
        db.add(party_member)
        db.commit()

    finally:
        db.close()  # 세션 닫기
    
    return new_party

@router.post("/parties/{party_id}/join")
def join_party(party_id: int, current_user: User = Depends(get_current_user)):
    db: Session = SessionLocal()  # 세션 열기
    try:
        # 파티 정보 조회
        party = db.query(Party).filter(Party.id == party_id).first()
        if not party:
            raise HTTPException(status_code=404, detail="Party not found")

        # 현재 유저를 파티 참여자로 추가
        party_member = PartyMember(
            party_id=party.id,
            user_id=current_user.id
        )
        db.add(party_member)
        db.commit()

    finally:
        db.close()  # 세션 닫기
    
    return {"message": "Successfully joined the party"}

@router.get("/parties/")
def list_parties(db: Session = Depends(get_db)):
    parties = db.query(Party).all()  # 모든 파티 조회

    # 각 파티에 대해 유저 이름을 포함한 결과 생성
    party_list = []
    for party in parties:
        members = db.query(User).join(PartyMember).filter(PartyMember.party_id == party.id).all()
        member_names = [member.name for member in members]  # 유저의 name 속성을 사용
        
        party_list.append({
            "party_id": party.id,
            "host_id": party.host_id,
            "origin": party.origin,
            "destination": party.destination,
            "departure_time": party.departure_time,
            "members": member_names  # 멤버 이름 추가
        })

    return party_list
