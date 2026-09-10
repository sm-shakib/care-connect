from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.session import Base

class FundSummary(Base):
    __tablename__ = "fund_summary"

    id = Column(Integer, primary_key=True, index=True)
    balance = Column(Float, default=0.0)
    total_donations = Column(Float, default=0.0)
    pending_aids_count = Column(Integer, default=0)
    aids_distributed_no = Column(Integer, default=0)
    aids_distributed_amount = Column(Float, default=0.0)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class Donation(Base):
    __tablename__ = "donations"

    id = Column(Integer, primary_key=True, index=True)
    donor_id = Column(Integer, ForeignKey("users.id"))
    amount = Column(Float, nullable=False)
    payment_method = Column(String)  # bkash, nagad, rocket, bank, cash
    transaction_id = Column(String, unique=True, index=True)
    status = Column(String, default="pending")  # pending, completed, failed
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    donor = relationship("User")

class AidRequest(Base):
    __tablename__ = "aid_requests"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("users.id"))
    caregiver_type = Column(String)
    reason = Column(Text)
    document_url = Column(String)
    status = Column(String, default="pending")  # pending, approved, rejected, disbursed
    approved_amount = Column(Float, default=0.0)
    admin_notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    requester = relationship("User")
