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
    resolution_feedback = Column(Text)  # Official feedback visible to the reporter
    caregiver_explanation = Column(Text) # Caregiver's side of the story

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    reporter = relationship("User", foreign_keys=[reporter_id])
    caregiver = relationship("Caregiver", foreign_keys=[caregiver_id])
    notes = relationship("ComplaintNote", back_populates="complaint", cascade="all, delete-orphan")

class ComplaintNote(Base):
    __tablename__ = "complaint_notes"

    id = Column(Integer, primary_key=True, index=True)
    complaint_id = Column(Integer, ForeignKey("complaints.id"), nullable=False)
    author_name = Column(String, default="Admin")
    note = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    complaint = relationship("Complaint", back_populates="notes")
