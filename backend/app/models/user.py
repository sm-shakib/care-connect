from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.session import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, default="user")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # uselist=False ensures the 1-to-1 relationship
    elder_profile = relationship("Elder", back_populates="user", uselist=False, cascade="all, delete-orphan")
    caregiver_profile = relationship("Caregiver", back_populates="user", uselist=False, cascade="all, delete-orphan")
    family_profile = relationship("Family", back_populates="user", uselist=False, cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    reported_complaints = relationship("Complaint", back_populates="reporter", cascade="all, delete-orphan")
    chat_participations = relationship("ConversationParticipant", back_populates="user", cascade="all, delete-orphan")
    sent_messages = relationship("Message", back_populates="sender", cascade="all, delete-orphan")
