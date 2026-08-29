from sqlalchemy import Column, Integer, String, Date, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.db.session import Base

class Elder(Base):
    __tablename__ = "elders"

    id = Column(Integer, primary_key=True, index=True)
    # Link to the authentication User record
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    # Profile Info
    name = Column(String, nullable=False)
    gender = Column(String)  # "Male", "Female", "Other"
    date_of_birth = Column(Date)
    phone = Column(String)
    address = Column(Text)
    profile_image_url = Column(String, nullable=True) # Path to stored image

    # Health Info
    health_condition = Column(Text)
    heart_rate = Column(Integer, default=75)
    systolic_bp = Column(Integer, default=120)
    diastolic_bp = Column(Integer, default=80)
    
    # Location Info
    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)
    last_location_update = Column(String, nullable=True)

    # Relationship back to User
    user = relationship("User", back_populates="elder_profile")
    family_links = relationship("FamilyElderLink", back_populates="elder")
    medicines = relationship("Medicine", back_populates="elder")
    appointments = relationship("Appointment", back_populates="elder")
    reminders = relationship("CareReminder", back_populates="elder")
