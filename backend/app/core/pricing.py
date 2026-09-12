"""What a block of care costs.

Extracted from `app/api/booking.py` so aid-request allocation can price a
job the same way a normal booking is priced — the central fund must pay a
caregiver exactly what an elder booking them directly would pay, and the
admin client must not be the one deciding that number.
"""
from datetime import date, time, timedelta
from typing import List

# Both the long and short spellings appear in stored `days_of_week`
# strings, which are free text written by whichever screen created them.
_DAY_INDEXES = {
    "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
    "friday": 4, "saturday": 5, "sunday": 6,
    "mon": 0, "tue": 1, "wed": 2, "thu": 3, "fri": 4, "sat": 5, "sun": 6,
}


def daily_duration_hours(start: time, end: time) -> float:
    """Hours between two clock times, treating an end at or before the
    start as running past midnight rather than as a negative shift."""
    start_minutes = start.hour * 60 + start.minute
    end_minutes = end.hour * 60 + end.minute
    if end_minutes <= start_minutes:
        return (end_minutes + 24 * 60 - start_minutes) / 60
    return (end_minutes - start_minutes) / 60


def working_days(start: date, end: date, days_of_week: str) -> int:
    """How many days in the range fall on one of the selected weekdays."""
    selected: List[int] = [
        _DAY_INDEXES[day.strip().lower()]
        for day in (days_of_week or "").split(",")
        if day.strip().lower() in _DAY_INDEXES
    ]
    if not selected:
        return 0

    total = 0
    current = start
    while current <= end:
        if current.weekday() in selected:
            total += 1
        current += timedelta(days=1)
    return total


def service_amount(
    hourly_rate: float,
    service_start_date: date,
    service_end_date: date,
    days_of_week: str,
    daily_timing_start: time,
    daily_timing_end: time,
) -> float:
    """Total fee for a whole service period, rounded to two decimals."""
    hours = daily_duration_hours(daily_timing_start, daily_timing_end)
    days = working_days(service_start_date, service_end_date, days_of_week)
    return round(hours * hourly_rate * days, 2)
