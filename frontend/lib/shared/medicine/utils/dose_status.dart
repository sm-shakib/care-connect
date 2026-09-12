/// Shared "is this scheduled dose missed yet?" rule, so every screen with
/// a "Mark Taken" button (the elder dashboard's [MedicationCard] and the
/// medicine details page's dose list) applies the exact same window.
///
/// Mirrors the backend's own grace period — see `_MISSED_DOSE_GRACE` in
/// `backend/app/services/notification_jobs.py` (when the elder's care
/// circle gets notified) and the lockout in
/// `backend/app/api/medicine.py::mark_medicine_taken` (when the take
/// request itself starts being rejected). Keep all three in sync if this
/// rule ever changes.
library;

/// How long after a dose's scheduled time it flips from "due" to
/// "missed" and can no longer be marked taken.
const missedDoseAfterMinutes = 120;

/// Minutes since midnight for a pre-formatted time label like "8:00 AM",
/// "14:30", or `null` if it doesn't match any known shape.
int? minutesSinceMidnight(String label) {
  final trimmed = label.trim();

  // 12-hour format: "8:00 AM" or "08:00 PM"
  final amPmMatch =
      RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(trimmed);
  if (amPmMatch != null) {
    var hour = int.parse(amPmMatch.group(1)!);
    final minute = int.parse(amPmMatch.group(2)!);
    final meridiem = amPmMatch.group(3)!.toUpperCase();
    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  // 24-hour format: "14:30" or "08:00"
  final simpleMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (simpleMatch != null) {
    final hour = int.parse(simpleMatch.group(1)!);
    final minute = int.parse(simpleMatch.group(2)!);
    return hour * 60 + minute;
  }

  return null;
}

/// Whether a not-yet-taken dose scheduled at [time] ("8:00 AM"-style) has
/// passed its taking window as of [now] (defaults to the current time).
bool isDoseMissed(String time, {DateTime? now}) {
  final doseMinutes = minutesSinceMidnight(time);
  if (doseMinutes == null) return false;
  final at = now ?? DateTime.now();
  return at.hour * 60 + at.minute - doseMinutes >= missedDoseAfterMinutes;
}
