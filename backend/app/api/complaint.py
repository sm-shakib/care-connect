from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.session import get_db
from app.api import deps
from app.models.complaint import Complaint
from app.schemas.complaint import ComplaintCreate, ComplaintOut

router = APIRouter()

@router.post("/", response_model=ComplaintOut)
def file_complaint(
    complaint_in: ComplaintCreate,
    db: Session = Depends(get_db),
    current_user = Depends(deps.get_current_active_user)
):
    """
    File a new complaint against a caregiver.
    """
    new_complaint = Complaint(
        reporter_id=current_user.id,
        **complaint_in.model_dump()
    )
    db.add(new_complaint)
    db.commit()
    db.refresh(new_complaint)
    return new_complaint

@router.get("/me", response_model=List[ComplaintOut])
def get_my_complaints(
    db: Session = Depends(get_db),
    current_user = Depends(deps.get_current_active_user)
):
    """
    Get all complaints filed by the current user.
    """
    return db.query(Complaint).filter(Complaint.reporter_id == current_user.id).all()
