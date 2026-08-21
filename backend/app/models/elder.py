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

    # Relationship back to User
    user = relationship("User", back_populates="elder_profile")