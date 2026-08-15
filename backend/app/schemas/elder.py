from pydantic import BaseModel
from typing import Optional
from datetime import date
from app.schemas.user import UserCreate, UserOut # Import User schemas

class ElderBase(BaseModel):
    name: str
    gender: str
    date_of_birth: date
    phone: str
    address: str
    health_condition: str
    profile_image_url: Optional[str] = None

class ElderCreate(ElderBase):
    pass # Fields inherited from ElderBase

class ElderOut(ElderBase):
    id: int
    user_id: int

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