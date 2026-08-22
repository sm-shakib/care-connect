from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.family import Family
from app.schemas.family import FamilySignupRequest, FamilySignupResponse
from app.core.security import get_password_hash

router = APIRouter()

@router.post("/signup/family", response_model=FamilySignupResponse)
def signup_family(request: FamilySignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

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
        "profile": new_family
    }
