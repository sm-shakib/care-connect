from pydantic import BaseModel
from typing import Optional, List
from datetime import date
from enum import Enum
from app.schemas.user import UserCreate, UserOut

class VerificationStatus(str, Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REJECTED = "rejected"

class CaregiverDocumentBase(BaseModel):
    document_type: str
    document_url: str

class CaregiverDocumentCreate(CaregiverDocumentBase):
    pass

class CaregiverDocumentOut(CaregiverDocumentBase):
    id: int
    is_verified: bool

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
    hourly_rate: float
    experience_years: int

class CaregiverCreate(CaregiverBase):
    pass

class CaregiverUpdate(BaseModel):
    name: Optional[str] = None
    gender: Optional[str] = None
    date_of_birth: Optional[date] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    profile_image_url: Optional[str] = None
    specializations: Optional[str] = None
    availability_type: Optional[str] = None
    hourly_rate: Optional[float] = None
    experience_years: Optional[int] = None

class CaregiverOut(CaregiverBase):
    id: int
    user_id: int
    email: str
    is_active: bool = True
    status: VerificationStatus
    rating: float
    review_count: int
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
