from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.db.session import get_db
from app.api import deps
from app.models.caregiver import Caregiver, CaregiverDocument
from app.schemas.caregiver import CaregiverOut, CaregiverDocumentOut, VerificationStatus

from app.core.email import send_email

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/caregivers/verification", response_model=List[CaregiverOut])
def get_caregivers_for_verification(
    status: Optional[VerificationStatus] = None,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    List caregivers for verification, optionally filtered by status.
    """
    query = db.query(Caregiver).options(joinedload(Caregiver.user))
    if status:
        query = query.filter(Caregiver.status == status.value)
    return query.all()

@router.get("/caregivers/{caregiver_id}", response_model=CaregiverOut)
def get_caregiver_detail(
    caregiver_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Get detailed profile of a caregiver for review.
    """
    caregiver = db.query(Caregiver).options(joinedload(Caregiver.user)).filter(Caregiver.id == caregiver_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")
    return caregiver

@router.patch("/caregivers/{caregiver_id}/verify", response_model=CaregiverOut)
def update_caregiver_verification_status(
    caregiver_id: int,
    status: VerificationStatus,
    notes: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Update the overall verification status of a caregiver and send an email notification.
    """
    caregiver = db.query(Caregiver).options(joinedload(Caregiver.user)).filter(Caregiver.id == caregiver_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")

    caregiver.status = status.value
    db.commit()
    db.refresh(caregiver)

    # Send email notification
    if caregiver.email:
        subject = f"Account {status.value.capitalize()} - CareConnect"
        if status == VerificationStatus.VERIFIED:
            body = f"Congratulations {caregiver.name}!\n\nYour account has been verified. You can now start using the CareConnect platform.\n\nAdmin Comments: {notes if notes else 'N/A'}"
        else:
            body = f"Hello {caregiver.name},\n\nWe regret to inform you that your caregiver application has been {status.value}.\n\nAdmin Comments: {notes if notes else 'N/A'}"

        send_email(caregiver.email, subject, body)

    return caregiver

@router.patch("/caregivers/documents/{document_id}/verify", response_model=CaregiverDocumentOut)
def verify_document(
    document_id: int,
    is_verified: bool,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Verify or unverify a specific document.
    """
    doc = db.query(CaregiverDocument).filter(CaregiverDocument.id == document_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")

    doc.is_verified = is_verified
    db.commit()
    db.refresh(doc)
    return doc
