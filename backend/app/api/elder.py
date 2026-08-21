from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.schemas.elder import ElderSignupRequest, ElderSignupResponse
from app.core.security import get_password_hash

router = APIRouter()

@router.post("/signup/elder", response_model=ElderSignupResponse)
def signup_elder(request: ElderSignupRequest, db: Session = Depends(get_db)):
    # 1. Check for existing user
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    # 2. Create User (Account) with dynamic role and is_active
    new_user = User(
        email=request.user.email,
        hashed_password=get_password_hash(request.user.password),
        role=request.user.role,       # Dynamically assigned from frontend
        is_active=request.user.is_active
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 3. Create Elder (Profile)
    new_elder = Elder(
        user_id=new_user.id,
        **request.profile.model_dump()
    )
    db.add(new_elder)
    db.commit()
    db.refresh(new_elder)

    return {
        "user": new_user,
        "profile": new_elder
    }