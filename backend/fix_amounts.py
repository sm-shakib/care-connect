from sqlalchemy.orm import Session
from app.db.session import SessionLocal
# Import all models to ensure mappers are initialized
from app.models.user import User
from app.models.elder import Elder
from app.models.family import Family
from app.models.caregiver import Caregiver
from app.models.booking import Booking
from app.models.notification import Notification
from app.models.binding import FamilyElderLink
from app.models.medicine import Medicine
from datetime import timedelta

def calculate_amount(booking, caregiver):
    # Daily duration
    start_mins = booking.daily_timing_start.hour * 60 + booking.daily_timing_start.minute
    end_mins = booking.daily_timing_end.hour * 60 + booking.daily_timing_end.minute

    if end_mins <= start_mins:
        duration_hours = (end_mins + 24*60 - start_mins) / 60
    else:
        duration_hours = (end_mins - start_mins) / 60

    # Work days
    work_days_list = [d.strip().lower() for d in booking.days_of_week.split(",")]
    day_map = {
        "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
        "friday": 4, "saturday": 5, "sunday": 6,
        "mon": 0, "tue": 1, "wed": 2, "thu": 3, "fri": 4, "sat": 5, "sun": 6
    }
    work_day_ints = [day_map[d] for d in work_days_list if d in day_map]

    if not work_day_ints:
        print(f"Warning: Could not parse any days from '{booking.days_of_week}'. Defaulting to all days in range.")
        work_day_ints = [0, 1, 2, 3, 4, 5, 6]

    total_work_days = 0
    current_date = booking.service_start_date
    while current_date <= booking.service_end_date:
        if current_date.weekday() in work_day_ints:
            total_work_days += 1
        current_date += timedelta(days=1)

    return round(duration_hours * caregiver.hourly_rate * total_work_days, 2)

def fix_existing_amounts():
    db = SessionLocal()
    try:
        bookings = db.query(Booking).filter(Booking.total_amount == 0.0).all()
        print(f"Found {len(bookings)} bookings with 0.0 amount.")

        for b in bookings:
            caregiver = db.query(Caregiver).filter(Caregiver.id == b.caregiver_id).first()
            if caregiver:
                new_amount = calculate_amount(b, caregiver)
                print(f"Updating Booking #{b.id}: Setting amount to {new_amount} (Rate: {caregiver.hourly_rate})")
                b.total_amount = new_amount
            else:
                print(f"Skipping Booking #{b.id}: Caregiver not found.")

        db.commit()
        print("Database updated successfully!")
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_existing_amounts()
