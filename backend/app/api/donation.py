from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func
from typing import List, Optional
from app.db.session import get_db
from app.api import deps
from app.models.donation import Donation
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.schemas.donation import DonationCreate, DonationOut, DonationStats
from app.core.bkash import bkash_client
import uuid

router = APIRouter()

@router.post("/", response_model=DonationOut)
def create_donation(
    donation_in: DonationCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Record a new donation to the Central Fund.
    """
    # Logic for status based on payment method:
    # - bkash: stay pending until 'execute' is called via official gateway
    # - nagad/rocket: mark completed for simulation using our custom UI
    # - bank/cash: stay pending until admin manually verifies deposit

    status = "pending"
    if donation_in.payment_method in ["nagad", "rocket"]:
        status = "completed"

    new_donation = Donation(
        donor_id=current_user.id,
        amount=donation_in.amount,
        payment_method=donation_in.payment_method,
        payment_status=status,
        transaction_id=donation_in.transaction_id
    )

    db.add(new_donation)
    db.commit()
    db.refresh(new_donation)
    return new_donation

@router.post("/{donation_id}/bkash/create")
async def create_donation_bkash_payment(
    donation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    donation = db.query(Donation).filter(
        Donation.id == donation_id,
        Donation.donor_id == current_user.id
    ).first()
    if not donation:
        raise HTTPException(status_code=404, detail="Donation record not found")

    invoice_number = f"DON-{donation.id}-{uuid.uuid4().hex[:6]}"
    callback_url = "http://careconnect.com/bkash/callback"

    try:
        payment_data = await bkash_client.create_payment(
            amount=donation.amount,
            invoice_number=invoice_number,
            callback_url=callback_url
        )
        return payment_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{donation_id}/bkash/execute")
async def execute_donation_bkash_payment(
    donation_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    donation = db.query(Donation).filter(
        Donation.id == donation_id,
        Donation.donor_id == current_user.id
    ).first()
    if not donation:
        raise HTTPException(status_code=404, detail="Donation record not found")

    body = await request.json()
    payment_id = body.get("paymentID")

    if not payment_id:
        raise HTTPException(status_code=400, detail="paymentID is required")

    try:
        execution_data = await bkash_client.execute_payment(payment_id)

        if execution_data.get("transactionStatus") == "Completed":
            donation.payment_status = "completed"
            donation.transaction_id = execution_data.get("trxID")
            db.commit()
            db.refresh(donation)
            return donation
        else:
            donation.payment_status = "failed"
            db.commit()
            raise HTTPException(status_code=400, detail=f"Payment execution failed: {execution_data}")

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/me", response_model=List[DonationOut])
def get_my_donations(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user)
):
    """
    Get donation history for the current user.
    """
    return db.query(Donation).filter(Donation.donor_id == current_user.id).order_by(Donation.created_at.desc()).all()

@router.get("/admin/stats", response_model=DonationStats)
def get_donation_stats(
    db: Session = Depends(get_db),
    current_admin: User = Depends(deps.get_current_admin)
):
    """
    Admin only: Get total funds and recent activity.
    """
    total_amount = db.query(func.sum(Donation.amount)).filter(Donation.payment_status == "completed").scalar() or 0.0
    count = db.query(Donation).count()

    recent = db.query(Donation).options(
        joinedload(Donation.donor).joinedload(User.elder_profile),
        joinedload(Donation.donor).joinedload(User.family_profile)
    ).order_by(Donation.created_at.desc()).limit(10).all()

    recent_formatted = []
    for d in recent:
        name = "Anonymous"
        image_url = ""
        role = d.donor.role

        if d.donor.role == "elder" and d.donor.elder_profile:
            name = d.donor.elder_profile.name
            image_url = d.donor.elder_profile.profile_image_url or ""
        elif d.donor.role == "family" and d.donor.family_profile:
            name = d.donor.family_profile.name
            image_url = d.donor.family_profile.profile_image_url or ""

        recent_formatted.append({
            "id": d.id,
            "donor_id": d.donor.id, # Using the User ID for profile navigation
            "amount": d.amount,
            "payment_method": d.payment_method,
            "payment_status": d.payment_status,
            "transaction_id": d.transaction_id,
            "created_at": d.created_at,
            "donor_name": name,
            "donor_image_url": image_url,
            "donor_role": role
        })

    return {
        "total_amount": total_amount,
        "donation_count": count,
        "recent_donations": recent_formatted
    }
