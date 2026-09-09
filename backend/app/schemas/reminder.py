from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class AppointmentBase(BaseModel):
    doctor_name: str
    specialty: Optional[str] = None
    appointment_date: str
    appointment_time: str
    location: Optional[str] = None

class AppointmentCreate(AppointmentBase):
    pass

class AppointmentUpdate(BaseModel):
    doctor_name: Optional[str] = None
    specialty: Optional[str] = None
    appointment_date: Optional[str] = None
    appointment_time: Optional[str] = None
    location: Optional[str] = None

class AppointmentOut(AppointmentBase):
    id: int
    elder_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class CareReminderBase(BaseModel):
    title: str
    subtitle: Optional[str] = None
    icon_name: Optional[str] = None

class CareReminderCreate(CareReminderBase):
    pass

class CareReminderUpdate(BaseModel):
    title: Optional[str] = None
    subtitle: Optional[str] = None
    icon_name: Optional[str] = None

class CareReminderOut(CareReminderBase):
    id: int
    elder_id: int
    created_at: datetime

    class Config:
        from_attributes = True
