from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from app.db.session import get_db
from app.api import deps
from app.models.caregiver import Caregiver, CaregiverDocument
from app.models.booking import Booking
from app.models.complaint import Complaint, ComplaintNote
from app.schemas.caregiver import CaregiverOut, CaregiverDocumentOut, VerificationStatus
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.binding import FamilyElderLink
from app.schemas.user import UserOut, UserAdminOut
from app.schemas.elder import ElderOut
from app.schemas.family import FamilyOut
from app.schemas.booking import BookingOut
from app.schemas.complaint import ComplaintOut, ComplaintUpdate, ComplaintNoteCreate

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

# --- User Management ---

@router.get("/users", response_model=List[UserAdminOut])
def list_users(
    role: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    List all users, optionally filtered by role.
    """
    query = db.query(User).options(
        joinedload(User.elder_profile),
        joinedload(User.caregiver_profile),
        joinedload(User.family_profile)
    )
    if role:
        query = query.filter(User.role == role)

    users = query.all()
    results = []
    for user in users:
        user_data = {
            "id": user.id,
            "email": user.email,
            "role": user.role,
            "is_active": user.is_active,
            "created_at": user.created_at
        }

        profile = None
        if user.role == "elder":
            profile = user.elder_profile
        elif user.role == "caregiver":
            profile = user.caregiver_profile
        elif user.role == "family":
            profile = user.family_profile

        if profile:
            user_data["name"] = profile.name
            user_data["phone"] = profile.phone
            user_data["profile_image_url"] = profile.profile_image_url

        results.append(user_data)

    return results

@router.get("/users/{user_id}", response_model=UserOut)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Get detailed view of a user account.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.patch("/users/{user_id}/status", response_model=UserOut)
def update_user_status(
    user_id: int,
    is_active: bool,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Activate or deactivate a user account.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.is_active = is_active
    db.commit()
    db.refresh(user)
    return user

@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Delete a user account and all associated profiles.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

# --- Specific Profile Details for Admin ---

@router.get("/elders/user/{user_id}", response_model=ElderOut)
def get_elder_detail_by_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    elder = db.query(Elder).options(joinedload(Elder.family_links).joinedload(FamilyElderLink.family)).filter(Elder.user_id == user_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")

    # Map family links to the expected output format
    links = []
    for link in elder.family_links:
        links.append({
            "id": link.id,
            "family_id": link.family_id,
            "name": link.family.name,
            "relationship": link.relationship,
            "avatarUrl": link.family.profile_image_url
        })

    return {
        "id": elder.id,
        "user_id": elder.user_id,
        "name": elder.name,
        "gender": elder.gender,
        "date_of_birth": elder.date_of_birth,
        "phone": elder.phone,
        "email": elder.user.email if elder.user else None,
        "address": elder.address,
        "health_condition": elder.health_condition,
        "profile_image_url": elder.profile_image_url,
        "is_active": elder.user.is_active if elder.user else True,
        "family_links": links
    }

@router.get("/families/user/{user_id}", response_model=FamilyOut)
def get_family_detail_by_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    family = db.query(Family).options(joinedload(Family.elder_links).joinedload(FamilyElderLink.elder)).filter(Family.user_id == user_id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Family profile not found")

    links = []
    for link in family.elder_links:
        links.append({
            "id": link.id,
            "elder_id": link.elder_id,
            "name": link.elder.name,
            "relationship": link.relationship,
            "avatarUrl": link.elder.profile_image_url
        })

    return {
        "id": family.id,
        "user_id": family.user_id,
        "name": family.name,
        "gender": family.gender,
        "date_of_birth": family.date_of_birth,
        "phone": family.phone,
        "email": family.user.email if family.user else None,
        "address": family.address,
        "profile_image_url": family.profile_image_url,
        "is_active": family.user.is_active if family.user else True,
        "elder_links": links
    }

@router.get("/caregivers/user/{user_id}", response_model=CaregiverOut)
def get_caregiver_detail_by_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    caregiver = db.query(Caregiver).options(joinedload(Caregiver.user), joinedload(Caregiver.documents)).filter(Caregiver.user_id == user_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")

    # Map documents to expected format
    docs = []
    for doc in caregiver.documents:
        docs.append({
            "id": doc.id,
            "document_type": doc.document_type,
            "document_url": doc.document_url,
            "is_verified": doc.is_verified
        })

    return {
        "id": caregiver.id,
        "user_id": caregiver.user_id,
        "name": caregiver.name,
        "gender": caregiver.gender,
        "date_of_birth": caregiver.date_of_birth,
        "phone": caregiver.phone,
        "address": caregiver.address,
        "profile_image_url": caregiver.profile_image_url,
        "specializations": caregiver.specializations,
        "availability_type": caregiver.availability_type,
        "hourly_rate": caregiver.hourly_rate,
        "experience_years": caregiver.experience_years,
        "status": caregiver.status,
        "rating": caregiver.rating,
        "review_count": caregiver.review_count,
        "email": caregiver.user.email if caregiver.user else "",
        "is_active": caregiver.user.is_active if caregiver.user else True,
        "documents": docs
    }

# --- Booking Management ---

@router.get("/bookings", response_model=List[BookingOut])
def list_bookings(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    List all bookings, optionally filtered by status.
    """
    query = db.query(Booking).options(
        joinedload(Booking.elder),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    )
    if status:
        query = query.filter(Booking.status == status)
    return query.all()

@router.get("/bookings/{booking_id}", response_model=BookingOut)
def get_booking_detail(
    booking_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Get detailed view of a booking.
    """
    booking = db.query(Booking).options(
        joinedload(Booking.elder),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.id == booking_id).first()

    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return booking

# --- Complaint Management ---

@router.get("/complaints", response_model=List[ComplaintOut])
def list_complaints(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    List all complaints, optionally filtered by status.
    """
    query = db.query(Complaint).options(
        joinedload(Complaint.reporter).joinedload(User.elder_profile),
        joinedload(Complaint.reporter).joinedload(User.family_profile),
        joinedload(Complaint.caregiver),
        joinedload(Complaint.notes)
    )
    if status:
        query = query.filter(Complaint.status == status)

    complaints = query.all()

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
            "caregiver_id": c.caregiver.user_id, # Return user_id for profile lookup
            "category": c.category,
            "description": c.description,
            "status": c.status,
            "admin_notes": c.admin_notes,
            "resolution_feedback": c.resolution_feedback,
            "caregiver_explanation": c.caregiver_explanation,
            "created_at": c.created_at,
            "reporter_name": reporter_name,
            "reporter_role": c.reporter.role,
            "caregiver_name": c.caregiver.name,
            "notes": c.notes
        })
    return results

@router.get("/complaints/{complaint_id}", response_model=ComplaintOut)
def get_complaint_detail(
    complaint_id: int,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Get detailed view of a complaint.
    """
    c = db.query(Complaint).options(
        joinedload(Complaint.reporter).joinedload(User.elder_profile),
        joinedload(Complaint.reporter).joinedload(User.family_profile),
        joinedload(Complaint.caregiver),
        joinedload(Complaint.notes)
    ).filter(Complaint.id == complaint_id).first()

    if not c:
        raise HTTPException(status_code=404, detail="Complaint not found")

    reporter_name = c.reporter.email
    if c.reporter.role == "elder" and c.reporter.elder_profile:
        reporter_name = c.reporter.elder_profile.name
    elif c.reporter.role == "family" and c.reporter.family_profile:
        reporter_name = c.reporter.family_profile.name

    return {
        "id": c.id,
        "reporter_id": c.reporter_id,
        "caregiver_id": c.caregiver.user_id, # Return user_id for profile lookup
        "category": c.category,
        "description": c.description,
        "status": c.status,
        "admin_notes": c.admin_notes,
        "resolution_feedback": c.resolution_feedback,
        "caregiver_explanation": c.caregiver_explanation,
        "created_at": c.created_at,
        "reporter_name": reporter_name,
        "reporter_role": c.reporter.role,
        "caregiver_name": c.caregiver.name,
        "notes": c.notes
    }

@router.patch("/complaints/{complaint_id}", response_model=ComplaintOut)
def update_complaint(
    complaint_id: int,
    complaint_in: ComplaintUpdate,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Update complaint status or add admin notes.
    """
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")

    update_data = complaint_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(complaint, field, value)

    db.commit()

    # Reload with all relationships
    return get_complaint_detail(complaint_id, db, current_admin)

@router.post("/complaints/{complaint_id}/notes", response_model=ComplaintOut)
def add_complaint_note(
    complaint_id: int,
    note_in: ComplaintNoteCreate,
    db: Session = Depends(get_db),
    current_admin = Depends(deps.get_current_admin)
):
    """
    Add an internal note to a complaint.
    """
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")

    new_note = ComplaintNote(
        complaint_id=complaint.id,
        author_name=note_in.author_name,
        note=note_in.note
    )
    db.add(new_note)

    # Auto-update status to under_review if currently pending
    if complaint.status == "pending":
        complaint.status = "under_review"

    db.commit()

    # Reload with all relationships
    return get_complaint_detail(complaint_id, db, current_admin)
