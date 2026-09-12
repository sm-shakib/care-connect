from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.caregiver import Caregiver, CaregiverDocument
from app.schemas.caregiver import CaregiverSignupRequest, CaregiverSignupResponse, CaregiverOut, CaregiverDocumentCreate
from app.core.security import get_password_hash
from app.api import deps

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

        profile_data = request.profile.model_dump()
        valid_cols = {c.key for c in Caregiver.__table__.columns}
        filtered_profile_data = {k: v for k, v in profile_data.items() if k in valid_cols}

        new_caregiver = Caregiver(
            user_id=new_user.id,
            **filtered_profile_data,
            status="pending"
        )

        db.add(new_caregiver)
        db.flush()

        # Add documents
        for doc in request.documents:
            doc_data = doc.model_dump()
            valid_doc_cols = {c.key for c in CaregiverDocument.__table__.columns}
            filtered_doc_data = {k: v for k, v in doc_data.items() if k in valid_doc_cols}
            
            new_doc = CaregiverDocument(
                caregiver_id=new_caregiver.id,
                **filtered_doc_data
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

@router.put("/caregivers/me/documents", response_model=CaregiverOut)
def update_caregiver_documents(
    documents: List[CaregiverDocumentCreate],
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Allow a caregiver to re-upload documents if requested by admin.
    """
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver profile not found")

    # Only allow if status is pending or rejected?
    # Usually pending is enough for "request docs".

    # Delete old documents
    db.query(CaregiverDocument).filter(CaregiverDocument.caregiver_id == caregiver.id).delete()

    # Add new documents
    for doc in documents:
        new_doc = CaregiverDocument(
            caregiver_id=caregiver.id,
            **doc.model_dump(),
            is_verified=False
        )
        db.add(new_doc)

    # Reset status to pending if it was something else,
    # though usually it stays pending.
    caregiver.status = "pending"
    # Clear admin notes once resubmitted?
    # Or keep them until admin reviews again.

    db.commit()
    db.refresh(caregiver)
    return caregiver
