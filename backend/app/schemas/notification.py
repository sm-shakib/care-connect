from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

class NotificationOut(BaseModel):
    id: int
    title: str
    body: str
    type: str
    is_read: bool
    created_at: datetime
    elder_id: Optional[int] = None
    elder_name: Optional[str] = None
    latitude: Optional[str] = None
    longitude: Optional[str] = None

    class Config:
        from_attributes = True

# --- SOS alert ---

class SosAlertRequest(BaseModel):
    # A fresh GPS fix taken right as the elder pressed the button, if one
    # could be obtained in time. When omitted, `trigger_sos` falls back to
    # whatever location is already on file for the elder.
    latitude: Optional[str] = None
    longitude: Optional[str] = None

class SosAlertRecipient(BaseModel):
    user_id: int
    role: str  # "family" | "caregiver"
    name: str

class SosAlertResponse(BaseModel):
    elder_name: str
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    # True when `latitude`/`longitude` came from a fresh fix taken this
    # call; False when they're the elder's last known location instead.
    is_live: bool
    notified: List[SosAlertRecipient] = []
