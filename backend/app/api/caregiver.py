from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.caregiver import Caregiver, CaregiverDocument
from app.schemas.caregiver import CaregiverSignupRequest, CaregiverSignupResponse
from app.core.security import get_password_hash

router = APIRouter()

@router.post("/signup/caregiver", response_model=CaregiverSignupResponse)
def signup_caregiver(request: CaregiverSignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=request.user.email,
        hashed_password=get_password_hash(request.user.password),
        role="caregiver"
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    new_caregiver = Caregiver(
        user_id=new_user.id,
        **request.profile.model_dump()
    )
    db.add(new_caregiver)
    db.commit()
    db.refresh(new_caregiver)

    # Add documents
    for doc in request.documents:
        new_doc = CaregiverDocument(
            caregiver_id=new_caregiver.id,
            **doc.model_dump()
        )
        db.add(new_doc)
    
    db.commit()
    db.refresh(new_caregiver)

    return {
        "user": new_user,
        "profile": new_caregiver
    }
