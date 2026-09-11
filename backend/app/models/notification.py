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

    created_at = Column(DateTime(timezone=True), server_default=func.now())
