from datetime import timedelta, datetime
import random
import string
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.caregiver import Caregiver
from app.models.otp import OTP
from app.core import security
from app.core.email import send_email
from app.schemas.token import Token
from app.schemas.otp import ForgotPasswordRequest, VerifyOTPRequest, ResetPasswordRequest

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

@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest, db: Session = Depends(get_db)):
    # 1. Check if user exists
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        # For security reasons, don't reveal if email exists or not
        return {"message": "If an account with that email exists, an OTP has been sent."}

    # 2. Generate 6-digit OTP
    otp_code = "".join(random.choices(string.digits, k=6))
    
    # 3. Save OTP to database
    expires_at = datetime.now() + timedelta(minutes=10)
    db_otp = OTP(email=request.email, otp=otp_code, expires_at=expires_at)
    db.add(db_otp)
    db.commit()

    # 4. Send email
    subject = "Care Connect - Password Reset OTP"
    body = f"Your OTP for resetting your password is: {otp_code}. It will expire in 10 minutes."
    email_sent = send_email(request.email, subject, body)

    if not email_sent:
        raise HTTPException(status_code=500, detail="Failed to send email")

    return {"message": "OTP sent successfully"}

@router.post("/verify-otp")
def verify_otp(request: VerifyOTPRequest, db: Session = Depends(get_db)):
    # 1. Find the latest valid OTP for this email
    db_otp = db.query(OTP).filter(
        OTP.email == request.email,
        OTP.otp == request.otp,
        OTP.expires_at > datetime.now()
    ).order_by(OTP.created_at.desc()).first()

    if not db_otp:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    return {"message": "OTP verified successfully"}

@router.post("/reset-password")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    # 1. Verify OTP again
    db_otp = db.query(OTP).filter(
        OTP.email == request.email,
        OTP.otp == request.otp,
        OTP.expires_at > datetime.now()
    ).order_by(OTP.created_at.desc()).first()

    if not db_otp:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    # 2. Update user password
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.hashed_password = security.get_password_hash(request.new_password)
    db.add(user)
    
    # 3. Delete the OTP
    db.delete(db_otp)
    
    db.commit()

    return {"message": "Password reset successfully"}
