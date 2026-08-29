from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey, Text, DateTime
from sqlalchemy.orm import relationship
from app.db.session import Base
from datetime import datetime, timezone

class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=False)
    caregiver_id = Column(Integer, ForeignKey("caregivers.id"), nullable=False)
    
    service_start_date = Column(Date, nullable=False)
    service_end_date = Column(Date, nullable=False)
    days_of_week = Column(String, nullable=False)  # e.g., "Mon,Tue,Wed"
    daily_timing_start = Column(Time, nullable=False)
    daily_timing_end = Column(Time, nullable=False)
    
    booking_reason = Column(Text)
    status = Column(String, default="pending")  # pending, accepted, rejected, cancelled
    payment_status = Column(String, default="pending")  # pending, paid
    requested_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))

    # Relationships
    elder = relationship("Elder")
    caregiver = relationship("Caregiver")
