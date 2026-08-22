from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.caregiver import Caregiver
from app.core import security
from app.schemas.token import Token

router = APIRouter()

@router.post("/login", response_model=Token)
def login(db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()):
    # 1. Find user by email (OAuth2PasswordRequestForm uses 'username' field for email)
    user = db.query(User).filter(User.email == form_data.username).first()

    # 2. Verify user exists and password is correct
    if not user or not security.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 3. Check if user is active
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")

    # 4. Determine profile ID and status based on role
    profile_id = None
    status_val = None

    if user.role == "elder":
        elder = db.query(Elder).filter(Elder.user_id == user.id).first()
        if elder:
            profile_id = elder.id
    elif user.role == "family":
        family = db.query(Family).filter(Family.user_id == user.id).first()
        if family:
            profile_id = family.id
    elif user.role == "caregiver":
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == user.id).first()
        if caregiver:
            profile_id = caregiver.id
            status_val = caregiver.status

    # 5. Create Access Token
    access_token_expires = timedelta(minutes=security.settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
        "role": user.role,
        "user_id": user.id,
        "profile_id": profile_id,
        "status": status_val
    }