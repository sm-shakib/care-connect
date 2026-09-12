from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.db.session import get_db
from app.models.booking import Booking
from app.models.caregiver import Caregiver
from app.models.elder import Elder
from app.models.family import Family
from app.models.binding import FamilyElderLink
from app.models.fund import AidRequest
from app.models.notification import Notification
from app.schemas.booking import BookingCreate, BookingOut, BookingUpdate
from app.api.deps import get_current_user
from app.models.user import User
from app.core.bkash import bkash_client
from app.services.pricing import calculate_service_amount
from app.services.fund_service import finalize_aid_disbursement, release_aid_reservation
import uuid

router = APIRouter()

@router.post("/", response_model=BookingOut)
def create_booking(
    booking_in: BookingCreate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Find the name of the current user
    requester_name = "Unknown"
    if current_user.role == "elder":
        elder_profile = db.query(Elder).filter(Elder.user_id == current_user.id).first()
        if elder_profile:
            requester_name = elder_profile.name
    elif current_user.role == "family":
        family_profile = db.query(Family).filter(Family.user_id == current_user.id).first()
        if family_profile:
            requester_name = family_profile.name

    # 1. Fetch caregiver to get their fixed hourly rate
    caregiver = db.query(Caregiver).filter(Caregiver.id == booking_in.caregiver_id).first()
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")

    # 2. Compute the total cost for this schedule at the caregiver's rate
    total_amount = calculate_service_amount(
        hourly_rate=caregiver.hourly_rate,
        service_start_date=booking_in.service_start_date,
        service_end_date=booking_in.service_end_date,
        days_of_week=booking_in.days_of_week,
        daily_timing_start=booking_in.daily_timing_start,
        daily_timing_end=booking_in.daily_timing_end,
    )

    booking_data = booking_in.model_dump()
    booking_data["total_amount"] = total_amount
    booking_data["requested_by_name"] = requester_name

    new_booking = Booking(**booking_data)
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    # Reload with relationships for the response
    return db.query(Booking).options(
        joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.id == new_booking.id).first()

@router.get("/caregiver/{caregiver_id}", response_model=List[BookingOut])
def get_caregiver_bookings(caregiver_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(
        joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.caregiver_id == caregiver_id).all()
    return bookings

@router.get("/elder/{elder_id}", response_model=List[BookingOut])
def get_elder_bookings(elder_id: int, db: Session = Depends(get_db)):
    bookings = db.query(Booking).options(
        joinedload(Booking.elder),
        joinedload(Booking.caregiver).joinedload(Caregiver.user)
    ).filter(Booking.elder_id == elder_id).all()
    return bookings

@router.patch("/{booking_id}", response_model=BookingOut)
def update_booking(booking_id: int, booking_update: BookingUpdate, db: Session = Depends(get_db)):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    old_status = booking.status
    update_data = booking_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(booking, key, value)

    # If this booking was created against an approved aid request, the
    # caregiver's accept/reject decision drives the aid request onward.
    # The approved amount was already reserved out of the fund when the
    # booking was created (app/api/fund.py::book_caregiver_for_aid_request);
    # here we settle that reservation one way or the other:
    #   accept  -> spend only what this booking actually costs, refund the
    #              unused remainder of the approved ceiling back to the fund
    #   reject  -> refund the whole reservation; family can pick someone else
    if booking.aid_request_id and update_data.get("status") and update_data["status"] != old_status:
        aid_request = db.query(AidRequest).filter(AidRequest.id == booking.aid_request_id).first()
        if aid_request:
            if update_data["status"] == "accepted":
                finalize_aid_disbursement(db, aid_request, booking.total_amount)
                db.add(Notification(
                    user_id=aid_request.requester_id,
                    title="Caregiver accepted",
                    body=f"Your assigned caregiver has accepted the job for aid request #{aid_request.id}.",
                    type="aid_booking_accepted",
                ))
            elif update_data["status"] == "rejected":
                release_aid_reservation(db, aid_request)
                db.add(Notification(
                    user_id=aid_request.requester_id,
                    title="Caregiver declined",
                    body=f"The assigned caregiver declined aid request #{aid_request.id}. Please choose another caregiver.",
                    type="aid_booking_rejected",
                ))

    db.commit()
    db.refresh(booking)
    return booking

@router.post("/{booking_id}/bkash/create")
async def create_bkash_payment(
    booking_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    # In a real app, you'd generate a unique merchantInvoiceNumber
    invoice_number = f"INV-{booking.id}-{uuid.uuid4().hex[:6]}"
    
    # The frontend catches these redirects
    callback_url = "http://careconnect.com/bkash/callback"
    
    try:
        payment_data = await bkash_client.create_payment(
            amount=booking.total_amount,
            invoice_number=invoice_number,
            callback_url=callback_url
        )
        return payment_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/{booking_id}/bkash/execute")
async def execute_bkash_payment(
    booking_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    body = await request.json()
    payment_id = body.get("paymentID")
    
    if not payment_id:
        raise HTTPException(status_code=400, detail="paymentID is required")

    try:
        execution_data = await bkash_client.execute_payment(payment_id)
        
        # Check if transaction was successful
        # bKash returns transactionStatus "Completed" on success
        if execution_data.get("transactionStatus") == "Completed":
            booking.payment_status = "completed"
            db.commit()
            db.refresh(booking)
            
            # Return the updated booking
            return db.query(Booking).options(
                joinedload(Booking.elder).joinedload(Elder.family_links).joinedload(FamilyElderLink.family),
                joinedload(Booking.caregiver).joinedload(Caregiver.user)
            ).filter(Booking.id == booking.id).first()
        else:
            raise HTTPException(status_code=400, detail=f"Payment execution failed: {execution_data}")
            
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
