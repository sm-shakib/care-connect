from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base

class Donation(Base):
    __tablename__ = "donations"

    id = Column(Integer, primary_key=True, index=True)
    donor_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Float, nullable=False)
    payment_method = Column(String, nullable=False)  # bkash, nagad, rocket, bank, cash
    payment_status = Column(String, default="pending")  # pending, completed, failed
    transaction_id = Column(String, unique=True, index=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    donor = relationship("User", back_populates="donations")
