from typing import List, Optional, Any
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.api import deps
from app.models.user import User
from app.schemas.user import UserMe, UserUpdate, UserOut
from app.core.security import get_password_hash

router = APIRouter(prefix="/users", tags=["Users"])

@router.get("/me", response_model=UserMe)
def read_user_me(
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Get current user details and their profile.
    """
    profile = None
    profile_id = None

    if current_user.role == "elder":
        profile = current_user.elder_profile
        if profile: profile_id = profile.id
    elif current_user.role == "caregiver":
        profile = current_user.caregiver_profile
        if profile: profile_id = profile.id
    elif current_user.role == "family":
        profile = current_user.family_profile
        if profile: profile_id = profile.id

    return {
        "id": current_user.id,
        "email": current_user.email,
        "role": current_user.role,
        "is_active": current_user.is_active,
        "created_at": current_user.created_at,
        "profile_id": profile_id,
        "profile": profile
    }

@router.patch("/me", response_model=UserOut)
def update_user_me(
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Update current user account (email, password).
    """
    if user_in.email:
        existing_user = db.query(User).filter(User.email == user_in.email).first()
        if existing_user and existing_user.id != current_user.id:
            raise HTTPException(status_code=400, detail="Email already registered")
        current_user.email = user_in.email

    if user_in.password:
        current_user.hashed_password = get_password_hash(user_in.password)

    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user

@router.patch("/me/profile")
def update_profile_me(
    profile_update: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Update the profile associated with the current user.
    """
    profile = None
    if current_user.role == "elder":
        profile = current_user.elder_profile
    elif current_user.role == "caregiver":
        profile = current_user.caregiver_profile
    elif current_user.role == "family":
        profile = current_user.family_profile

    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    # Update profile fields
    for field, value in profile_update.items():
        if hasattr(profile, field) and value is not None:
            setattr(profile, field, value)

    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile
