from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.db.session import get_db
from app.api import deps
from app.models.complaint import Complaint
from app.models.caregiver import Caregiver
from app.models.user import User
from app.schemas.complaint import ComplaintCreate, ComplaintOut, ComplaintUpdate

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
    complaints = db.query(Complaint).filter(Complaint.reporter_id == current_user.id).all()

    results = []
    for c in complaints:
        results.append({
            "id": c.id,
            "reporter_id": c.reporter_id,
            "caregiver_id": c.caregiver_id,
            "category": c.category,
            "description": c.description,
            "status": c.status,
            "admin_notes": c.admin_notes,
            "resolution_feedback": c.resolution_feedback,
            "caregiver_explanation": c.caregiver_explanation,
            "created_at": c.created_at,
            "caregiver_name": c.caregiver.name if c.caregiver else "Caregiver"
        })
    return results

@router.get("/caregiver", response_model=List[ComplaintOut])
def get_caregiver_complaints(
    db: Session = Depends(get_db),
    current_user = Depends(deps.get_current_active_user)
):
    """
    Get all complaints filed against the current caregiver.
    """
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver profile not found")

    complaints = db.query(Complaint).options(
        joinedload(Complaint.reporter).joinedload(User.elder_profile),
        joinedload(Complaint.reporter).joinedload(User.family_profile)
    ).filter(Complaint.caregiver_id == caregiver.id).all()

    results = []
    for c in complaints:
        reporter_name = c.reporter.email
        if c.reporter.role == "elder" and c.reporter.elder_profile:
            reporter_name = c.reporter.elder_profile.name
        elif c.reporter.role == "family" and c.reporter.family_profile:
            reporter_name = c.reporter.family_profile.name

        results.append({
            "id": c.id,
            "reporter_id": c.reporter_id,
            "caregiver_id": c.caregiver_id,
            "category": c.category,
            "description": c.description,
            "status": c.status,
            "admin_notes": None, # Hide internal notes from caregiver
            "resolution_feedback": c.resolution_feedback,
            "caregiver_explanation": c.caregiver_explanation,
            "created_at": c.created_at,
            "reporter_name": reporter_name,
            "caregiver_name": c.caregiver.name
        })
    return results

@router.patch("/{complaint_id}/respond", response_model=ComplaintOut)
def respond_to_complaint(
    complaint_id: int,
    explanation_in: ComplaintUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(deps.get_current_active_user)
):
    """
    Allow a caregiver to provide their explanation for a complaint.
    """
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(status_code=403, detail="Not authorized")

    complaint = db.query(Complaint).filter(
        Complaint.id == complaint_id,
        Complaint.caregiver_id == caregiver.id
    ).first()

    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")

    if explanation_in.caregiver_explanation:
        complaint.caregiver_explanation = explanation_in.caregiver_explanation
        if complaint.status == "pending":
            complaint.status = "under_review"

    db.commit()
    db.refresh(complaint)
    return complaint
