from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from app.schemas.user import UserCreate, UserOut # Import User schemas

class ElderBase(BaseModel):
    name: str
    gender: str
    date_of_birth: date
    phone: str
    email: Optional[str] = None
    address: str
    health_condition: str
    profile_image_url: Optional[str] = None

class ElderCreate(ElderBase):
    pass # Fields inherited from ElderBase

class ElderUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    health_condition: Optional[str] = None
    profile_image_url: Optional[str] = None

class FamilyLinkOut(BaseModel):
    id: int
    family_id: int
    name: str
    relationship: str
    avatarUrl: Optional[str] = None

class ElderOut(ElderBase):
    id: int
    user_id: int
    is_active: bool = True
    family_links: List[FamilyLinkOut] = []

    class Config:
        from_attributes = True

# --- Registration Specific Schemas ---

class ElderSignupRequest(BaseModel):
    user: UserCreate
    profile: ElderCreate

class ElderSignupResponse(BaseModel):
    user: UserOut
    profile: ElderOut
    message: str = "Elderly account created successfully"