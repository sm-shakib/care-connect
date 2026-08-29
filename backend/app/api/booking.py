from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.db.session import get_db
from app.models.booking import Booking
from app.models.caregiver import Caregiver
from app.schemas.booking import BookingCreate, BookingOut, BookingUpdate

router = APIRouter()

@router.post("/", response_model=BookingOut)
def create_booking(booking_in: BookingCreate, db: Session = Depends(get_db)):
    new_booking = Booking(**booking_in.model_dump())
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    # Reload with relationships for the response
    return db.query(Booking).options(
        joinedload(Booking.elder),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.id == new_booking.id).first()

@router.get("/caregiver/{caregiver_id}", response_model=List[BookingOut])
def get_caregiver_bookings(caregiver_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(joinedload(Booking.elder)).filter(Booking.caregiver_id == caregiver_id).all()
    return bookings

@router.get("/elder/{elder_id}", response_model=List[BookingOut])
def get_elder_bookings(elder_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(
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
