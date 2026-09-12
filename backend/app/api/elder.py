from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.caregiver import Caregiver
from app.models.reminder import Appointment, CareReminder
from app.models.binding import FamilyElderLink
from app.models.booking import Booking
from app.models.notification import Notification
from app.services.care_circle import get_elder_care_circle
from app.schemas.elder import ElderSignupRequest, ElderSignupResponse, ElderOut, ElderUpdate, VitalsUpdate

# ... (rest of imports)
from app.schemas.reminder import (
    AppointmentOut, AppointmentCreate, AppointmentUpdate,
    CareReminderOut, CareReminderCreate, CareReminderUpdate
)
from app.schemas.notification import NotificationOut, SosAlertRequest, SosAlertRecipient, SosAlertResponse
from app.core.security import get_password_hash
from app.api.deps import get_current_user
from app.api.chat_ws import manager

router = APIRouter(prefix="/elders", tags=["Elderly"])

def _check_elder_access(elder_id: int, db: Session, current_user: User):
    elder = db.query(Elder).filter(Elder.id == elder_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder not found")

    authorized = False
    if current_user.role == "elder" and elder.user_id == current_user.id:
        authorized = True
    elif current_user.role == "family":
        family = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family:
            link = db.query(FamilyElderLink).filter(
                FamilyElderLink.elder_id == elder.id,
                FamilyElderLink.family_id == family.id,
                FamilyElderLink.status == "accepted"
            ).first()
            if link: authorized = True
    elif current_user.role == "caregiver":
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
        if caregiver:
            booking = db.query(Booking).filter(
                Booking.elder_id == elder.id,
                Booking.caregiver_id == caregiver.id,
                Booking.status == "accepted"
            ).first()
            if booking: authorized = True

    if not authorized:
        raise HTTPException(status_code=403, detail="Not authorized")
    return elder

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

        profile_data = request.profile.model_dump()
        valid_cols = {c.key for c in Elder.__table__.columns}
        filtered_profile_data = {k: v for k, v in profile_data.items() if k in valid_cols}

        new_elder = Elder(
            user_id=new_user.id,
            **filtered_profile_data
        )
        db.add(new_elder)
        
        db.commit()
        db.refresh(new_user)
        db.refresh(new_elder)
        new_elder.email = new_user.email

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
    
    # Attach email from the user object to the response
    elder.email = current_user.email
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
    elder.email = current_user.email
    return elder

@router.post("/sos", response_model=SosAlertResponse)
async def trigger_sos(
    payload: SosAlertRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Fires an emergency SOS: shares the elder's location with every
    accepted family member and caregiver, both as a persisted
    [Notification] (so it shows up even for whoever is offline right now)
    and as a live `sos:alert` push over the same socket used for chat/calls
    (see `app/api/chat_ws.py`) for whoever is online.

    `payload.latitude`/`payload.longitude` is a fresh GPS fix taken by the
    client right as the button was pressed. When the device couldn't get
    one in time (permission denied, GPS off, no signal), they're omitted
    and this falls back to the elder's last known location already on
    file — kept current in the background by the elder app's normal
    location tracking (see `DashboardCubit._startLocationTracking`).
    """
    if current_user.role != "elder":
        raise HTTPException(status_code=403, detail="Only elders can trigger an SOS alert")

    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")

    is_live = bool(payload.latitude and payload.longitude)
    if is_live:
        elder.latitude = payload.latitude
        elder.longitude = payload.longitude
        elder.last_location_update = "Just now"
        db.commit()
        db.refresh(elder)

    location_note = "their live location" if is_live else (
        "their last known location" if elder.latitude and elder.longitude else "an alert (no location on file)"
    )

    # Everyone allowed to see this elder's location today: accepted family
    # links plus caregivers with an accepted booking — the same audiences
    # `_check_elder_access` treats as authorized elsewhere in this file.
    recipients = get_elder_care_circle(db, elder)

    pending_notifications = []
    for user_id, role, name in recipients:
        notification = Notification(
            user_id=user_id,
            title=f"\U0001F6A8 SOS Alert from {elder.name}",
            body=f"{elder.name} triggered an emergency SOS and shared {location_note}.",
            type="sos_alert",
            elder_id=elder.id,
            elder_name=elder.name,
            latitude=elder.latitude,
            longitude=elder.longitude,
        )
        db.add(notification)
        pending_notifications.append((notification, role, name))

    db.commit()

    notified: List[SosAlertRecipient] = []
    for notification, role, name in pending_notifications:
        db.refresh(notification)
        notified.append(SosAlertRecipient(user_id=notification.user_id, role=role, name=name))
        await manager.send_to_user(notification.user_id, {
            "type": "sos:alert",
            "notification": NotificationOut.model_validate(notification).model_dump(mode="json"),
        })

    return SosAlertResponse(
        elder_name=elder.name,
        latitude=elder.latitude,
        longitude=elder.longitude,
        is_live=is_live,
        notified=notified,
    )

@router.get("/appointments", response_model=List[AppointmentOut])
def get_my_appointments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")
    return db.query(Appointment).filter(Appointment.elder_id == elder.id).all()

@router.post("/appointments", response_model=AppointmentOut)
def create_appointment(
    payload: AppointmentCreate,
    elder_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if elder_id is None:
        elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
        if not elder:
            raise HTTPException(status_code=404, detail="Elder profile not found")
        target_elder_id = elder.id
    else:
        _check_elder_access(elder_id, db, current_user)
        target_elder_id = elder_id

    new_app = Appointment(elder_id=target_elder_id, **payload.model_dump())
    db.add(new_app)
    db.commit()
    db.refresh(new_app)
    return new_app

@router.put("/appointments/{appointment_id}", response_model=AppointmentOut)
def update_appointment(
    appointment_id: int,
    payload: AppointmentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    _check_elder_access(appointment.elder_id, db, current_user)
    
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(appointment, field, value)
    
    db.commit()
    db.refresh(appointment)
    return appointment

@router.delete("/appointments/{appointment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_appointment(
    appointment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    appointment = db.query(Appointment).filter(Appointment.id == appointment_id).first()
    if not appointment:
        raise HTTPException(status_code=404, detail="Appointment not found")
    
    _check_elder_access(appointment.elder_id, db, current_user)
    
    db.delete(appointment)
    db.commit()

@router.get("/reminders", response_model=List[CareReminderOut])
def get_my_reminders(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder profile not found")
    return db.query(CareReminder).filter(CareReminder.elder_id == elder.id).all()

@router.post("/reminders", response_model=CareReminderOut)
def create_reminder(
    payload: CareReminderCreate,
    elder_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if elder_id is None:
        elder = db.query(Elder).filter(Elder.user_id == current_user.id).first()
        if not elder:
            raise HTTPException(status_code=404, detail="Elder profile not found")
        target_elder_id = elder.id
    else:
        _check_elder_access(elder_id, db, current_user)
        target_elder_id = elder_id

    new_rem = CareReminder(elder_id=target_elder_id, **payload.model_dump())
    db.add(new_rem)
    db.commit()
    db.refresh(new_rem)
    return new_rem

@router.put("/reminders/{reminder_id}", response_model=CareReminderOut)
def update_care_reminder(
    reminder_id: int,
    payload: CareReminderUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    reminder = db.query(CareReminder).filter(CareReminder.id == reminder_id).first()
    if not reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    
    _check_elder_access(reminder.elder_id, db, current_user)
    
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(reminder, field, value)
    
    db.commit()
    db.refresh(reminder)
    return reminder

@router.delete("/reminders/{reminder_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_care_reminder(
    reminder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    reminder = db.query(CareReminder).filter(CareReminder.id == reminder_id).first()
    if not reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    
    _check_elder_access(reminder.elder_id, db, current_user)
    
    db.delete(reminder)
    db.commit()

@router.get("/{elder_id}", response_model=ElderOut)
def get_elder_by_id(
    elder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.id == elder_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder not found")

    # Authorization Check
    authorized = False
    
    # 1. Is it the elder themselves?
    if current_user.role == "elder" and elder.user_id == current_user.id:
        authorized = True
    
    # 2. Is it a linked family member with accepted status?
    elif current_user.role == "family":
        family = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family:
            link = db.query(FamilyElderLink).filter(
                FamilyElderLink.elder_id == elder.id,
                FamilyElderLink.family_id == family.id,
                FamilyElderLink.status == "accepted"
            ).first()
            if link:
                authorized = True
    
    # 3. Is it an assigned caregiver with accepted status?
    elif current_user.role == "caregiver":
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
        if caregiver:
            booking = db.query(Booking).filter(
                Booking.elder_id == elder.id,
                Booking.caregiver_id == caregiver.id,
                Booking.status == "accepted"
            ).first()
            if booking:
                authorized = True

    if not authorized:
        raise HTTPException(status_code=403, detail="Not authorized to view this elder's profile")

    # Attach email from the user object to the response
    elder.email = elder.user.email if elder.user else None
    return elder

@router.patch("/{elder_id}/vitals", response_model=ElderOut)
def update_vitals(
    elder_id: int,
    vitals: VitalsUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    elder = db.query(Elder).filter(Elder.id == elder_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder not found")

    # Authorization Check
    authorized = False
    
    # 1. Is it the elder themselves?
    if current_user.role == "elder" and elder.user_id == current_user.id:
        authorized = True
    
    # 2. Is it a linked family member with accepted status?
    elif current_user.role == "family":
        family = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family:
            link = db.query(FamilyElderLink).filter(
                FamilyElderLink.elder_id == elder.id,
                FamilyElderLink.family_id == family.id,
                FamilyElderLink.status == "accepted"
            ).first()
            if link:
                authorized = True

    if not authorized:
        raise HTTPException(status_code=403, detail="Not authorized to update these vitals")

    elder.heart_rate = vitals.heart_rate
    elder.systolic_bp = vitals.systolic_bp
    elder.diastolic_bp = vitals.diastolic_bp
    
    db.commit()
    db.refresh(elder)
    return elder

@router.get("/{elder_id}/appointments", response_model=List[AppointmentOut])
def get_elder_appointments(
    elder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Authorization Check (similar to get_elder_by_id)
    elder = db.query(Elder).filter(Elder.id == elder_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder not found")

    authorized = False
    if current_user.role == "elder" and elder.user_id == current_user.id:
        authorized = True
    elif current_user.role == "family":
        family = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family:
            link = db.query(FamilyElderLink).filter(FamilyElderLink.elder_id == elder.id, FamilyElderLink.family_id == family.id, FamilyElderLink.status == "accepted").first()
            if link: authorized = True
    elif current_user.role == "caregiver":
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
        if caregiver:
            booking = db.query(Booking).filter(Booking.elder_id == elder.id, Booking.caregiver_id == caregiver.id, Booking.status == "accepted").first()
            if booking: authorized = True

    if not authorized:
        raise HTTPException(status_code=403, detail="Not authorized")

    return db.query(Appointment).filter(Appointment.elder_id == elder_id).all()

@router.get("/{elder_id}/reminders", response_model=List[CareReminderOut])
def get_elder_reminders(
    elder_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Authorization Check
    elder = db.query(Elder).filter(Elder.id == elder_id).first()
    if not elder:
        raise HTTPException(status_code=404, detail="Elder not found")

    authorized = False
    if current_user.role == "elder" and elder.user_id == current_user.id:
        authorized = True
    elif current_user.role == "family":
        family = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family:
            link = db.query(FamilyElderLink).filter(FamilyElderLink.elder_id == elder.id, FamilyElderLink.family_id == family.id, FamilyElderLink.status == "accepted").first()
            if link: authorized = True
    elif current_user.role == "caregiver":
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
        if caregiver:
            booking = db.query(Booking).filter(Booking.elder_id == elder.id, Booking.caregiver_id == caregiver.id, Booking.status == "accepted").first()
            if booking: authorized = True

    if not authorized:
        raise HTTPException(status_code=403, detail="Not authorized")

    return db.query(CareReminder).filter(CareReminder.elder_id == elder_id).all()
