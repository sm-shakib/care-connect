from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from app.schemas.user import UserCreate, UserOut

class CaregiverDocumentBase(BaseModel):
    document_type: str
    document_url: str

class CaregiverDocumentCreate(CaregiverDocumentBase):
    pass

class CaregiverDocumentOut(CaregiverDocumentBase):
    id: int

    class Config:
        from_attributes = True

class CaregiverBase(BaseModel):
    name: str
    gender: str
    date_of_birth: date
    phone: str
    address: str
    profile_image_url: Optional[str] = None
    specializations: str
    availability_type: str
    daily_rate: float
    experience_years: int

class CaregiverCreate(CaregiverBase):
    pass

class CaregiverOut(CaregiverBase):
    id: int
    user_id: int
    is_verified: bool
    documents: List[CaregiverDocumentOut] = []

    class Config:
        from_attributes = True

class CaregiverSignupRequest(BaseModel):
    user: UserCreate
    profile: CaregiverCreate
    documents: List[CaregiverDocumentCreate]

class CaregiverSignupResponse(BaseModel):
    user: UserOut
    profile: CaregiverOut
    message: str = "Caregiver account created successfully"
