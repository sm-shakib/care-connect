from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date, time

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
    caregiver_type: Optional[str] = None
    reason: str
    service_start_date: Optional[date] = None
    service_end_date: Optional[date] = None
    days_of_week: Optional[str] = None
    daily_timing_start: Optional[time] = None
    daily_timing_end: Optional[time] = None
    document_url: Optional[str] = None

class AidRequestCreate(AidRequestBase):
    # Required when a family member submits on an elder's behalf; ignored
    # (auto-filled from the caller's own profile) when an elder submits
    # directly. See app/api/fund.py::request_aid.
    elder_id: Optional[int] = None

class AidRequestUpdate(BaseModel):
    status: Optional[str] = None
    approved_amount: Optional[float] = None
    admin_notes: Optional[str] = None

class AidRequestOut(AidRequestBase):
    id: int
    requester_id: int
    elder_id: Optional[int] = None
    status: str
    approved_amount: float
    admin_notes: Optional[str] = None
    created_at: datetime
    requester_name: Optional[str] = None

    class Config:
        from_attributes = True

class EligibleCaregiverOut(BaseModel):
    """A caregiver matched to an approved aid request's care type, with the
    exact cost of covering that request's fixed schedule at their rate."""
    caregiver_id: int
    name: str
    specializations: Optional[str] = None
    hourly_rate: float
    rating: Optional[float] = None
    estimated_cost: float
    within_budget: bool

class BookCaregiverIn(BaseModel):
    caregiver_id: int
