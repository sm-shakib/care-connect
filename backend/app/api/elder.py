from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.models.reminder import Appointment, CareReminder
from app.schemas.elder import ElderSignupRequest, ElderSignupResponse, ElderOut, ElderUpdate
from app.schemas.reminder import AppointmentOut, AppointmentCreate, CareReminderOut, CareReminderCreate
from app.core.security import get_password_hash
from app.api.deps import get_current_user

router = APIRouter(prefix="/elders", tags=["Elderly"])

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
        if hasattr(elder, field):
            setattr(elder, field, value)
    
    db.commit()
    db.refresh(elder)
    return elder

@router.get("/appointments", response_model=List[AppointmentOut])
def get_my_appointments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    return db.query(Appointment).filter(Appointment.elder_id == elder.id).all()

@router.post("/appointments", response_model=AppointmentOut)
def create_appointment(
    payload: AppointmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    new_app = Appointment(elder_id=elder.id, **payload.model_dump())
    db.add(new_app)
    db.commit()
    db.refresh(new_app)
    return new_app

@router.get("/reminders", response_model=List[CareReminderOut])
def get_my_reminders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    return db.query(CareReminder).filter(CareReminder.elder_id == elder.id).all()

@router.post("/reminders", response_model=CareReminderOut)
def create_reminder(
    payload: CareReminderCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    new_rem = CareReminder(elder_id=elder.id, **payload.model_dump())
    db.add(new_rem)
    db.commit()
    db.refresh(new_rem)
    return new_rem
