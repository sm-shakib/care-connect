from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class FundStats(BaseModel):
    balance: float
    total_donations: float
    pending_aids_count: int
    aids_distributed_no: int
    aids_distributed_amount: float
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class DonationBase(BaseModel):
    amount: float
    payment_method: str
    transaction_id: Optional[str] = None

class DonationCreate(DonationBase):
    pass

class DonationOut(DonationBase):
    id: int
    donor_id: int
    status: str
    created_at: datetime
    donor_name: Optional[str] = None
    donor_role: Optional[str] = None
    profile_image_url: Optional[str] = None

    class Config:
        from_attributes = True

class AidRequestBase(BaseModel):
    caregiver_type: str
    reason: str
    document_url: Optional[str] = None

class AidRequestCreate(AidRequestBase):
    pass

class AidRequestUpdate(BaseModel):
    status: Optional[str] = None
    approved_amount: Optional[float] = None
    admin_notes: Optional[str] = None

class AidRequestOut(AidRequestBase):
    id: int
    requester_id: int
    status: str
    approved_amount: float
    admin_notes: Optional[str] = None
    created_at: datetime
    requester_name: Optional[str] = None

    class Config:
        from_attributes = True
