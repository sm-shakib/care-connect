from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.models.binding import FamilyElderLink, BindingStatus
from app.models.elder import Elder
from app.models.user import User
from app.models.family import Family
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only family members can send binding requests"
        )
    
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
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Binding request already exists or is active"
        )

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

@router.get("/pending/me", response_model=List[BindingOut])
def get_my_pending_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "elder":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only elders can view their pending requests"
        )
    
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")

    return db.query(FamilyElderLink).filter(
        FamilyElderLink.elder_id == elder.id,
        FamilyElderLink.status == BindingStatus.pending
    ).all()

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
    
    # Verify the current user is the elder this request was sent to
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder or binding.elder_id != elder.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Not authorized to respond to this request"
        )

    binding.status = update.status
    db.commit()
    db.refresh(binding)
    return binding

@router.get("/family/members", response_model=List[FamilyMemberOut])
def get_my_family_members(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Only family members can view their links"
        )
    
    family = db.query(Family).filter(Family.user_id == current_user.id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Family profile not found")

    return db.query(FamilyElderLink).filter(
        FamilyElderLink.family_id == family.id,
        FamilyElderLink.status == BindingStatus.accepted
    ).all()
