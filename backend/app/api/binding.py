from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.models.binding import FamilyElderLink, BindingStatus
from app.models.elder import Elder
from app.models.user import User
from app.models.family import Family
from app.models.notification import Notification
from app.models.booking import Booking
from app.schemas.binding import BindingCreate, BindingOut, BindingUpdate, FamilyMemberOut
from app.api.deps import get_current_user

router = APIRouter(prefix="/bindings", tags=["Bindings"])

@router.post("/request", response_model=BindingOut)
def create_binding_request(
    request: BindingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "family":
        raise HTTPException(status_code=403, detail="Only family members can send binding requests")
    
    family = db.query(Family).filter(Family.user_id == current_user.id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Sender family profile not found")

    user = db.query(User).filter(User.email == request.elder_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="Elder with this email not found")

    elder = db.query(Elder).filter(Elder.user_id == user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="No elderly profile found for this email")

    existing = db.query(FamilyElderLink).filter(
        FamilyElderLink.family_id == family.id,
        FamilyElderLink.elder_id == elder.id
    ).first()

    if existing:
        raise HTTPException(status_code=400, detail="Binding request already exists or is active")

    new_link = FamilyElderLink(
        family_id=family.id,
        elder_id=elder.id,
        relationship=request.relationship,
        status=BindingStatus.pending
    )

    db.add(new_link)
    db.commit()
    db.refresh(new_link)
    return new_link

@router.put("/{binding_id}/respond", response_model=BindingOut)
def respond_to_binding(
    binding_id: int,
    update: BindingUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    binding = db.query(FamilyElderLink).filter(FamilyElderLink.id == binding_id).first()
    if not binding:
        raise HTTPException(status_code=404, detail="Binding request not found")
    
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder or binding.elder_id != elder.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    binding.status = update.status
    
    # NEW: If accepted, create a notification for the Family member
    if update.status == BindingStatus.accepted:
        family = db.query(Family).filter(Family.id == binding.family_id).first()
        if family:
            notification = Notification(
                user_id=family.user_id,
                title="New Request Accepted",
                body=f"{elder.name} has accepted your binding request as their {binding.relationship}.",
                type="binding_accepted"
            )
            db.add(notification)
            
    db.commit()
    db.refresh(binding)
    return binding

@router.get("/pending/me", response_model=List[BindingOut])
def get_my_pending_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "elder":
        raise HTTPException(status_code=403, detail="Only elders can view requests")
    
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    return db.query(FamilyElderLink).filter(
        FamilyElderLink.elder_id == elder.id,
        FamilyElderLink.status == BindingStatus.pending
    ).all()

@router.get("/family/members", response_model=List[FamilyMemberOut])
def get_my_family_members(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    family = db.query(Family).filter(Family.user_id == current_user.id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Family profile not found")
    
    links = db.query(FamilyElderLink).filter(
        FamilyElderLink.family_id == family.id,
        FamilyElderLink.status == BindingStatus.accepted
    ).all()

    results = []
    for link in links:
        elder = link.elder
        
        # Fetch accepted caregivers for this elder
        bookings = db.query(Booking).filter(
            Booking.elder_id == elder.id,
            Booking.status == "accepted"
        ).all()
        caregiver_names = [b.caregiver.name for b in bookings if b.caregiver]

        results.append({
            "relationship": link.relationship,
            "elder": elder,
            "medications": elder.medicines if elder else [],
            "appointments": elder.appointments if elder else [],
            "reminders": elder.reminders if elder else [],
            "caregiver_names": caregiver_names
        })
    
    return results
