from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text, Date, Time
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.session import Base

class FundSummary(Base):
    __tablename__ = "fund_summary"

    id = Column(Integer, primary_key=True, index=True)
    # New: Link to the transaction that triggered this summary update
    donation_id = Column(Integer, ForeignKey("donations.id", ondelete="CASCADE"), nullable=True)
    aid_request_id = Column(Integer, ForeignKey("aid_requests.id", ondelete="CASCADE"), nullable=True)

    balance = Column(Float, default=0.0)
    total_donations = Column(Float, default=0.0)
    pending_aids_count = Column(Integer, default=0)
    aids_distributed_no = Column(Integer, default=0)
    aids_distributed_amount = Column(Float, default=0.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    donation = relationship("Donation")
    aid_request = relationship("AidRequest")

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
    caregiver_type = Column(String, nullable=True)
    reason = Column(Text)
    
    # New Fields for Service Details
    service_start_date = Column(Date, nullable=True)
    service_end_date = Column(Date, nullable=True)
    days_of_week = Column(String, nullable=True)
    daily_timing_start = Column(Time, nullable=True)
    daily_timing_end = Column(Time, nullable=True)
    
    document_url = Column(String)
    status = Column(String, default="pending")  # pending, approved, rejected, disbursed
    approved_amount = Column(Float, default=0.0)
    admin_notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    requester = relationship("User")
