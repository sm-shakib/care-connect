from pydantic import BaseModel
from typing import Optional, List
from datetime import date, datetime
from enum import Enum


class MedicineForm(str, Enum):
    tablet = "tablet"
    capsule = "capsule"
    syrup = "syrup"
    injection = "injection"
    other = "other"


class MedicineBase(BaseModel):
    name: str
    name_bn: Optional[str] = None
    dosage: str
    form: MedicineForm = MedicineForm.tablet
    image_url: Optional[str] = None
    times_per_day: int = 1
    schedule_times: List[str]
    start_date: date
    end_date: date
    refill_reminder_enabled: bool = False
    available_units: int = 0
    notify_threshold: int = 0

class MedicineCreate(MedicineBase):
    pass

class MedicineUpdate(MedicineBase):
    pass

class MedicineTakeRequest(BaseModel):
    time: str  # One of the medicine's own `schedule_times` entries.

class MedicineOut(MedicineBase):
    id: int
    elder_id: int
    taken_dose_times: List[str] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
