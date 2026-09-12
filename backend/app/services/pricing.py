"""Shared fee calculation for hourly caregiver services.

Extracted from app/api/booking.py so the same "hourly rate x hours x
matching days" math can be reused wherever a cost needs to be computed
against a caregiver before a Booking row exists yet (e.g. showing a
family the cost of each eligible caregiver for an approved aid
request, in app/api/fund.py).
"""
from datetime import date, time, timedelta

DAY_MAP = {
    "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
    "friday": 4, "saturday": 5, "sunday": 6,
    "mon": 0, "tue": 1, "wed": 2, "thu": 3, "fri": 4, "sat": 5, "sun": 6,
}


def calculate_service_amount(
    hourly_rate: float,
    service_start_date: date,
    service_end_date: date,
    days_of_week: str,
    daily_timing_start: time,
    daily_timing_end: time,
) -> float:
    """Total cost for a caregiver at `hourly_rate` over the given schedule.

    Mirrors the calculation in app/api/booking.py::create_booking exactly,
    so a cost quoted before booking (e.g. to filter/rank caregivers) never
    drifts from the amount actually charged when the booking is created.
    """
    start_total_minutes = daily_timing_start.hour * 60 + daily_timing_start.minute
    end_total_minutes = daily_timing_end.hour * 60 + daily_timing_end.minute

    if end_total_minutes <= start_total_minutes:
        duration_hours = (end_total_minutes + 24 * 60 - start_total_minutes) / 60
    else:
        duration_hours = (end_total_minutes - start_total_minutes) / 60

    work_days_list = [d.strip().lower() for d in days_of_week.split(",")]
    work_day_ints = [DAY_MAP[d] for d in work_days_list if d in DAY_MAP]

    total_work_days = 0
    current_date = service_start_date
    while current_date <= service_end_date:
        if current_date.weekday() in work_day_ints:
            total_work_days += 1
        current_date += timedelta(days=1)

    return round(duration_hours * hourly_rate * total_work_days, 2)
