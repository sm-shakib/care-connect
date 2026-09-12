"""Shared parsing + the single "how late is too late" rule for the plain
"8:00 AM"-style strings the app stores for medicine schedules (see
`Medicine.schedule_times`) and, combined with a date, for appointments
(see `Appointment.appointment_date`/`appointment_time`).

`MISSED_DOSE_GRACE` is the one place this rule lives on the backend; it
must be kept in sync with the Flutter app's own copy of it,
`missedDoseAfterMinutes` in
`frontend/lib/shared/medicine/utils/dose_status.dart`. Two consumers:
`app/services/notification_jobs.py` (when to notify the elder's care
circle about a missed dose) and `app/api/medicine.py::mark_medicine_taken`
(when a dose can no longer be marked taken at all).
"""
from datetime import date, datetime, timedelta
from typing import Optional

MISSED_DOSE_GRACE = timedelta(hours=2)


def parse_clock_time(time_str: str, on_date: date) -> Optional[datetime]:
    """Combines a stored "8:00 AM"-style time string with a date. Returns
    None for anything that doesn't parse instead of raising, so a bad
    value degrades to "skip" rather than crashing a caller."""
    try:
        parsed = datetime.strptime(time_str.strip(), "%I:%M %p")
    except (ValueError, AttributeError):
        return None
    return datetime.combine(on_date, parsed.time())
