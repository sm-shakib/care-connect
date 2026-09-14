from pydantic import BaseModel
from typing import List
from datetime import datetime

class AdminDashboardStats(BaseModel):
    sos_alert_count: int
    pending_verification_count: int
    open_complaint_count: int
    unread_notifications_count: int

class AdminActivityItem(BaseModel):
    id: str
    type: str
    title: str
    subtitle: str
    created_at: datetime

class AdminDashboardData(BaseModel):
    stats: AdminDashboardStats
    activities: List[AdminActivityItem]
