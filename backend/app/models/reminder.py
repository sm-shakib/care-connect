from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base

class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(Integer, primary_key=True, index=True)
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=False)

    doctor_name = Column(String, nullable=False)
    specialty = Column(String)
    appointment_date = Column(String) 
    appointment_time = Column(String) 
    location = Column(String)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    elder = relationship("Elder", back_populates="appointments")

class CareReminder(Base):
    __tablename__ = "care_reminders"

    id = Column(Integer, primary_key=True, index=True)
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=False)

    title = Column(String, nullable=False)
    subtitle = Column(String)
    icon_name = Column(String) 

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    elder = relationship("Elder", back_populates="reminders")
