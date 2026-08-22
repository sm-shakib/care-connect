from datetime import date

from sqlalchemy import Column, Integer, String, Boolean, Date, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base
import enum


class MedicineForm(str, enum.Enum):
    tablet = "tablet"
    capsule = "capsule"
    syrup = "syrup"
    injection = "injection"
    other = "other"


class Medicine(Base):
    __tablename__ = "medicines"

    id = Column(Integer, primary_key=True, index=True)
    elder_id = Column(Integer, ForeignKey("elders.id"), nullable=False)

    # Identity
    name = Column(String, nullable=False)
    name_bn = Column(String, nullable=True)  # Optional Bangla name
    dosage = Column(String, nullable=False)  # e.g. "1"
    form = Column(String, default=MedicineForm.tablet.value, nullable=False)
    image_url = Column(String, nullable=True)  # Path to stored image

    # Dosage schedule
    times_per_day = Column(Integer, nullable=False, default=1)
    schedule_times = Column(ARRAY(String), nullable=False)  # e.g. ["8:00 AM", "9:00 PM"]
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)

    # Refill reminder
    refill_reminder_enabled = Column(Boolean, default=False)
    available_units = Column(Integer, default=0)
    notify_threshold = Column(Integer, default=0)

    # Doses taken "today" — raw storage only; always read via the
    # `taken_dose_times` property below, which resets this to empty once
    # `taken_on_date` is no longer today. Never read these two columns
    # directly outside of that property and the /take endpoint.
    taken_dose_times_raw = Column(ARRAY(String), nullable=False, default=list)
    taken_on_date = Column(Date, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationship back to Elder
    elder = relationship("Elder", back_populates="medicines")

    @property
    def taken_dose_times(self):
        """Schedule times already taken today, or [] once the day rolls
        over — resolved on read so nothing needs to reset this at
        midnight."""
        if self.taken_on_date != date.today():
            return []
        return self.taken_dose_times_raw or []
