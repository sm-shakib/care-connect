from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from app.db.session import get_db
from app.api import deps
from app.models.fund import FundSummary, Donation, AidRequest
from app.schemas.fund import DonationCreate, DonationOut, AidRequestCreate, AidRequestOut, FundStats, AidRequestUpdate
from app.models.user import User

from app.core.bkash import bkash_client
import uuid

router = APIRouter(prefix="/fund", tags=["Fund"])

def get_fund_summary(db: Session) -> FundSummary:
    summary = db.query(FundSummary).first()
    if not summary:
        summary = FundSummary(
            balance=0.0, 
            total_donations=0.0, 
            pending_aids_count=0, 
            aids_distributed_no=0, 
            aids_distributed_amount=0.0
        )
        db.add(summary)
        db.flush()  # Use flush instead of commit to stay within the same transaction
    return summary

@router.get("/stats", response_model=FundStats)
def get_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """Get overall fund statistics."""
    summary = get_fund_summary(db)
    db.commit() # Ensure the initial row is committed if created
    return summary

@router.post("/donate", response_model=DonationOut)
def donate(
    donation_in: DonationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """Record a new donation and update fund balance."""
    donation = Donation(
        donor_id=current_user.id,
        amount=donation_in.amount,
        payment_method=donation_in.payment_method,
        transaction_id=donation_in.transaction_id,
        status="completed" # Simplified: assuming payment success for now
    )
    db.add(donation)
    
    # Update FundSummary
    summary = get_fund_summary(db)
    summary.balance += donation_in.amount
    summary.total_donations += donation_in.amount
    
    db.commit()
    db.refresh(donation)
    return donation

@router.post("/bkash/create")
async def create_fund_bkash_payment(
    donation_in: DonationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    # 1. Create a pending donation
    donation = Donation(
        donor_id=current_user.id,
        amount=donation_in.amount,
        payment_method="bkash",
        status="pending"
    )
    db.add(donation)
    db.commit()
    db.refresh(donation)

    # 2. Call bKash Create API
    invoice_number = f"FUND-{donation.id}-{uuid.uuid4().hex[:6]}"
    callback_url = "http://careconnect.com/bkash/callback"
    
    try:
        payment_data = await bkash_client.create_payment(
            amount=donation.amount,
            invoice_number=invoice_number,
            callback_url=callback_url
        )
        # Store paymentID temporarily if needed, or just return to frontend
        return {**payment_data, "donation_id": donation.id}
    except Exception as e:
        db.delete(donation)
        db.commit()
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/bkash/execute")
async def execute_fund_bkash_payment(
    payment_id: str,
    donation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    donation = db.query(Donation).filter(Donation.id == donation_id).first()
    if not donation:
        raise HTTPException(status_code=404, detail="Donation record not found")

    try:
        execution_data = await bkash_client.execute_payment(payment_id)
        
        if execution_data.get("transactionStatus") == "Completed":
            donation.status = "completed"
            donation.transaction_id = execution_data.get("trxID")
            
            # Update FundSummary
            summary = get_fund_summary(db)
            summary.balance += donation.amount
            summary.total_donations += donation.amount
            
            db.commit()
            db.refresh(donation)
            return {"status": "success", "donation": donation}
        else:
            donation.status = "failed"
            db.commit()
            raise HTTPException(status_code=400, detail=f"Payment failed: {execution_data}")
            
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/request-aid", response_model=AidRequestOut)
def request_aid(
    request_in: AidRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """Submit a new aid request from an elder."""
    aid_request = AidRequest(
        requester_id=current_user.id,
        caregiver_type=request_in.caregiver_type,
        reason=request_in.reason,
        document_url=request_in.document_url,
        status="pending"
    )
    db.add(aid_request)
    
    # Update pending count
    summary = get_fund_summary(db)
    summary.pending_aids_count += 1
    
    db.commit()
    db.refresh(aid_request)
    return aid_request

@router.get("/my-donations", response_model=List[DonationOut])
def get_my_donations(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """Get donation history for the current user."""
    donations = db.query(Donation).filter(Donation.donor_id == current_user.id).order_by(Donation.created_at.desc()).all()
    results = []
    for d in donations:
        d_out = DonationOut.model_validate(d)
        d_out.donor_name = "You"
        results.append(d_out)
    return results

@router.get("/my-requests", response_model=List[AidRequestOut])
def get_my_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """Get aid request history for the current user."""
    requests = db.query(AidRequest).filter(AidRequest.requester_id == current_user.id).order_by(AidRequest.created_at.desc()).all()
    results = []
    for r in requests:
        r_out = AidRequestOut.model_validate(r)
        r_out.requester_name = "You"
        results.append(r_out)
    return results

# --- Admin Endpoints ---

@router.get("/admin/donations", response_model=List[DonationOut])
def list_donations(
    db: Session = Depends(get_db),
    current_admin: User = Depends(deps.get_current_admin)
):
    """List all donations for admin monitoring."""
    donations = db.query(Donation).options(
        joinedload(Donation.donor)
    ).filter(Donation.status == "completed").order_by(Donation.created_at.desc()).all()
    
    results = []
    for d in donations:
        if not d.donor:
            continue
            
        name = d.donor.email
        image = None
        
        # Access profiles directly from the donor object
        if d.donor.elder_profile:
            name = d.donor.elder_profile.name
            image = d.donor.elder_profile.profile_image_url
        elif d.donor.family_profile:
            name = d.donor.family_profile.name
            image = d.donor.family_profile.profile_image_url
        elif d.donor.caregiver_profile:
            name = d.donor.caregiver_profile.name
            image = d.donor.caregiver_profile.profile_image_url
            
        d_out = DonationOut.model_validate(d)
        d_out.donor_name = name
        d_out.donor_role = d.donor.role
        d_out.profile_image_url = image
        results.append(d_out)
    return results

@router.get("/admin/requests", response_model=List[AidRequestOut])
def list_aid_requests(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin: User = Depends(deps.get_current_admin)
):
    """List all aid requests for admin review."""
    query = db.query(AidRequest).options(joinedload(AidRequest.requester))
    if status:
        query = query.filter(AidRequest.status == status)
    
    requests = query.all()
    results = []
    for r in requests:
        if not r.requester:
            continue
            
        name = r.requester.email
        if r.requester.elder_profile:
            name = r.requester.elder_profile.name
        elif r.requester.family_profile:
            name = r.requester.family_profile.name
        elif r.requester.caregiver_profile:
            name = r.requester.caregiver_profile.name
            
        r_out = AidRequestOut.model_validate(r)
        r_out.requester_name = name
        results.append(r_out)
        
    return results

@router.patch("/admin/requests/{request_id}/review", response_model=AidRequestOut)
def review_aid_request(
    request_id: int,
    review_in: AidRequestUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(deps.get_current_admin)
):
    """Approve or reject an aid request and update fund stats."""
    aid_request = db.query(AidRequest).filter(AidRequest.id == request_id).first()
    if not aid_request:
        raise HTTPException(status_code=404, detail="Aid request not found")

    old_status = aid_request.status
    
    if review_in.status:
        aid_request.status = review_in.status
    if review_in.approved_amount is not None:
        aid_request.approved_amount = review_in.approved_amount
    if review_in.admin_notes:
        aid_request.admin_notes = review_in.admin_notes
        
    db.commit()
    
    # Logic to update summary if status changed
    summary = get_fund_summary(db)

    # 1. Update pending count if status moved away from pending
    if old_status == "pending" and aid_request.status != "pending":
        summary.pending_aids_count = max(0, summary.pending_aids_count - 1)

    # 2. Check for sufficient balance if status is changing to disbursed
    if old_status != "disbursed" and aid_request.status == "disbursed":
        if summary.balance < aid_request.approved_amount:
            # Revert status change if balance is insufficient
            aid_request.status = old_status
            db.commit()
            raise HTTPException(
                status_code=400, 
                detail=f"Insufficient Fund Balance. Available: ৳{summary.balance}"
            )
        
        summary.balance -= aid_request.approved_amount
        summary.aids_distributed_no += 1
        summary.aids_distributed_amount += aid_request.approved_amount
        
    db.commit()
    db.refresh(aid_request)
    return aid_request
