from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.caregiver import Caregiver, CaregiverDocument
from app.schemas.caregiver import CaregiverSignupRequest, CaregiverSignupResponse, CaregiverOut
from app.core.security import get_password_hash

router = APIRouter()

@router.post("/signup/caregiver", response_model=CaregiverSignupResponse)
def signup_caregiver(request: CaregiverSignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    try:
        new_user = User(
            email=request.user.email,
            hashed_password=get_password_hash(request.user.password),
            role="caregiver"
        )
        db.add(new_user)
        db.flush()  # Gets the new_user.id without committing the transaction

        new_caregiver = Caregiver(
            user_id=new_user.id,
            **request.profile.model_dump(),
            status="pending"
        )

        db.add(new_caregiver)
        db.flush()

        # Add documents
        for doc in request.documents:
            new_doc = CaregiverDocument(
                caregiver_id=new_caregiver.id,
                **doc.model_dump()
            )
            db.add(new_doc)

        db.commit() # Atomic commit for user, profile, and documents
        db.refresh(new_user)
        db.refresh(new_caregiver)

        return {
            "user": new_user,
            "profile": new_caregiver,
            "message": "Caregiver account created successfully"
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Signup failed: {str(e)}")


@router.get("/caregivers", response_model=List[CaregiverOut])
def list_verified_caregivers(db: Session = Depends(get_db)):
    """
    Public endpoint to list caregivers with status == 'verified'.
    """
    caregivers = db.query(Caregiver).join(Caregiver.user).filter(Caregiver.status == "verified").all()
    return caregivers

@router.get("/caregivers/{caregiver_id}", response_model=CaregiverOut)
def get_caregiver_profile(caregiver_id: int, db: Session = Depends(get_db)):
    """
    Public endpoint to get a single caregiver's profile.
    """
    caregiver = db.query(Caregiver).filter(Caregiver.id == caregiver_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")
    return caregiver
