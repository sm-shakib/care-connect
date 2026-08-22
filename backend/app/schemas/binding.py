from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

from app.schemas.elder import ElderOut

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

    class Config:
        from_attributes = True
