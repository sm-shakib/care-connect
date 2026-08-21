from pydantic import BaseModel
from typing import Optional
from datetime import date
from app.schemas.user import UserCreate, UserOut

class FamilyBase(BaseModel):
    name: str
    gender: str
    date_of_birth: date
    phone: str
    address: str
    profile_image_url: Optional[str] = None

class FamilyCreate(FamilyBase):
    pass

class FamilyOut(FamilyBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class FamilySignupRequest(BaseModel):
    user: UserCreate
    profile: FamilyCreate

class FamilySignupResponse(BaseModel):
    user: UserOut
    profile: FamilyOut
    message: str = "Family member account created successfully"
