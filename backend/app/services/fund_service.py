"""Shared fund/aid-request bookkeeping.

Lives outside app/api so both app/api/fund.py (admin review, family
caregiver booking) and app/api/booking.py (caregiver accept/reject of an
aid-funded booking) can drive the same balance/snapshot logic without
importing one API router from another.

Fund movement for the caregiver-assignment path is a reserve/release/
finalize cycle, not a single deduction:

  approved (money promised, nothing moved)
      -> book-caregiver: reserve_aid_amount()   balance -= approved_amount
      -> caregiver accepts: finalize_aid_disbursement(actual_amount)
             balance += (approved_amount - actual_amount)   # refund unused
      -> caregiver rejects: release_aid_reservation()
             balance += approved_amount                      # full refund

This means the fund balance always reflects money that is either spent or
free to reserve elsewhere -- a second aid request can't be approved and
assigned against money a first, still-pending assignment already claimed,
and an elder who ends up costing less than the approved ceiling returns
the difference to the pool instead of it vanishing into "distributed".
"""
from sqlalchemy.orm import Session

from app.models.fund import FundSummary, AidRequest


class InsufficientFundsError(Exception):
    def __init__(self, available: float):
        self.available = available
        super().__init__(f"Insufficient fund balance: {available}")


def get_latest_fund_summary(db: Session) -> FundSummary:
    """Fetch the most recent summary record, creating a zeroed one if none exists."""
    summary = db.query(FundSummary).order_by(FundSummary.id.desc()).first()
    if not summary:
        summary = FundSummary(
            balance=0.0,
            total_donations=0.0,
            pending_aids_count=0,
            aids_distributed_no=0,
            aids_distributed_amount=0.0,
        )
        db.add(summary)
        db.flush()
    return summary


def reserve_aid_amount(db: Session, aid_request: AidRequest) -> None:
    """Take `aid_request.approved_amount` out of the balance the moment a
    family commits to a specific caregiver, so it can't be double-spent by
    another approved request while this one still waits on the caregiver's
    decision. Raises InsufficientFundsError if the pool can't cover it.
    """
    prev = get_latest_fund_summary(db)
    if prev.balance < aid_request.approved_amount:
        raise InsufficientFundsError(prev.balance)

    db.add(FundSummary(
        aid_request_id=aid_request.id,
        balance=prev.balance - aid_request.approved_amount,
        total_donations=prev.total_donations,
        pending_aids_count=prev.pending_aids_count,
        aids_distributed_no=prev.aids_distributed_no,
        aids_distributed_amount=prev.aids_distributed_amount,
    ))


def release_aid_reservation(db: Session, aid_request: AidRequest) -> None:
    """Caregiver declined before anything was actually used: refund the
    full reservation and send the request back to "approved" so the family
    can book a different caregiver."""
    if aid_request.status != "assigned":
        return

    prev = get_latest_fund_summary(db)
    db.add(FundSummary(
        aid_request_id=aid_request.id,
        balance=prev.balance + aid_request.approved_amount,
        total_donations=prev.total_donations,
        pending_aids_count=prev.pending_aids_count,
        aids_distributed_no=prev.aids_distributed_no,
        aids_distributed_amount=prev.aids_distributed_amount,
    ))
    aid_request.status = "approved"


def finalize_aid_disbursement(db: Session, aid_request: AidRequest, actual_amount: float) -> None:
    """Caregiver accepted: only `actual_amount` (the booking's real cost --
    can be less than the approved ceiling) is actually spent. Credit the
    unused remainder of the earlier reservation back to the balance and
    record the real amount, not the ceiling, as distributed.
    """
    if aid_request.status == "disbursed":
        return

    prev = get_latest_fund_summary(db)
    refund = round(aid_request.approved_amount - actual_amount, 2)
    db.add(FundSummary(
        aid_request_id=aid_request.id,
        balance=prev.balance + refund,
        total_donations=prev.total_donations,
        pending_aids_count=prev.pending_aids_count,
        aids_distributed_no=prev.aids_distributed_no + 1,
        aids_distributed_amount=prev.aids_distributed_amount + actual_amount,
    ))
    aid_request.status = "disbursed"
