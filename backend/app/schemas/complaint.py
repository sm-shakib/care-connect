from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class ComplaintNoteBase(BaseModel):
    author_name: str
    note: str

class ComplaintNoteCreate(ComplaintNoteBase):
    pass

class ComplaintNoteOut(ComplaintNoteBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class ComplaintBase(BaseModel):
    category: str
    description: str

class ComplaintCreate(ComplaintBase):
    caregiver_id: int

class ComplaintUpdate(BaseModel):
    status: Optional[str] = None
    admin_notes: Optional[str] = None
    resolution_feedback: Optional[str] = None
    caregiver_explanation: Optional[str] = None

class ComplaintOut(ComplaintBase):
    id: int
    reporter_id: int
    caregiver_id: int
    status: str
    admin_notes: Optional[str] = None # Legacy field, keeping for compatibility
    resolution_feedback: Optional[str] = None
    caregiver_explanation: Optional[str] = None
    created_at: datetime
    notes: List[ComplaintNoteOut] = []

    # Extra fields for UI convenience (populated by join or mapping)
    reporter_name: Optional[str] = None
    reporter_role: Optional[str] = None
    caregiver_name: Optional[str] = None

    class Config:
        from_attributes = True
