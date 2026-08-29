from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List
from datetime import timedelta
from app.db.session import get_db
from app.models.booking import Booking
from app.models.caregiver import Caregiver
from app.models.elder import Elder
from app.models.binding import FamilyElderLink
from app.schemas.booking import BookingCreate, BookingOut, BookingUpdate

router = APIRouter()

@router.post("/", response_model=BookingOut)
def create_booking(booking_in: BookingCreate, db: Session = Depends(get_db)):
    # 1. Fetch caregiver to get their fixed hourly rate
    caregiver = db.query(Caregiver).filter(Caregiver.id == booking_in.caregiver_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")

    # 2. Calculate daily duration in hours
    start_total_minutes = booking_in.daily_timing_start.hour * 60 + booking_in.daily_timing_start.minute
    end_total_minutes = booking_in.daily_timing_end.hour * 60 + booking_in.daily_timing_end.minute

    if end_total_minutes <= start_total_minutes:
        # Handle overnight bookings if necessary, for now assuming same day
        duration_hours = (end_total_minutes + 24*60 - start_total_minutes) / 60
    else:
        duration_hours = (end_total_minutes - start_total_minutes) / 60

    # 3. Count the actual number of days the caregiver will work
    # based on service dates and selected days_of_week
    work_days_list = [d.strip().lower() for d in booking_in.days_of_week.split(",")]

    # Mapping for weekday names
    day_map = {
        "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
        "friday": 4, "saturday": 5, "sunday": 6,
        "mon": 0, "tue": 1, "wed": 2, "thu": 3, "fri": 4, "sat": 5, "sun": 6
    }
    work_day_ints = [day_map[d] for d in work_days_list if d in day_map]

    total_work_days = 0
    current_date = booking_in.service_start_date
    while current_date <= booking_in.service_end_date:
        if current_date.weekday() in work_day_ints:
            total_work_days += 1
        current_date += timedelta(days=1)

    # 4. Final amount calculation
    total_amount = round(duration_hours * caregiver.hourly_rate * total_work_days, 2)

    booking_data = booking_in.model_dump()
    booking_data["total_amount"] = total_amount

    new_booking = Booking(**booking_data)
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    # Reload with relationships for the response
    return db.query(Booking).options(
        joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.id == new_booking.id).first()

@router.get("/caregiver/{caregiver_id}", response_model=List[BookingOut])
def get_caregiver_bookings(caregiver_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(
        joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.caregiver_id == caregiver_id).all()
    return bookings

@router.get("/elder/{elder_id}", response_model=List[BookingOut])
def get_elder_bookings(elder_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(
        joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.elder_id == elder_id).all()
    return bookings

@router.patch("/{booking_id}", response_model=BookingOut)
def update_booking(booking_id: int, booking_update: BookingUpdate, db: Session = Depends(get_db)):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    update_data = booking_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(booking, key, value)
    
    db.commit()
    db.refresh(booking)
    return booking
