from sqlalchemy import Column, Integer, String, Date, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.db.session import Base

class Family(Base):
    __tablename__ = "families"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    
    # Profile Info
    name = Column(String, nullable=False)
    gender = Column(String)
    date_of_birth = Column(Date)
    phone = Column(String)
    address = Column(Text)
    profile_image_url = Column(String, nullable=True)

    # Relationships
    user = relationship("User", back_populates="family_profile")
