from sqlalchemy import Column, Integer, String, Date, ForeignKey, Text, Boolean, Float
from sqlalchemy.orm import relationship
from app.db.session import Base

class Caregiver(Base):
    __tablename__ = "caregivers"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    
    # Profile Info
    name = Column(String, nullable=False)
    gender = Column(String)
    date_of_birth = Column(Date)
    phone = Column(String)
    address = Column(Text)
    profile_image_url = Column(String, nullable=True)
    
    # Professional Info
    specializations = Column(Text)
    availability_type = Column(String)  # fullTime, partTime, onCall, weekendsOnly
    daily_rate = Column(Float)
    experience_years = Column(Integer)
    is_verified = Column(Boolean, default=False)

    # Relationships
    user = relationship("User", back_populates="caregiver_profile")
    documents = relationship("CaregiverDocument", back_populates="caregiver")

class CaregiverDocument(Base):
    __tablename__ = "caregiver_documents"

    id = Column(Integer, primary_key=True, index=True)
    caregiver_id = Column(Integer, ForeignKey("caregivers.id"), nullable=False)
    document_type = Column(String, nullable=False)  # nationalId, certificate, policeClearance
    document_url = Column(String, nullable=False)

    caregiver = relationship("Caregiver", back_populates="documents")
