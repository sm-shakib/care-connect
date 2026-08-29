from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from app.schemas.user import UserCreate, UserOut

class FamilyBase(BaseModel):
    name: str
    gender: str
    date_of_birth: date
    phone: str
    email: Optional[str] = None
    address: str
    profile_image_url: Optional[str] = None

class FamilyCreate(FamilyBase):
    pass

class FamilyUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    profile_image_url: Optional[str] = None

class ElderLinkOut(BaseModel):
    id: int
    elder_id: int
    name: str
    relationship: str
    avatarUrl: Optional[str] = None

class FamilyOut(FamilyBase):
    id: int
    user_id: int
    is_active: bool = True

    class Config:
        from_attributes = True

class FamilySignupRequest(BaseModel):
    user: UserCreate
    profile: FamilyCreate

class FamilySignupResponse(BaseModel):
    user: UserOut
    profile: FamilyOut
    message: str = "Family member account created successfully"
