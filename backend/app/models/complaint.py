from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base

class Complaint(Base):
    __tablename__ = "complaints"

    id = Column(Integer, primary_key=True, index=True)
    reporter_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    caregiver_id = Column(Integer, ForeignKey("caregivers.id"), nullable=False)

    category = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    status = Column(String, default="pending")  # pending, under_review, resolved, dismissed
    admin_notes = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    reporter = relationship("User", foreign_keys=[reporter_id])
    caregiver = relationship("Caregiver", foreign_keys=[caregiver_id])
