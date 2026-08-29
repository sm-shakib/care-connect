from pydantic import BaseModel, EmailStr
from typing import Optional, Any
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    role: str = "user"  # Frontend will send "elder", "caregiver", etc.
    is_active: bool = True # Defaulting to True

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None

class UserOut(UserBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class UserAdminOut(UserOut):
    name: Optional[str] = None
    phone: Optional[str] = None
    profile_image_url: Optional[str] = None

class UserMe(UserOut):
    profile_id: Optional[int] = None
    profile: Optional[Any] = None
