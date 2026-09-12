"""Background polling jobs that turn time-based care events into
in-app [Notification] rows — nothing in the normal request/response cycle
triggers these, so `run_notification_background_jobs` is started once
from `main.py`'s lifespan and polls forever:

- A medicine dose whose scheduled time has passed (past a grace period)
  without being marked taken -> notifies the elder's care circle
  (accepted family + caregiver, see `app/services/care_circle.py`).
- An appointment starting within the hour -> notifies the elder.

Both dates/times are read the same way the rest of the app writes them —
plain local-time strings (see `Medicine.schedule_times`,
`Appointment.appointment_date`/`appointment_time`) — so comparisons here
use naive local `datetime.now()`, matching `date.today()` in
`app/api/medicine.py`.
"""
import asyncio
import logging
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.elder import Elder
from app.models.medicine import Medicine
from app.models.notification import Notification
from app.models.reminder import Appointment
from app.services.care_circle import get_elder_care_circle
from app.services.time_parsing import MISSED_DOSE_GRACE, parse_clock_time

logger = logging.getLogger(__name__)

# How often the loop wakes up to re-check everything.
_POLL_INTERVAL_SECONDS = 300  # 5 minutes

# How far ahead of an appointment its "starting soon" reminder fires.
_APPOINTMENT_REMINDER_LEAD = timedelta(hours=1)


def _parse_appointment_datetime(appointment: Appointment) -> Optional[datetime]:
    """Parses the "Sep 2, 2026" + "10:30 AM"-style strings written by
    `AppointmentFormSheet` (see `DateFormat('MMM d, yyyy')` and
    `TimeOfDay.format` in the Flutter app)."""
    try:
        appt_date = datetime.strptime(appointment.appointment_date.strip(), "%b %d, %Y").date()
    except (ValueError, AttributeError):
        return None
    return parse_clock_time(appointment.appointment_time, appt_date)


def check_missed_medicines(db: Session, now: Optional[datetime] = None) -> None:
    """Notifies an elder's care circle, once per dose, about any dose
    still unmarked `MISSED_DOSE_GRACE` after its scheduled time — the same
    point at which `mark_medicine_taken` stops accepting it."""
    now = now or datetime.now()
    today = now.date()
    start_of_today = datetime.combine(today, datetime.min.time())

    medicines = db.query(Medicine).filter(
        Medicine.start_date <= today,
        Medicine.end_date >= today,
    ).all()

    for medicine in medicines:
        taken_today = medicine.taken_dose_times if medicine.taken_on_date == today else []
        for dose_time in medicine.schedule_times or []:
            if dose_time in taken_today:
                continue

            scheduled_at = parse_clock_time(dose_time, today)
            if scheduled_at is None or now < scheduled_at + MISSED_DOSE_GRACE:
                continue

            already_notified = db.query(Notification.id).filter(
                Notification.type == "medicine_missed",
                Notification.medicine_id == medicine.id,
                Notification.dose_time == dose_time,
                Notification.created_at >= start_of_today,
            ).first()
            if already_notified:
                continue

            elder = db.query(Elder).filter(Elder.id == medicine.elder_id).first()
            if not elder:
                continue

            for user_id, _role, _name in get_elder_care_circle(db, elder):
                db.add(Notification(
                    user_id=user_id,
                    title=f"Missed dose: {medicine.name}",
                    body=f"{elder.name} hasn't marked their {dose_time} dose of {medicine.name} as taken.",
                    type="medicine_missed",
                    medicine_id=medicine.id,
                    dose_time=dose_time,
                ))

    db.commit()


def check_upcoming_appointments(db: Session, now: Optional[datetime] = None) -> None:
    """Notifies the elder once, roughly an hour ahead of each of their
    upcoming appointments."""
    now = now or datetime.now()

    for appointment in db.query(Appointment).all():
        appt_at = _parse_appointment_datetime(appointment)
        if appt_at is None:
            continue

        time_until = appt_at - now
        if time_until < timedelta(0) or time_until > _APPOINTMENT_REMINDER_LEAD:
            continue

        already_notified = db.query(Notification.id).filter(
            Notification.type == "appointment_reminder",
            Notification.appointment_id == appointment.id,
        ).first()
        if already_notified:
            continue

        elder = db.query(Elder).filter(Elder.id == appointment.elder_id).first()
        if not elder:
            continue

        db.add(Notification(
            user_id=elder.user_id,
            title="Upcoming appointment",
            # `doctor_name` is entered with its own "Dr." prefix already
            # (see `AppointmentFormSheet`'s hint text), so it isn't added
            # again here.
            body=f"You have an appointment with {appointment.doctor_name} at "
                 f"{appointment.appointment_time} today.",
            type="appointment_reminder",
            appointment_id=appointment.id,
        ))

    db.commit()


async def run_notification_background_jobs() -> None:
    """Entry point started once from `main.py`'s lifespan. Runs forever,
    each iteration on its own short-lived DB session so a connection is
    never held open across the sleep."""
    while True:
        db = SessionLocal()
        try:
            check_missed_medicines(db)
            check_upcoming_appointments(db)
        except Exception:
            logger.exception("Notification background job failed")
            db.rollback()
        finally:
            db.close()
        await asyncio.sleep(_POLL_INTERVAL_SECONDS)
