from pydantic import BaseModel
from typing import Optional
from datetime import date, time, datetime
from app.schemas.elder import ElderOut
from app.schemas.caregiver import CaregiverOut

class BookingBase(BaseModel):
    service_start_date: date
    service_end_date: date
    days_of_week: str
    daily_timing_start: time
    daily_timing_end: time
    booking_reason: Optional[str] = None

class BookingCreate(BookingBase):
    elder_id: int
    caregiver_id: int

class BookingUpdate(BaseModel):
    status: Optional[str] = None
    payment_status: Optional[str] = None

class BookingOut(BookingBase):
    id: int
    elder_id: int
    caregiver_id: int
    status: str
    payment_status: str
    requested_at: datetime
    elder: Optional[ElderOut] = None
    caregiver: Optional[CaregiverOut] = None

    class Config:
        from_attributes = True
