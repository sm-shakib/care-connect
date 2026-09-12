"""Shared helper for finding who should be notified about an elder's
care-related events: the people with an accepted binding to that elder,
whether as family or as a booked caregiver.

Used by the SOS alert (`app/api/elder.py::trigger_sos`) and the
missed-medicine background job (`app/services/notification_jobs.py`).
"""
from typing import List, Tuple

from sqlalchemy.orm import Session, joinedload

from app.models.binding import FamilyElderLink, BindingStatus
from app.models.booking import Booking
from app.models.elder import Elder


def get_elder_care_circle(db: Session, elder: Elder) -> List[Tuple[int, str, str]]:
    """Everyone allowed to see this elder's info today: accepted family
    links plus caregivers with an accepted booking — the same audiences
    `_check_elder_access` treats as authorized elsewhere in `elder.py`.

    Returns `(user_id, role, name)` tuples, `role` being "family" or
    "caregiver". A caregiver with more than one accepted booking for the
    same elder is only included once.
    """
    recipients: List[Tuple[int, str, str]] = []

    family_links = db.query(FamilyElderLink).options(
        joinedload(FamilyElderLink.family)
    ).filter(
        FamilyElderLink.elder_id == elder.id,
        FamilyElderLink.status == BindingStatus.accepted
    ).all()
    for link in family_links:
        if link.family:
            recipients.append((link.family.user_id, "family", link.family.name))

    accepted_bookings = db.query(Booking).options(
        joinedload(Booking.caregiver)
    ).filter(
        Booking.elder_id == elder.id,
        Booking.status == "accepted"
    ).all()
    seen_caregiver_ids = set()
    for booking in accepted_bookings:
        caregiver = booking.caregiver
        if caregiver and caregiver.id not in seen_caregiver_ids:
            seen_caregiver_ids.add(caregiver.id)
            recipients.append((caregiver.user_id, "caregiver", caregiver.name))

    return recipients
