from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class DonationBase(BaseModel):
    amount: float
    payment_method: str

class DonationCreate(DonationBase):
    transaction_id: Optional[str] = None

class DonationOut(DonationBase):
    id: int
    donor_id: int
    payment_status: str
    transaction_id: Optional[str] = None
    created_at: datetime
    donor_name: Optional[str] = None
    donor_image_url: Optional[str] = None
    donor_role: Optional[str] = None

    class Config:
        from_attributes = True

class DonationStats(BaseModel):
    total_amount: float
    donation_count: int
    recent_donations: List[DonationOut]
