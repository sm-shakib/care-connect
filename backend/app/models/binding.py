from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship as orm_relationship
from sqlalchemy.sql import func
from app.db.session import Base
import enum


class BindingStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"


class FamilyElderLink(Base):
    __tablename__ = "family_elder_links"

    id = Column(Integer, primary_key=True, index=True)
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False)
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=False)

    relationship = Column(String, nullable=False)  # e.g., "Father"
    status = Column(String, default="pending")

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    family = orm_relationship("Family", back_populates="elder_links")
    elder = orm_relationship("Elder", back_populates="family_links")

    @property
    def elder_name(self):
        return self.elder.name if self.elder else None

    @property
    def family_name(self):
        return self.family.name if self.family else None

    @property
    def name(self):
        return self.family_name

    @property
    def avatarUrl(self):
        return self.family.profile_image_url if self.family else None
