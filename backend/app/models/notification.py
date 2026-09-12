from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    user = relationship("User", back_populates="notifications")
    
    title = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    type = Column(String)  # e.g., "binding_request", "binding_accepted", "sos_alert"
    is_read = Column(Boolean, default=False)

    # Populated for "sos_alert" notifications so the recipient can jump
    # straight to a map without another round trip — see
    # `app/api/elder.py::trigger_sos`.
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=True)
    elder_name = Column(String, nullable=True)
    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)

    # Populated for "medicine_missed" notifications — lets the missed-dose
    # job (`app/services/notification_jobs.py::check_missed_medicines`)
    # tell whether it has already notified about this exact dose.
    medicine_id = Column(Integer, ForeignKey("medicines.id", ondelete="CASCADE"), nullable=True)
    dose_time = Column(String, nullable=True)

    # Populated for "appointment_reminder" notifications, for the same
    # once-only-per-appointment reason (see
    # `check_upcoming_appointments` in the same module).
    appointment_id = Column(Integer, ForeignKey("appointments.id", ondelete="CASCADE"), nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
