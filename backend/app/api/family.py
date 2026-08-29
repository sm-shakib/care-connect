from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.family import Family
from app.schemas.family import FamilySignupRequest, FamilySignupResponse, FamilyOut, FamilyUpdate
from app.core.security import get_password_hash
from app.api.deps import get_current_user

router = APIRouter(prefix="/families", tags=["Family"])

@router.post("/signup/family", response_model=FamilySignupResponse)
def signup_family(request: FamilySignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    try:
        new_user = User(
            email=request.user.email,
            hashed_password=get_password_hash(request.user.password),
            role="family"
        )
        db.add(new_user)
        db.flush()

        new_family = Family(
            user_id=new_user.id,
            **request.profile.model_dump()
        )
        db.add(new_family)

        db.commit()
        db.refresh(new_user)
        db.refresh(new_family)

        return {
            "user": new_user,
            "profile": new_family,
            "message": "Family member account created successfully"
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Signup failed: {str(e)}")

@router.get("/me", response_model=FamilyOut)
def get_family_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "family":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only family members can access this profile",
        )
    family = db.query(Family).filter(Family.user_id == current_user.id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Family profile not found")
    
    # Attach email from the user object to the response
    family.email = current_user.email
    return family

@router.put("/me", response_model=FamilyOut)
def update_family_profile(
    payload: FamilyUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if current_user.role != "family":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")
    
    family = db.query(Family).filter(Family.user_id == current_user.id).first()
    if not family:
        raise HTTPException(status_code=404, detail="Family profile not found")
    
    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(family, field, value)
    
    db.commit()
    db.refresh(family)
    family.email = current_user.email
    return family
