from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum

from app.schemas.elder import ElderOut
from app.schemas.medicine import MedicineOut
from app.schemas.reminder import AppointmentOut, CareReminderOut

class BindingStatus(str, Enum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"

class BindingBase(BaseModel):
    elder_email: str
    relationship: str

class BindingCreate(BindingBase):
    pass

class BindingUpdate(BaseModel):
    status: BindingStatus

class BindingOut(BaseModel):
    id: int
    family_id: int
    elder_id: int
    relationship: str
    status: BindingStatus
    created_at: datetime
    updated_at: Optional[datetime] = None
    elder_name: Optional[str] = None
    family_name: Optional[str] = None

    class Config:
        from_attributes = True

class FamilyMemberOut(BaseModel):
    relationship: str
    elder: ElderOut
    medications: List[MedicineOut] = []
    appointments: List[AppointmentOut] = []
    reminders: List[CareReminderOut] = []
    caregiver_names: List[str] = []
    caregiver_details: List[dict] = []  # List of {"id": int, "name": str}

    class Config:
        from_attributes = True
