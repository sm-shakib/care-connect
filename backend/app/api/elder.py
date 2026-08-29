from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.schemas.elder import ElderSignupRequest, ElderSignupResponse, ElderOut, ElderUpdate
from app.core.security import get_password_hash
from app.api.deps import get_current_user

router = APIRouter()

@router.post("/signup/elder", response_model=ElderSignupResponse)
def signup_elder(request: ElderSignupRequest, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == request.user.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    try:
        new_user = User(
            email=request.user.email,
            hashed_password=get_password_hash(request.user.password),
            role=request.user.role,       
            is_active=request.user.is_active
        )
        db.add(new_user)
        db.flush()

        new_elder = Elder(
            user_id=new_user.id,
            **request.profile.model_dump()
        )
        db.add(new_elder)
        
        db.commit()
        db.refresh(new_user)
        db.refresh(new_elder)

        return {
            "user": new_user,
            "profile": new_elder,
            "message": "Elderly account created successfully"
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Signup failed: {str(e)}")

@router.get("/me", response_model=ElderOut)
def get_elder_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")
    return elder

@router.put("/me", response_model=ElderOut)
def update_elder_profile(
    payload: ElderUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")
    
    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(elder, field, value)
    
    db.commit()
    db.refresh(elder)
    return elder
