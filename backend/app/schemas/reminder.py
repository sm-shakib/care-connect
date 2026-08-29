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

class CareReminderOut(CareReminderBase):
    id: int
    elder_id: int
    created_at: datetime

    class Config:
        from_attributes = True
